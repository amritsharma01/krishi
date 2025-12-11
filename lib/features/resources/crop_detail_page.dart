import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/widgets/detail/crop_detail_widgets.dart';
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
          CropDetailHeader(crop: crop, color: color, icon: icon),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(10.rt),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CropDetailTitle(crop: crop, color: color, icon: icon),
                  10.verticalGap,
                  CropQuickInfo(crop: crop),
                  6.verticalGap,
                  CropDetailSection(
                    icon: Icons.thermostat_rounded,
                    title: 'climate_requirement'.tr(context),
                    content: crop.climateRequirement,
                  ),
                  6.verticalGap,
                  CropDetailSection(
                    icon: Icons.landscape_rounded,
                    title: 'soil_type'.tr(context),
                    content: crop.soilType,
                  ),
                  6.verticalGap,
                  CropDetailSection(
                    icon: Icons.water_drop_rounded,
                    title: 'water_requirement'.tr(context),
                    content: crop.waterRequirement,
                  ),
                  6.verticalGap,
                  CropDetailSection(
                    icon: Icons.checklist_rounded,
                    title: 'best_practices'.tr(context),
                    content: crop.bestPractices,
                  ),
                  6.verticalGap,
                  CropDetailSection(
                    icon: Icons.bug_report_rounded,
                    title: 'common_pests_diseases'.tr(context),
                    content: crop.commonPests,
                  ),
                  6.verticalGap,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
