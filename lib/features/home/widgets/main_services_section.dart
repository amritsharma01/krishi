import 'package:flutter/material.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/notices_page.dart';
import 'package:krishi/features/resources/programs_page.dart';
import 'package:krishi/features/soil_testing/soil_testing_page.dart';

class MainServicesSection extends StatelessWidget {
  const MainServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          overflow: TextOverflow.ellipsis,
          'main_services'.tr(context),
          style: Get.bodyLarge.px14.w600.copyWith(color: Get.disabledColor),
        ),
        5.verticalGap,
        _MainServiceCard(
          titleKey: 'soil_testing',
          descriptionKey: 'test_soil_quality',
          icon: Icons.science_rounded,
          onTap: () => Get.to(const SoilTestingPage()),
        ),
        5.verticalGap,
        _MainServiceCard(
          titleKey: 'notices',
          descriptionKey: 'important_announcements',
          icon: Icons.notifications_active_rounded,
          onTap: () => Get.to(const NoticesPage()),
        ),
        5.verticalGap,
        _MainServiceCard(
          titleKey: 'programs',
          descriptionKey: 'agricultural_development_programs',
          icon: Icons.agriculture_rounded,
          onTap: () => Get.to(const ProgramsPage()),
        ),
      ],
    );
  }
}

class _MainServiceCard extends StatelessWidget {
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final VoidCallback onTap;

  const _MainServiceCard({
    required this.titleKey,
    required this.descriptionKey,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8).rt,
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
                blurRadius: 8,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10).rt,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20.st),
              ),
              16.horizontalGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      titleKey.tr(context),
                      style: Get.bodyLarge.px12.w700.copyWith(
                        color: Get.disabledColor,
                      ),
                    ),
                    AppText(
                      descriptionKey.tr(context),
                      style: Get.bodySmall.px10.w500.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.65),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primary.withValues(alpha: 0.5),
                size: 16.st,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
