import 'package:flutter/material.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
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
                    color: (iconColor ?? AppColors.primary).withValues(
                      alpha: 0.1,
                    ),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 80.st,
                color: iconColor ?? AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            24.verticalGap,
            AppText(
              title,
              style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              12.verticalGap,
              AppText(
                maxLines: 3,
                subtitle!,
                style: Get.bodyMedium.px12.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
