import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';
import 'package:krishi/features/support/providers/user_guides_providers.dart';
import 'package:krishi/features/support/user_manual_detail_page.dart';
import 'package:krishi/features/support/widgets/user_guide_widgets.dart';

class UserGuidePage extends ConsumerStatefulWidget {
  const UserGuidePage({super.key});

  @override
  ConsumerState<UserGuidePage> createState() => _UserGuidePageState();
}

class _UserGuidePageState extends ConsumerState<UserGuidePage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasLoaded = false;

  Map<String, String> _getCategories(BuildContext context) {
    return {
      'all': 'all_categories'.tr(context),
      'buying': 'buying'.tr(context),
      'selling': 'selling'.tr(context),
      'account': 'account'.tr(context),
      'orders': 'orders'.tr(context),
      'other': 'other'.tr(context),
    };
  }

  final Map<String, IconData> _categoryIcons = {
    'buying': Icons.shopping_cart_rounded,
    'selling': Icons.store_rounded,
    'account': Icons.person_rounded,
    'orders': Icons.receipt_long_rounded,
    'other': Icons.help_outline_rounded,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadManuals();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadManuals({String? category, bool force = false}) async {
    if (!mounted) return;

    final selectedCategory =
        category ?? ref.read(selectedUserGuideCategoryProvider);

    // Reset if category changed or force refresh
    if (category != null || force) {
      _hasLoaded = false;
    }

    if (!force && _hasLoaded && ref.read(userGuidesListProvider).isNotEmpty) {
      return;
    }

    ref.read(isLoadingUserGuidesProvider.notifier).state = true;
    ref.read(userGuidesCurrentPageProvider.notifier).state = 1;
    ref.read(userGuidesHasMoreProvider.notifier).state = true;
    ref.read(userGuidesListProvider.notifier).state = [];

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getUserManuals(
        category: selectedCategory == 'all' ? null : selectedCategory,
        page: 1,
        pageSize: 10,
      );

      if (!mounted) return;

      ref.read(userGuidesListProvider.notifier).state = response.results;
      ref.read(isLoadingUserGuidesProvider.notifier).state = false;
      ref.read(userGuidesHasMoreProvider.notifier).state =
          response.next != null;
      ref.read(userGuidesCurrentPageProvider.notifier).state = 2;
      _hasLoaded = true;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingUserGuidesProvider.notifier).state = false;
      Get.snackbar('error_loading_products'.tr(context));
    }
  }

  Future<void> _loadMoreManuals() async {
    final isLoading = ref.read(isLoadingMoreUserGuidesProvider);
    final hasMore = ref.read(userGuidesHasMoreProvider);

    if (isLoading || !hasMore) return;

    ref.read(isLoadingMoreUserGuidesProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(userGuidesCurrentPageProvider);
      final selectedCategory = ref.read(selectedUserGuideCategoryProvider);

      final response = await apiService.getUserManuals(
        category: selectedCategory == 'all' ? null : selectedCategory,
        page: currentPage,
        pageSize: 10,
      );

      if (!mounted) return;

      final currentManuals = ref.read(userGuidesListProvider);
      ref.read(userGuidesListProvider.notifier).state = [
        ...currentManuals,
        ...response.results,
      ];
      ref.read(userGuidesHasMoreProvider.notifier).state =
          response.next != null;
      ref.read(userGuidesCurrentPageProvider.notifier).state = currentPage + 1;
      ref.read(isLoadingMoreUserGuidesProvider.notifier).state = false;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingMoreUserGuidesProvider.notifier).state = false;
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isLoading = ref.read(isLoadingMoreUserGuidesProvider);
    final hasMore = ref.read(userGuidesHasMoreProvider);

    if (isLoading || !hasMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreManuals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingUserGuidesProvider);
    final manuals = ref.watch(userGuidesListProvider);
    final isLoadingMore = ref.watch(isLoadingMoreUserGuidesProvider);
    final hasManuals = manuals.isNotEmpty;

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'user_guide'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Get.disabledColor),
      ),
      body: Column(
        children: [
          UserGuideFilter(
            categories: _getCategories(context),
            categoryIcons: _categoryIcons,
            onFilterSelected: (category) {
              ref.read(selectedUserGuideCategoryProvider.notifier).state =
                  category;
              _loadManuals(category: category, force: true);
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadManuals(force: true),
              child: isLoading && manuals.isEmpty
                  ? Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : !hasManuals
                  ? EmptyStateWidget(
                      icon: Icons.menu_book_rounded,
                      title: 'no_manuals_available'.tr(context),
                      subtitle: 'check_back_later'.tr(context),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: manuals.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == manuals.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          );
                        }
                        final manual = manuals[index];
                        return UserGuideCard(
                          manual: manual,
                          categoryIcons: _categoryIcons,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserManualDetailPage(manual: manual),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
