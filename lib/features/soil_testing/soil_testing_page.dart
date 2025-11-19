import 'package:flutter/material.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';

class SoilTestingPage extends StatefulWidget {
  const SoilTestingPage({super.key});

  @override
  State<SoilTestingPage> createState() => _SoilTestingPageState();
}

class _SoilTestingPageState extends State<SoilTestingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.disabledColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: AppText(
          'soil_testing'.tr(context),
          style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16).rt,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image/Icon
            Container(
              width: double.infinity,
              height: 200.rt,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20).rt,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5E35B1).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.science_rounded,
                  size: 100.st,
                  color: AppColors.white,
                ),
              ),
            ),

            24.verticalGap,

            // Title
            AppText(
              'soil_testing_title'.tr(context),
              style: Get.bodyLarge.px24.w800.copyWith(
                color: Get.disabledColor,
              ),
            ),

            12.verticalGap,

            // Description
            AppText(
              'soil_testing_description'.tr(context),
              style: Get.bodyMedium.px15.w400.copyWith(
                color: Get.disabledColor.withValues(alpha: 0.7),
                height: 1.6,
              ),
            ),

            32.verticalGap,

            // Features
            AppText(
              'soil_testing_features'.tr(context),
              style: Get.bodyLarge.px18.w700.copyWith(
                color: Get.disabledColor,
              ),
            ),

            16.verticalGap,

            _buildFeatureCard(
              icon: Icons.water_drop_rounded,
              title: 'ph_level',
              description: 'ph_level_description',
              color: Colors.blue,
            ),

            12.verticalGap,

            _buildFeatureCard(
              icon: Icons.grass_rounded,
              title: 'nutrients',
              description: 'nutrients_description',
              color: Colors.green,
            ),

            12.verticalGap,

            _buildFeatureCard(
              icon: Icons.opacity_rounded,
              title: 'moisture',
              description: 'moisture_description',
              color: Colors.cyan,
            ),

            12.verticalGap,

            _buildFeatureCard(
              icon: Icons.psychology_rounded,
              title: 'recommendations',
              description: 'recommendations_description',
              color: Colors.orange,
            ),

            32.verticalGap,

            // CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: AppText(
                        'soil_testing_coming_soon'.tr(context),
                        style: Get.bodyMedium.w600.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12).rt,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E35B1),
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.rt),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12).rt,
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF5E35B1).withValues(alpha: 0.4),
                ),
                child: AppText(
                  'start_soil_test'.tr(context),
                  style: Get.bodyMedium.px16.w700.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),

            20.verticalGap,
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12).rt,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12).rt,
            ),
            child: Icon(
              icon,
              size: 24.st,
              color: color,
            ),
          ),
          16.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title.tr(context),
                  style: Get.bodyMedium.px15.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                4.verticalGap,
                AppText(
                  description.tr(context),
                  style: Get.bodySmall.px13.w400.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

