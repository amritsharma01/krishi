import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/knowledge/articles_page.dart';
import 'package:krishi/features/knowledge/news_page.dart';
import 'package:krishi/features/resources/crop_calendar_page.dart';
import 'package:krishi/features/resources/videos_page.dart';

class KnowledgeBaseGrid extends StatelessWidget {
  const KnowledgeBaseGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'knowledge_base'.tr(context),
          style: Get.bodyLarge.px14.w600.copyWith(color: Get.disabledColor),
        ),
        5.verticalGap,
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _KnowledgeCard(
                    title: 'krishi_gyaan'.tr(context),
                    icon: Icons.local_library_rounded,
                    onTap: () => Get.to(ArticlesPage()),
                  ),
                ),
                6.horizontalGap,
                Expanded(
                  child: _KnowledgeCard(
                    title: 'news_information'.tr(context),
                    icon: Icons.article_rounded,
                    onTap: () => Get.to(const NewsPage()),
                  ),
                ),
              ],
            ),
            6.verticalGap,
            Row(
              children: [
                Expanded(
                  child: _KnowledgeCard(
                    title: 'videos'.tr(context),
                    icon: Icons.video_library_rounded,
                    onTap: () => Get.to(const VideosPage()),
                  ),
                ),
                6.horizontalGap,
                Expanded(
                  child: _KnowledgeCard(
                    title: 'crop_calendar'.tr(context),
                    icon: Icons.calendar_month_rounded,
                    onTap: () => Get.to(const CropCalendarPage()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _KnowledgeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _KnowledgeCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10).rt,
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: Container(
          height: 40.ht,
          decoration: BoxDecoration(
            color: Get.cardColor,
            borderRadius: BorderRadius.circular(10).rt,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3).rt,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4).rt,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12).rt,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18.st),
                ),
                16.horizontalGap,
                Expanded(
                  child: AppText(
                    title,
                    style: Get.bodySmall.w700.copyWith(
                      fontSize: 8.sp,
                      color: Get.disabledColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                8.horizontalGap,
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.primary.withValues(alpha: 0.5),
                  size: 12.st,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
