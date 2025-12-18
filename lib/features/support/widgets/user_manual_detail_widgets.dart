import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';

class UserManualDetailHeader extends StatelessWidget {
  final UserManual manual;
  final IconData icon;

  const UserManualDetailHeader({
    super.key,
    required this.manual,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14).rt,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: AppColors.primary, size: 15.st),
                    6.horizontalGap,
                    AppText(
                      manual.categoryDisplay,
                      style: Get.bodySmall.px12.w700.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          6.verticalGap,
          AppText(
            manual.title,
            style: Get.bodyLarge.px14.w700.copyWith(
              color:
                  Get.bodyLarge.color ??
                  (Get.isDark ? Colors.white : Colors.black87),
              height: 1.4,
            ),
            maxLines: 10,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}

class UserManualDetailImage extends StatelessWidget {
  final String imageUrl;

  const UserManualDetailImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16).rt,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 220.h,
            decoration: BoxDecoration(
              color: Get.cardColor.withValues(alpha: Get.isDark ? 0.3 : 0.7),
              borderRadius: BorderRadius.circular(16).rt,
            ),
            child: const Center(child: CircularProgressIndicator.adaptive()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 220.h,
            decoration: BoxDecoration(
              color: Get.cardColor.withValues(alpha: Get.isDark ? 0.3 : 0.7),
              borderRadius: BorderRadius.circular(16).rt,
            ),
            child: Icon(
              Icons.image_not_supported,
              color: Get.disabledColor,
              size: 32.st,
            ),
          ),
        ),
      ),
    );
  }
}

class UserManualDetailContent extends StatelessWidget {
  final String content;

  const UserManualDetailContent({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.1)),
      ),
      child: AppText(
        content,
        style: Get.bodyMedium.px12.copyWith(
          color:
              Get.bodyMedium.color ??
              (Get.isDark ? Colors.white70 : Colors.black87),
          height: 1.7,
        ),
        maxLines: 100,
        overflow: TextOverflow.visible,
      ),
    );
  }
}

class UserManualVideoButton extends StatelessWidget {
  final String videoUrl;
  final Future<void> Function(String) onOpenVideo;

  const UserManualVideoButton({
    super.key,
    required this.videoUrl,
    required this.onOpenVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade600.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => onOpenVideo(videoUrl),
          icon: Icon(Icons.play_circle_outline_rounded, size: 20.st),
          label: AppText(
            'watch_video'.tr(context),
            style: Get.bodyMedium.px15.w600.copyWith(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14).rt,
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
