import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/providers/experts_providers.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';
import 'package:krishi/features/resources/widgets/experts_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpertsPage extends ConsumerStatefulWidget {
  const ExpertsPage({super.key});

  @override
  ConsumerState<ExpertsPage> createState() => _ExpertsPageState();
}

class _ExpertsPageState extends ConsumerState<ExpertsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExperts();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadExperts({bool force = false}) async {
    if (!force && _hasLoaded && ref.read(expertsListProvider).isNotEmpty) {
      return;
    }

    ref.read(isLoadingExpertsProvider.notifier).state = true;
    ref.read(expertsCurrentPageProvider.notifier).state = 1;
    ref.read(expertsHasMoreProvider.notifier).state = true;
    ref.read(expertsListProvider.notifier).state = [];

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getExperts(page: 1, pageSize: 10);

      if (!mounted) return;

      ref.read(expertsListProvider.notifier).state = response.results;
      ref.read(isLoadingExpertsProvider.notifier).state = false;
      ref.read(expertsHasMoreProvider.notifier).state = response.next != null;
      ref.read(expertsCurrentPageProvider.notifier).state = 2;
      _hasLoaded = true;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingExpertsProvider.notifier).state = false;
      Get.snackbar('error_loading_products'.tr(context));
    }
  }

  Future<void> _loadMoreExperts() async {
    final isLoading = ref.read(isLoadingMoreExpertsProvider);
    final hasMore = ref.read(expertsHasMoreProvider);

    if (isLoading || !hasMore) return;

    ref.read(isLoadingMoreExpertsProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(expertsCurrentPageProvider);
      final response = await apiService.getExperts(
        page: currentPage,
        pageSize: 10,
      );

      if (!mounted) return;

      final currentExperts = ref.read(expertsListProvider);
      ref.read(expertsListProvider.notifier).state = [
        ...currentExperts,
        ...response.results,
      ];
      ref.read(expertsHasMoreProvider.notifier).state = response.next != null;
      ref.read(expertsCurrentPageProvider.notifier).state = currentPage + 1;
      ref.read(isLoadingMoreExpertsProvider.notifier).state = false;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingMoreExpertsProvider.notifier).state = false;
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isLoading = ref.read(isLoadingMoreExpertsProvider);
    final hasMore = ref.read(expertsHasMoreProvider);

    if (isLoading || !hasMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreExperts();
    }
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('could_not_make_call'.tr(context));
    }
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    if (email.isEmpty) {
      Get.snackbar('no_email_available'.tr(context));
      return;
    }
    try {
      final uri = Uri.parse('mailto:$email');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        Get.snackbar('could_not_send_email'.tr(context));
      }
    }
  }

  Future<void> _openWhatsApp(BuildContext context, String phoneNumber) async {
    try {
      // Remove any spaces or special characters
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Add country code if not present (Nepal country code is +977)
      if (!cleanNumber.startsWith('+') && !cleanNumber.startsWith('977')) {
        cleanNumber = '977$cleanNumber';
      }

      // Ensure it starts with + for WhatsApp
      if (!cleanNumber.startsWith('+')) {
        cleanNumber = '+$cleanNumber';
      }

      final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');

      // Try multiple launch modes
      try {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        try {
          await launchUrl(whatsappUri, mode: LaunchMode.platformDefault);
        } catch (e2) {
          try {
            await launchUrl(whatsappUri, mode: LaunchMode.inAppWebView);
          } catch (e3) {
            if (mounted) {
              Get.snackbar('whatsapp_failed'.tr(context), color: Colors.red);
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('whatsapp_failed'.tr(context), color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingExpertsProvider);
    final experts = ref.watch(expertsListProvider);
    final isLoadingMore = ref.watch(isLoadingMoreExpertsProvider);
    final hasExperts = experts.isNotEmpty;

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'agri_experts'.tr(context),
          style: Get.bodyLarge.px16.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Get.disabledColor),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadExperts(force: true),
        child: isLoading && experts.isEmpty
            ? Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : !hasExperts
            ? EmptyStateWidget(
                icon: Icons.person_search_rounded,
                title: 'no_experts_available'.tr(context),
                subtitle: 'check_back_later'.tr(context),
              )
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(6),
                itemCount: experts.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == experts.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  }
                  final expert = experts[index];
                  return ExpertCard(
                    expert: expert,
                    onCall: () => _makePhoneCall(context, expert.phoneNumber),
                    onWhatsApp: () =>
                        _openWhatsApp(context, expert.phoneNumber),
                    onEmail: expert.email.isNotEmpty
                        ? () => _sendEmail(context, expert.email)
                        : null,
                  );
                },
              ),
      ),
    );
  }
}
