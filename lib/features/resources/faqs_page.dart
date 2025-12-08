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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFAQs();
    });
  }

  Future<void> _loadFAQs() async {
    if (!mounted) return;

    ref.read(isLoadingFAQsProvider.notifier).state = true;
    ref.read(faqsErrorProvider.notifier).state = null;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final faqs = await apiService.getFAQs();

      if (!mounted) return;

      ref.read(faqsListProvider.notifier).state = faqs;
      ref.read(isLoadingFAQsProvider.notifier).state = false;
    } catch (e) {
      if (!mounted) return;
      ref.read(faqsErrorProvider.notifier).state = e.toString();
      ref.read(isLoadingFAQsProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingFAQsProvider);
    final error = ref.watch(faqsErrorProvider);
    final faqs = ref.watch(faqsListProvider);

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : error != null
              ? ErrorState(title: error, onRetry: _loadFAQs)
              : faqs.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.help_outline_rounded,
                      title: 'no_faqs_found'.tr(context),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFAQs,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: faqs.length,
                        itemBuilder: (context, index) {
                          final faq = faqs[index];
                          return FAQCard(faq: faq, index: index);
                        },
                      ),
                    ),
    );
  }
}
