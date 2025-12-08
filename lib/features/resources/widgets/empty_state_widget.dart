import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80.st,
            color: Colors.grey.shade400,
          ),
          16.verticalGap,
          AppText(
            title,
            style: Get.bodyLarge.px18.w600.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          if (subtitle != null) ...[
            8.verticalGap,
            AppText(
              subtitle!,
              style: Get.bodyMedium.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }
}

