import 'package:flutter/material.dart';
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
          style: Get.bodyLarge.px16.w600.copyWith(color: Get.disabledColor),
        ),
        7.verticalGap,
        _MainServiceCard(
          titleKey: 'soil_testing',
          descriptionKey: 'test_soil_quality',
          icon: Icons.science_rounded,
          accentColor: const Color(0xFF5E35B1),
          onTap: () => Get.to(const SoilTestingPage()),
        ),
        7.verticalGap,
        _MainServiceCard(
          titleKey: 'notices',
          descriptionKey: 'important_announcements',
          icon: Icons.notifications_active_rounded,
          accentColor: const Color(0xFFFF8F00),
          onTap: () => Get.to(const NoticesPage()),
        ),
        7.verticalGap,
        _MainServiceCard(
          titleKey: 'programs',
          descriptionKey: 'agricultural_development_programs',
          icon: Icons.agriculture_rounded,
          accentColor: const Color(0xFF2E7D32),
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
  final Color accentColor;
  final VoidCallback onTap;

  const _MainServiceCard({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(20).rt,
          border: Border.all(color: accentColor.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: accentColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10).rt,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: accentColor, size: 24.st),
            ),
            16.horizontalGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    titleKey.tr(context),
                    style: Get.bodyLarge.px14.w700.copyWith(
                      color: Get.disabledColor,
                    ),
                  ),
                  AppText(
                    descriptionKey.tr(context),
                    style: Get.bodySmall.px11.w500.copyWith(
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
              color: accentColor,
              size: 16.st,
            ),
          ],
        ),
      ),
    );
  }
}
