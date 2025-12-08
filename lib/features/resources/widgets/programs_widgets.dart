import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';

class ProgramsHeader extends StatelessWidget {
  final Widget searchField;

  const ProgramsHeader({super.key, required this.searchField});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.wt, vertical: 8.ht),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.vertical(
          bottom: const Radius.circular(20),
        ).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.wt),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'agricultural_development_programs'.tr(context),
                  style: Get.bodyLarge.px14.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                4.verticalGap,
                AppText(
                  maxLines: 4,
                  'programs_intro'.tr(context),
                  style: Get.bodyMedium.px12.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          6.verticalGap,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.wt),
            child: searchField,
          ),
        ],
      ),
    );
  }
}

class ProgramCard extends StatelessWidget {
  final Program program;
  final VoidCallback onApply;

  const ProgramCard({super.key, required this.program, required this.onApply});

  @override
  Widget build(BuildContext context) {
    final titleColor =
        Get.bodyLarge.color ?? (Get.isDark ? Colors.white : Colors.black87);
    final bodyColor =
        Get.bodyMedium.color ?? (Get.isDark ? Colors.white70 : Colors.black87);
    final dateText = DateFormat('MMM dd, yyyy').format(program.createdAt);

    return Container(
      margin: EdgeInsets.only(bottom: 16.ht),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.rt),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.rt),
                  decoration: BoxDecoration(
                    color: Get.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14).rt,
                  ),
                  child: Icon(
                    Icons.agriculture_rounded,
                    color: Get.primaryColor,
                  ),
                ),
                12.horizontalGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        program.title,
                        style: Get.bodyLarge.px16.w700.copyWith(
                          color: titleColor,
                        ),
                      ),
                      4.verticalGap,
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12.st,
                            color: Get.disabledColor.withValues(alpha: 0.7),
                          ),
                          4.horizontalGap,
                          AppText(
                            dateText,
                            style: Get.bodySmall.copyWith(
                              color: Get.disabledColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            12.verticalGap,
            AppText(
              program.description,
              style: Get.bodyMedium.copyWith(
                color: bodyColor.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
            16.verticalGap,
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onApply,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Get.primaryColor,
                  side: BorderSide(color: Get.primaryColor),
                  padding: EdgeInsets.symmetric(vertical: 12.ht),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14).rt,
                  ),
                ),
                icon: const Icon(Icons.open_in_new_rounded),
                label: AppText(
                  'apply_now'.tr(context),
                  style: Get.bodyMedium.w600.copyWith(color: Get.primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
