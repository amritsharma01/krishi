import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14).rt),
      elevation: 2,
      child: InkWell(
        onTap: () {
          ref.read(expandedFAQIndexProvider.notifier).state = isExpanded
              ? null
              : index;
        },
        borderRadius: BorderRadius.circular(14).rt,
        child: Padding(
          padding: EdgeInsets.all(16.rt),
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
                  padding: EdgeInsets.all(14.rt),
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
                          maxLines: 50,
                          overflow: TextOverflow.visible,
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
