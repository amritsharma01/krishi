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
            expandedHeight: 280.h,
            pinned: true,
            backgroundColor: color,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: AppText(
                crop.cropName,
                style: Get.bodyLarge.px18.w700.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              background: crop.image != null && crop.image!.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: crop.image!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: color.withValues(alpha: 0.1),
                            child: Center(
                              child: CircularProgressIndicator(color: color),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  color.withValues(alpha: 0.7),
                                  color,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(icon, size: 100.st, color: Colors.white),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withValues(alpha: 0.7), color],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(icon, size: 100.st, color: Colors.white),
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
                  // Type Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8).rt,
                    ),
                    child: AppText(
                      crop.cropTypeDisplay.toUpperCase(),
                      style: Get.bodySmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  24.verticalGap,

                  // Duration Card
                  _buildInfoCard(
                    context,
                    icon: Icons.schedule_rounded,
                    title: 'growing_duration'.tr(context),
                    content: '${crop.durationDays} days',
                    color: Colors.blue,
                  ),

                  16.verticalGap,

                  // Planting Season
                  _buildInfoCard(
                    context,
                    icon: Icons.wb_sunny_rounded,
                    title: 'planting_season'.tr(context),
                    content: crop.plantingSeason,
                    color: Colors.orange,
                  ),

                  16.verticalGap,

                  // Harvesting Season
                  _buildInfoCard(
                    context,
                    icon: Icons.agriculture_rounded,
                    title: 'harvesting_season'.tr(context),
                    content: crop.harvestingSeason,
                    color: Colors.green,
                  ),

                  24.verticalGap,

                  // Detailed Information
                  _buildDetailSection(
                    context,
                    icon: Icons.thermostat_rounded,
                    title: 'climate_requirement'.tr(context),
                    content: crop.climateRequirement,
                    color: Colors.red,
                  ),

                  16.verticalGap,

                  _buildDetailSection(
                    context,
                    icon: Icons.landscape_rounded,
                    title: 'soil_type'.tr(context),
                    content: crop.soilType,
                    color: Colors.brown,
                  ),

                  16.verticalGap,

                  _buildDetailSection(
                    context,
                    icon: Icons.water_drop_rounded,
                    title: 'water_requirement'.tr(context),
                    content: crop.waterRequirement,
                    color: Colors.cyan,
                  ),

                  16.verticalGap,

                  _buildDetailSection(
                    context,
                    icon: Icons.checklist_rounded,
                    title: 'best_practices'.tr(context),
                    content: crop.bestPractices,
                    color: Colors.green,
                  ),

                  16.verticalGap,

                  _buildDetailSection(
                    context,
                    icon: Icons.bug_report_rounded,
                    title: 'common_pests_diseases'.tr(context),
                    content: crop.commonPests,
                    color: Colors.deepOrange,
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

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.rt),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.rt),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10).rt,
            ),
            child: Icon(icon, color: color, size: 24.st),
          ),
          16.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: Get.bodySmall.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                4.verticalGap,
                AppText(
                  content,
                  style: Get.bodyLarge.w600.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.rt),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.rt),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8).rt,
                ),
                child: Icon(icon, color: color, size: 20.st),
              ),
              12.horizontalGap,
              Expanded(
                child: AppText(
                  title,
                  style: Get.bodyLarge.w600,
                ),
              ),
            ],
          ),
          12.verticalGap,
          AppText(
            content,
            style: Get.bodyMedium.copyWith(
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
