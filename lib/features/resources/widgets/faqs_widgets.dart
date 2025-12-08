import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/providers/faqs_providers.dart';
import 'package:krishi/models/resources.dart';

class FAQCard extends ConsumerWidget {
  final FAQ faq;
  final int index;

  const FAQCard({super.key, required this.faq, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expandedIndex = ref.watch(expandedFAQIndexProvider);
    final isExpanded = expandedIndex == index;

    return Container(
      margin: EdgeInsets.only(bottom: 16.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(
          color: isExpanded
              ? Get.primaryColor.withValues(alpha: 0.3)
              : Get.disabledColor.withValues(alpha: 0.1),
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? Get.primaryColor.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isExpanded ? 12 : 8,
            offset: Offset(0, isExpanded ? 4 : 2),
            spreadRadius: isExpanded ? 1 : 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20).rt,
        child: InkWell(
          onTap: () {
            ref.read(expandedFAQIndexProvider.notifier).state = isExpanded
                ? null
                : index;
          },
          borderRadius: BorderRadius.circular(20).rt,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(20.rt),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Badge with gradient
                    Container(
                      width: 44.rt,
                      height: 44.rt,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Get.primaryColor,
                            Get.primaryColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Get.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AppText(
                          'Q',
                          style: Get.bodyLarge.px16.w700.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    16.horizontalGap,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            faq.question,
                            style: Get.bodyLarge.px15.w700.copyWith(
                              color: Get.disabledColor,
                              height: 1.4,
                            ),
                            maxLines: isExpanded ? null : 3,
                            overflow: isExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                          ),
                          if (!isExpanded) ...[
                            8.verticalGap,
                            Row(
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  size: 14.st,
                                  color: Get.primaryColor.withValues(alpha: 0.6),
                                ),
                                6.horizontalGap,
                                AppText(
                                  'Tap to view answer',
                                  style: Get.bodySmall.px11.copyWith(
                                    color: Get.primaryColor.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    12.horizontalGap,
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.all(8.rt),
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? Get.primaryColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isExpanded
                              ? Get.primaryColor
                              : Get.disabledColor.withValues(alpha: 0.6),
                          size: 28.st,
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: [
                      20.verticalGap,
                      Container(
                        padding: EdgeInsets.all(18.rt),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade50.withValues(alpha: Get.isDark ? 0.1 : 1),
                              Colors.green.shade100.withValues(alpha: Get.isDark ? 0.05 : 1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16).rt,
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40.rt,
                              height: 40.rt,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade600,
                                    Colors.green.shade700,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: AppText(
                                  'A',
                                  style: Get.bodyLarge.px16.w700.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            16.horizontalGap,
                            Expanded(
                              child: AppText(
                                faq.answer,
                                style: Get.bodyMedium.px14.w400.copyWith(
                                  height: 1.7,
                                  color: Get.disabledColor.withValues(alpha: 0.9),
                                ),
                                maxLines: null,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                  sizeCurve: Curves.easeInOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
