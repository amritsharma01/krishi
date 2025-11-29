import 'package:flutter/material.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';

class ErrorState extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback onRetry;
  final IconData icon;
  final Color? iconColor;

  const ErrorState({
    super.key,
    this.title,
    this.subtitle,
    required this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32).rt,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32).rt,
              decoration: BoxDecoration(
                color: Get.cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (iconColor ?? Colors.orange)
                        .withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 80.st,
                color: iconColor ?? Colors.orange,
              ),
            ),
            24.verticalGap,
            AppText(
              title ?? 'problem_fetching_data'.tr(context),
              style: Get.bodyLarge.px20.w700.copyWith(
                color: Get.disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              12.verticalGap,
              AppText(
                maxLines: 2,
                subtitle!,
                style: Get.bodyMedium.px14.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            32.verticalGap,
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ).rt,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12).rt,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: AppColors.white,
                      size: 20.st,
                    ),
                    10.horizontalGap,
                    AppText(
                      'retry'.tr(context),
                      style: Get.bodyMedium.px15.w700.copyWith(
                        color: AppColors.white,
                      ),
                    ),
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

