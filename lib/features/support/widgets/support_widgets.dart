import 'package:flutter/material.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';

class SupportHeader extends StatelessWidget {
  const SupportHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: AppColors.primary,
              size: 48.st,
            ),
          ),
          16.verticalGap,
          AppText(
            'how_can_we_help'.tr(context),
            style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SupportOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const SupportOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(16).rt,
          border: Border.all(
            color: Get.disabledColor.withValues(alpha: 0.08),
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
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12).rt,
              ),
              child: Icon(icon, color: AppColors.white, size: 24.st),
            ),
            16.horizontalGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title.tr(context),
                    style: Get.bodyMedium.px12.w700.copyWith(
                      color: Get.disabledColor,
                    ),
                  ),

                  AppText(
                    subtitle.tr(context),
                    style: Get.bodySmall.px10.w500.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Get.disabledColor.withValues(alpha: 0.3),
              size: 18.st,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickContactInfo extends StatelessWidget {
  const QuickContactInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(
          color: Get.disabledColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'quick_contact'.tr(context),
            style: Get.bodyMedium.px16.w700.copyWith(color: Get.disabledColor),
          ),
          6.verticalGap,
          QuickContactRow(
            icon: Icons.email_rounded,
            text: 'support@krishi.com',
          ),
          6.verticalGap,
          QuickContactRow(icon: Icons.phone_rounded, text: '+977 9800000000'),
          6.verticalGap,
          QuickContactRow(
            icon: Icons.access_time_rounded,
            text: 'Mon - Fri, 9:00 AM - 5:00 PM',
          ),
        ],
      ),
    );
  }
}

class QuickContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const QuickContactRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20.st),
        12.horizontalGap,
        Expanded(
          child: AppText(
            text,
            style: Get.bodyMedium.px12.w500.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}
