import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/empty_state.dart';
import 'package:krishi/features/components/error_state.dart';
import 'package:krishi/models/resources.dart';

class FAQsPage extends ConsumerStatefulWidget {
  const FAQsPage({super.key});

  @override
  ConsumerState<FAQsPage> createState() => _FAQsPageState();
}

class _FAQsPageState extends ConsumerState<FAQsPage> {
  List<FAQ> _faqs = [];
  bool _isLoading = true;
  String? _error;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _loadFAQs();
  }

  Future<void> _loadFAQs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final faqs = await apiService.getFAQs();
      setState(() {
        _faqs = faqs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? ErrorState(title: _error!, onRetry: _loadFAQs)
          : _faqs.isEmpty
          ? EmptyState(
              title: 'no_faqs_found'.tr(context),
              icon: Icons.help_outline_rounded,
            )
          : RefreshIndicator(
              onRefresh: _loadFAQs,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _faqs.length,
                itemBuilder: (context, index) {
                  final faq = _faqs[index];
                  final isExpanded = _expandedIndex == index;
                  return _buildFAQCard(faq, index, isExpanded);
                },
              ),
            ),
    );
  }

  Widget _buildFAQCard(FAQ faq, int index, bool isExpanded) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14).rt),
      elevation: 2,
      child: InkWell(
        onTap: () {
          setState(() {
            _expandedIndex = isExpanded ? null : index;
          });
        },
        borderRadius: BorderRadius.circular(14).rt,
        child: Padding(
          padding: const EdgeInsets.all(16).rt,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Get.primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppText(
                        'Q',
                        style: Get.bodyLarge.px15.w700.copyWith(
                          color: Get.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  12.horizontalGap,
                  Expanded(
                    child: AppText(
                      faq.question,
                      style: Get.bodyMedium.px15.w600,
                      maxLines: isExpanded ? null : 2,
                      overflow: isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                  ),
                  8.horizontalGap,
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Get.primaryColor,
                      size: 24.st,
                    ),
                  ),
                ],
              ),
              if (isExpanded) ...[
                16.verticalGap,
                Container(
                  padding: const EdgeInsets.all(14).rt,
                  decoration: BoxDecoration(
                    color: Get.cardColor,
                    borderRadius: BorderRadius.circular(10).rt,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: AppText(
                            'A',
                            style: Get.bodyLarge.px15.w700.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      12.horizontalGap,
                      Expanded(
                        child: AppText(
                          faq.answer,
                          style: Get.bodyMedium.px14.w400.copyWith(
                            height: 1.6,
                            color: Get.disabledColor.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
