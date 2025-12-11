import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/services/get.dart';
import 'package:flutter/material.dart';
import 'app_text.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(12).rt,
          border: Border.all(color: Get.disabledColor.o1, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10).rt,
              decoration: BoxDecoration(
                color: (iconColor ?? Get.primaryColor).o1,
                borderRadius: BorderRadius.circular(10).rt,
              ),
              child: Icon(
                icon,
                color: iconColor ?? Get.primaryColor,
                size: 20.st,
              ),
            ),
            16.horizontalGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    style: Get.bodyMedium.px14.w600.copyWith(
                      color: Get.disabledColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    AppText(
                      subtitle!,
                      style: Get.bodySmall.px12.copyWith(
                        color: Get.disabledColor.o6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[12.horizontalGap, trailing!],
          ],
        ),
      ),
    );
  }
}
