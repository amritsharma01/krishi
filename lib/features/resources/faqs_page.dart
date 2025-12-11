import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/error_state.dart';
import 'package:krishi/features/resources/providers/faqs_providers.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';
import 'package:krishi/features/resources/widgets/faqs_widgets.dart';

class FAQsPage extends ConsumerStatefulWidget {
  const FAQsPage({super.key});

  @override
  ConsumerState<FAQsPage> createState() => _FAQsPageState();
}

class _FAQsPageState extends ConsumerState<FAQsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFAQs();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFAQs({bool force = false}) async {
    if (!force && _hasLoaded && ref.read(faqsListProvider).isNotEmpty) {
      return;
    }

    ref.read(isLoadingFAQsProvider.notifier).state = true;
    ref.read(faqsErrorProvider.notifier).state = null;
    ref.read(faqsCurrentPageProvider.notifier).state = 1;
    ref.read(faqsHasMoreProvider.notifier).state = true;
    ref.read(faqsListProvider.notifier).state = [];

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getFAQs(page: 1, pageSize: 10);

      if (!mounted) return;

      ref.read(faqsListProvider.notifier).state = response.results;
      ref.read(isLoadingFAQsProvider.notifier).state = false;
      ref.read(faqsHasMoreProvider.notifier).state = response.next != null;
      ref.read(faqsCurrentPageProvider.notifier).state = 2;
      _hasLoaded = true;
    } catch (e) {
      if (!mounted) return;
      ref.read(faqsErrorProvider.notifier).state = e.toString();
      ref.read(isLoadingFAQsProvider.notifier).state = false;
    }
  }

  Future<void> _loadMoreFAQs() async {
    final isLoading = ref.read(isLoadingMoreFAQsProvider);
    final hasMore = ref.read(faqsHasMoreProvider);

    if (isLoading || !hasMore) return;

    ref.read(isLoadingMoreFAQsProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(faqsCurrentPageProvider);
      final response = await apiService.getFAQs(
        page: currentPage,
        pageSize: 10,
      );

      if (!mounted) return;

      final currentFAQs = ref.read(faqsListProvider);
      ref.read(faqsListProvider.notifier).state = [
        ...currentFAQs,
        ...response.results,
      ];
      ref.read(faqsHasMoreProvider.notifier).state = response.next != null;
      ref.read(faqsCurrentPageProvider.notifier).state = currentPage + 1;
      ref.read(isLoadingMoreFAQsProvider.notifier).state = false;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingMoreFAQsProvider.notifier).state = false;
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isLoading = ref.read(isLoadingMoreFAQsProvider);
    final hasMore = ref.read(faqsHasMoreProvider);

    if (isLoading || !hasMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreFAQs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingFAQsProvider);
    final error = ref.watch(faqsErrorProvider);
    final faqs = ref.watch(faqsListProvider);
    final isLoadingMore = ref.watch(isLoadingMoreFAQsProvider);

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'faqs'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Colors.white),
        ),
        backgroundColor: Get.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadFAQs(force: true),
        child: isLoading && faqs.isEmpty
            ? const Center(child: CircularProgressIndicator.adaptive())
            : error != null
            ? ErrorState(title: error, onRetry: () => _loadFAQs(force: true))
            : faqs.isEmpty
            ? EmptyStateWidget(
                icon: Icons.help_outline_rounded,
                title: 'no_faqs_found'.tr(context),
              )
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: faqs.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == faqs.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Get.primaryColor,
                          ),
                        ),
                      ),
                    );
                  }
                  final faq = faqs[index];
                  return FAQCard(faq: faq, index: index);
                },
              ),
      ),
    );
  }
}
