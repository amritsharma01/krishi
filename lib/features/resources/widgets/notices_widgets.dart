import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/notice_detail_page.dart';
import 'package:krishi/features/resources/providers/notices_providers.dart';
import 'package:krishi/features/resources/widgets/filter_pill.dart';
import 'package:krishi/models/resources.dart';

class NoticesFilterChips extends ConsumerWidget {
  final Map<String, String> filterOptions;
  final Map<String, IconData> filterIcons;
  final Map<String, Color> filterColors;
  final Future<void> Function(String?) onFilterChanged;

  const NoticesFilterChips({
    super.key,
    required this.filterOptions,
    required this.filterIcons,
    required this.filterColors,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(selectedNoticeFilterProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wt, vertical: 12.ht),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.vertical(
          bottom: const Radius.circular(28),
        ).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filterOptions.entries.map((entry) {
            final isSelected = selectedFilter == entry.key;
            final color = filterColors[entry.key] ?? Get.primaryColor;
            final icon = entry.key == 'all'
                ? Icons.all_inclusive
                : filterIcons[entry.key] ?? Icons.article_rounded;
            return Padding(
              padding: EdgeInsets.only(right: 8.wt),
              child: FilterPill(
                label: entry.value,
                icon: icon,
                color: color,
                isSelected: isSelected,
                onTap: () {
                  ref.read(selectedNoticeFilterProvider.notifier).state =
                      entry.key;
                  onFilterChanged(entry.key);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NoticeCard extends StatelessWidget {
  final Notice notice;
  final Color typeColor;
  final IconData typeIcon;

  const NoticeCard({
    super.key,
    required this.notice,
    required this.typeColor,
    required this.typeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = Get.bodyLarge.color ??
        (Get.isDark ? Colors.white : Colors.black87);
    final bodyColor = Get.bodyMedium.color ??
        (Get.isDark ? Colors.white70 : Colors.black87);
    final mutedColor = Get.disabledColor.withValues(alpha: 0.9);

    return Container(
      margin: EdgeInsets.only(bottom: 16.ht),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(18).rt,
        border: Border.all(
          color: Get.disabledColor.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoticeDetailPage(notice: notice),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16).rt,
          child: Padding(
            padding: EdgeInsets.all(16.rt),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(
                            alpha: Get.isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(24).rt,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 14.st, color: typeColor),
                          6.horizontalGap,
                          AppText(
                            notice.noticeTypeDisplay,
                            style: Get.bodySmall.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.calendar_today_outlined,
                        size: 14.st, color: mutedColor),
                    6.horizontalGap,
                    AppText(
                      DateFormat('MMM dd, yyyy').format(notice.publishedDate),
                      style: Get.bodySmall.copyWith(
                        color: mutedColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                12.verticalGap,
                AppText(
                  notice.title,
                  style: Get.bodyLarge.px16.w600.copyWith(color: titleColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                8.verticalGap,
                AppText(
                  notice.description,
                  style: Get.bodyMedium.copyWith(
                    color: bodyColor.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (notice.pdfFile != null || notice.image != null) ...[
                  12.verticalGap,
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      if (notice.pdfFile != null)
                        _AttachmentChip(
                          label: 'pdf_attached'.tr(context),
                          icon: Icons.picture_as_pdf_rounded,
                          color: Colors.red.shade600,
                        ),
                      if (notice.image != null)
                        _AttachmentChip(
                          label: 'image_attached'.tr(context),
                          icon: Icons.image_rounded,
                          color: Colors.blue.shade600,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _AttachmentChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.wt, vertical: 6.ht),
      decoration: BoxDecoration(
        color: color.withValues(alpha: Get.isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(10).rt,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.st, color: color),
          6.horizontalGap,
          AppText(
            label,
            style: Get.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

