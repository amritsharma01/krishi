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

class CropDetailPage extends StatelessWidget {
  final CropCalendar crop;

  const CropDetailPage({super.key, required this.crop});

  Color _getCropColor() {
    switch (crop.cropType) {
      case 'cereal':
        return Colors.amber;
      case 'vegetable':
        return Colors.green;
      case 'fruit':
        return Colors.red;
      case 'pulses':
        return Colors.brown;
      case 'cash_crop':
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }

  IconData _getCropIcon() {
    switch (crop.cropType) {
      case 'cereal':
        return Icons.grain_rounded;
      case 'vegetable':
        return Icons.eco_rounded;
      case 'fruit':
        return Icons.apple_rounded;
      case 'pulses':
        return Icons.spa_rounded;
      case 'cash_crop':
        return Icons.attach_money_rounded;
      default:
        return Icons.agriculture_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCropColor();
    final icon = _getCropIcon();

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
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
              stretchModes: const [
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
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
                              child: CircularProgressIndicator(color: color),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildPlaceholder(color, icon),
                        )
                      : _buildPlaceholder(color, icon),
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
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.rt),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Type Badge
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(
                            alpha: Get.isDark ? 0.15 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12).rt,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: color, size: 14.st),
                            6.horizontalGap,
                            AppText(
                              crop.cropTypeDisplay,
                              style: Get.bodySmall.px12.w600.copyWith(
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  12.verticalGap,
                  AppText(
                    crop.cropName,
                    style: Get.bodyLarge.px20.w700.copyWith(
                      color:
                          Get.bodyLarge.color ??
                          (Get.isDark ? Colors.white : Colors.black87),
                      height: 1.35,
                    ),
                    maxLines: 10,
                    overflow: TextOverflow.visible,
                  ),
                  20.verticalGap,
                  // Quick Info
                  _buildQuickInfo(context, color),
                  20.verticalGap,
                  // Detailed Information
                  _buildDetailSection(
                    context,
                    icon: Icons.thermostat_rounded,
                    title: 'climate_requirement'.tr(context),
                    content: crop.climateRequirement,
                  ),
                  16.verticalGap,
                  _buildDetailSection(
                    context,
                    icon: Icons.landscape_rounded,
                    title: 'soil_type'.tr(context),
                    content: crop.soilType,
                  ),
                  16.verticalGap,
                  _buildDetailSection(
                    context,
                    icon: Icons.water_drop_rounded,
                    title: 'water_requirement'.tr(context),
                    content: crop.waterRequirement,
                  ),
                  16.verticalGap,
                  _buildDetailSection(
                    context,
                    icon: Icons.checklist_rounded,
                    title: 'best_practices'.tr(context),
                    content: crop.bestPractices,
                  ),
                  16.verticalGap,
                  _buildDetailSection(
                    context,
                    icon: Icons.bug_report_rounded,
                    title: 'common_pests_diseases'.tr(context),
                    content: crop.commonPests,
                  ),
                  32.verticalGap,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(Color color, IconData icon) {
    return Container(
      color: color.withValues(alpha: 0.1),
      child: Center(
        child: Icon(icon, size: 80.st, color: color.withValues(alpha: 0.3)),
      ),
    );
  }

  Widget _buildQuickInfo(BuildContext context, Color color) {
    return Container(
      padding: EdgeInsets.all(16.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildQuickInfoRow(
            Icons.schedule_rounded,
            'growing_duration'.tr(context),
            '${crop.durationDays} days',
          ),
          12.verticalGap,
          Divider(color: Get.disabledColor.withValues(alpha: 0.1)),
          12.verticalGap,
          _buildQuickInfoRow(
            Icons.wb_sunny_rounded,
            'planting_season'.tr(context),
            crop.plantingSeason,
          ),
          12.verticalGap,
          Divider(color: Get.disabledColor.withValues(alpha: 0.1)),
          12.verticalGap,
          _buildQuickInfoRow(
            Icons.agriculture_rounded,
            'harvesting_season'.tr(context),
            crop.harvestingSeason,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoRow(IconData icon, String label, String value) {
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
                style: Get.bodySmall.px12.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.7),
                ),
              ),
              4.verticalGap,
              AppText(
                value,
                style: Get.bodyMedium.px14.w600.copyWith(
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

  Widget _buildDetailSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
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
                size: 18.st,
                color: Get.disabledColor.withValues(alpha: 0.7),
              ),
              10.horizontalGap,
              Expanded(
                child: AppText(
                  title,
                  style: Get.bodyMedium.px15.w600.copyWith(
                    color:
                        Get.bodyMedium.color ??
                        (Get.isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
            ],
          ),
          12.verticalGap,
          AppText(
            content,
            style: Get.bodyMedium.px14.copyWith(
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
