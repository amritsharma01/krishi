import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';

class CropDetailHeader extends StatelessWidget {
  final CropCalendar crop;
  final Color color;
  final IconData icon;

  const CropDetailHeader({
    super.key,
    required this.crop,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240.h,
      pinned: true,
      backgroundColor: Get.scaffoldBackgroundColor,
      leadingWidth: 70.rt,
      leading: Padding(
        padding: EdgeInsets.only(left: 12.rt, top: 8.rt, bottom: 8.rt),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12).rt,
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18.st,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.blurBackground, StretchMode.fadeTitle],
        background: Stack(
          fit: StackFit.expand,
          children: [
            crop.image != null && crop.image!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: Get.imageUrl(crop.image!),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: color.withValues(alpha: 0.1),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        CropDetailPlaceholder(color: color, icon: icon),
                  )
                : CropDetailPlaceholder(color: color, icon: icon),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CropDetailPlaceholder extends StatelessWidget {
  final Color color;
  final IconData icon;

  const CropDetailPlaceholder({
    super.key,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(alpha: 0.1),
      child: Center(
        child: Icon(icon, size: 80.st, color: color.withValues(alpha: 0.3)),
      ),
    );
  }
}

class CropDetailTitle extends StatelessWidget {
  final CropCalendar crop;
  final Color color;
  final IconData icon;

  const CropDetailTitle({
    super.key,
    required this.crop,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: Get.isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(12).rt,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 14.st),
                  6.horizontalGap,
                  AppText(
                    crop.cropTypeDisplay,
                    style: Get.bodySmall.px12.w600.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
        6.verticalGap,
        AppText(
          crop.cropName,
          style: Get.bodyLarge.px16.w700.copyWith(
            color:
                Get.bodyLarge.color ??
                (Get.isDark ? Colors.white : Colors.black87),
            height: 1.35,
          ),
          maxLines: 10,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }
}

class CropQuickInfo extends StatelessWidget {
  final CropCalendar crop;

  const CropQuickInfo({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          CropQuickInfoRow(
            icon: Icons.schedule_rounded,
            label: 'growing_duration'.tr(context),
            value: '${crop.durationDays} days',
          ),

          Divider(color: Get.disabledColor.withValues(alpha: 0.1)),

          CropQuickInfoRow(
            icon: Icons.wb_sunny_rounded,
            label: 'planting_season'.tr(context),
            value: crop.plantingSeason,
          ),

          Divider(color: Get.disabledColor.withValues(alpha: 0.1)),
          CropQuickInfoRow(
            icon: Icons.agriculture_rounded,
            label: 'harvesting_season'.tr(context),
            value: crop.harvestingSeason,
          ),
        ],
      ),
    );
  }
}

class CropQuickInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const CropQuickInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.st,
          color: Get.disabledColor.withValues(alpha: 0.7),
        ),
        12.horizontalGap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                label,
                style: Get.bodySmall.px10.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.7),
                ),
              ),
              4.verticalGap,
              AppText(
                value,
                style: Get.bodyMedium.px12.w600.copyWith(
                  color:
                      Get.bodyMedium.color ??
                      (Get.isDark ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CropDetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const CropDetailSection({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16.st,
                color: Get.disabledColor.withValues(alpha: 0.7),
              ),
              10.horizontalGap,
              Expanded(
                child: AppText(
                  title,
                  style: Get.bodyMedium.px14.w600.copyWith(
                    color:
                        Get.bodyMedium.color ??
                        (Get.isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
            ],
          ),
          8.verticalGap,
          AppText(
            content,
            style: Get.bodyMedium.px12.copyWith(
              color:
                  Get.bodyMedium.color ??
                  (Get.isDark ? Colors.white70 : Colors.black87),
              height: 1.6,
            ),
            maxLines: 100,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}
