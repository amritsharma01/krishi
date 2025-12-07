import 'package:flutter/material.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/emergency_contacts_page.dart';
import 'package:krishi/features/resources/experts_page.dart';
import 'package:krishi/features/resources/service_providers_page.dart';

class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'services_directory'.tr(context),
          style: Get.bodyLarge.px14.w600.copyWith(color: Get.disabledColor),
        ),
        5.verticalGap,
        Row(
          children: [
            Expanded(
              child: _DirectoryCard(
                title: 'agri_experts',
                icon: Icons.people_rounded,
                color: const Color(0xFF00897B),
                onTap: () => Get.to(const ExpertsPage()),
              ),
            ),
            5.horizontalGap,
            Expanded(
              child: _DirectoryCard(
                title: 'service_providers',
                icon: Icons.business_rounded,
                color: const Color(0xFF1565C0),
                onTap: () => Get.to(const ServiceProvidersPage()),
              ),
            ),
            5.horizontalGap,
            Expanded(
              child: _DirectoryCard(
                title: 'emergency_contacts',
                icon: Icons.emergency_rounded,
                color: const Color(0xFFC62828),
                onTap: () => Get.to(const EmergencyContactsPage()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DirectoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DirectoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(14).rt,
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10).rt,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12).rt,
              ),
              child: Icon(icon, color: color, size: 28.st),
            ),
            3.verticalGap,
            AppText(
              title.tr(context),
              style: Get.bodySmall.px10.w600.copyWith(color: Get.disabledColor),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
