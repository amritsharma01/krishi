import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/providers/notices_providers.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';
import 'package:krishi/features/resources/widgets/notices_widgets.dart';

class NoticesPage extends ConsumerStatefulWidget {
  const NoticesPage({super.key});

  @override
  ConsumerState<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends ConsumerState<NoticesPage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasLoaded = false;

  Map<String, String> _getFilterOptions(BuildContext context) {
    return {
      'all': 'all_notices'.tr(context),
      'general': 'general'.tr(context),
      'important': 'important'.tr(context),
      'urgent': 'urgent'.tr(context),
      'event': 'events'.tr(context),
      'training': 'training'.tr(context),
    };
  }

  final Map<String, IconData> _filterIcons = {
    'general': Icons.article_rounded,
    'important': Icons.info_rounded,
    'urgent': Icons.warning_amber_rounded,
    'event': Icons.event_rounded,
    'training': Icons.school_rounded,
  };


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotices();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNotices({String? noticeType, bool force = false}) async {
    if (!mounted) return;

    final selectedFilter = noticeType ?? ref.read(selectedNoticeFilterProvider);

    // Reset if filter changed or force refresh
    if (noticeType != null || force) {
      _hasLoaded = false;
    }

    if (!force && _hasLoaded && ref.read(noticesListProvider).isNotEmpty) {
      return;
    }

    ref.read(isLoadingNoticesProvider.notifier).state = true;
    ref.read(noticesCurrentPageProvider.notifier).state = 1;
    ref.read(noticesHasMoreProvider.notifier).state = true;
    ref.read(noticesListProvider.notifier).state = [];

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getNotices(
        noticeType: selectedFilter == 'all' ? null : selectedFilter,
        page: 1,
        pageSize: 10,
      );

      if (!mounted) return;

      ref.read(noticesListProvider.notifier).state = response.results;
      ref.read(isLoadingNoticesProvider.notifier).state = false;
      ref.read(noticesHasMoreProvider.notifier).state = response.next != null;
      ref.read(noticesCurrentPageProvider.notifier).state = 2;
      _hasLoaded = true;
    } catch (e) {
      if (!mounted || e is FormatException) {
        return;
      }
      ref.read(isLoadingNoticesProvider.notifier).state = false;
      Get.snackbar('Failed to load notices: $e');
    }
  }

  Future<void> _loadMoreNotices() async {
    final isLoading = ref.read(isLoadingMoreNoticesProvider);
    final hasMore = ref.read(noticesHasMoreProvider);

    if (isLoading || !hasMore) return;

    ref.read(isLoadingMoreNoticesProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(noticesCurrentPageProvider);
      final selectedFilter = ref.read(selectedNoticeFilterProvider);

      final response = await apiService.getNotices(
        noticeType: selectedFilter == 'all' ? null : selectedFilter,
        page: currentPage,
        pageSize: 10,
      );

      if (!mounted) return;

      final currentNotices = ref.read(noticesListProvider);
      ref.read(noticesListProvider.notifier).state = [
        ...currentNotices,
        ...response.results,
      ];
      ref.read(noticesHasMoreProvider.notifier).state = response.next != null;
      ref.read(noticesCurrentPageProvider.notifier).state = currentPage + 1;
      ref.read(isLoadingMoreNoticesProvider.notifier).state = false;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingMoreNoticesProvider.notifier).state = false;
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isLoading = ref.read(isLoadingMoreNoticesProvider);
    final hasMore = ref.read(noticesHasMoreProvider);

    if (isLoading || !hasMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreNotices();
    }
  }

  Color _getNoticeTypeColor(String type) {
    switch (type) {
      case 'urgent':
        return Colors.red;
      case 'important':
        return Colors.orange;
      case 'event':
        return Colors.blue;
      case 'training':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getNoticeTypeIcon(String type) {
    switch (type) {
      case 'urgent':
        return Icons.warning_amber_rounded;
      case 'important':
        return Icons.info_rounded;
      case 'event':
        return Icons.event_rounded;
      case 'training':
        return Icons.school_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingNoticesProvider);
    final notices = ref.watch(noticesListProvider);
    final isLoadingMore = ref.watch(isLoadingMoreNoticesProvider);
    final hasNotices = notices.isNotEmpty;

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'notices_announcements'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Get.disabledColor),
      ),
      body: Column(
        children: [
          NoticesFilterChips(
            filterOptions: _getFilterOptions(context),
            filterIcons: _filterIcons,
            onFilterChanged: (noticeType) =>
                _loadNotices(noticeType: noticeType, force: true),
          ),
          Expanded(
            child: isLoading && notices.isEmpty
                ? const Center(child: CircularProgressIndicator.adaptive())
                : !hasNotices
                ? EmptyStateWidget(
                    icon: Icons.notifications_off_rounded,
                    title: 'no_notices_available'.tr(context),
                    subtitle: 'check_back_later_updates'.tr(context),
                  )
                : _buildNoticesList(context, isLoadingMore),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticesList(BuildContext context, bool isLoadingMore) {
    final notices = ref.watch(noticesListProvider);
    final selectedFilter = ref.watch(selectedNoticeFilterProvider);

    return RefreshIndicator(
      onRefresh: () => _loadNotices(noticeType: selectedFilter, force: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5).rt,
        itemCount: notices.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == notices.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16).rt,
              child: Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(Get.primaryColor),
                ),
              ),
            );
          }
          final notice = notices[index];
          return NoticeCard(
            notice: notice,
            typeColor: _getNoticeTypeColor(notice.noticeType),
            typeIcon: _getNoticeTypeIcon(notice.noticeType),
          );
        },
      ),
    );
  }
}
