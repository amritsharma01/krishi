import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';
import 'package:url_launcher/url_launcher.dart';

class UserManualDetailPage extends StatelessWidget {
  final UserManual manual;

  const UserManualDetailPage({super.key, required this.manual});

  Color _getCategoryColor() {
    switch (manual.category) {
      case 'buying':
        return Colors.blue;
      case 'selling':
        return Colors.green;
      case 'account':
        return Colors.purple;
      case 'orders':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    switch (manual.category) {
      case 'buying':
        return Icons.shopping_cart_rounded;
      case 'selling':
        return Icons.store_rounded;
      case 'account':
        return Icons.person_rounded;
      case 'orders':
        return Icons.receipt_long_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Future<void> _openVideo(BuildContext context, String url) async {
    try {
      String videoUrl = url.trim();
      
      if (videoUrl.isEmpty) {
        Get.snackbar('video_url_empty'.tr(context));
        return;
      }
      
      if (!videoUrl.startsWith('http://') && !videoUrl.startsWith('https://')) {
        if (videoUrl.length == 11 && RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(videoUrl)) {
          videoUrl = 'https://www.youtube.com/watch?v=$videoUrl';
        } else {
          videoUrl = 'https://$videoUrl';
        }
      }
      
      if (videoUrl.contains('youtu.be/')) {
        final parts = videoUrl.split('youtu.be/');
        if (parts.length > 1) {
          final videoId = parts[1].split('?').first.split('&').first;
          videoUrl = 'https://www.youtube.com/watch?v=$videoId';
        }
      }
      
      String? videoId;
      if (videoUrl.contains('youtube.com/watch?v=')) {
        final match = RegExp(r'[?&]v=([a-zA-Z0-9_-]{11})').firstMatch(videoUrl);
        videoId = match?.group(1);
      } else if (videoUrl.contains('youtube.com/embed/')) {
        final match = RegExp(r'/embed/([a-zA-Z0-9_-]{11})').firstMatch(videoUrl);
        videoId = match?.group(1);
      }
      
      if (videoId != null && videoId.isNotEmpty) {
        videoUrl = 'https://www.youtube.com/watch?v=$videoId';
      }
      
      if (!videoUrl.contains('youtube.com') && !videoUrl.contains('youtu.be')) {
        Get.snackbar('invalid_video_url'.tr(context));
        return;
      }
      
      final uri = Uri.parse(videoUrl);
      
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e2) {
          try {
            await launchUrl(uri, mode: LaunchMode.inAppWebView);
          } catch (e3) {
            Get.snackbar('could_not_open_video'.tr(context));
          }
        }
      }
    } catch (e) {
      Get.snackbar('error_opening_video'.tr(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor();
    final icon = _getCategoryIcon();

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'user_guide'.tr(context),
          style: Get.bodyLarge.px18.w600.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Get.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.rt),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, color, icon),
            if (manual.image != null && manual.image!.trim().isNotEmpty) ...[
              20.verticalGap,
              _buildImage(),
            ],
            20.verticalGap,
            _buildContent(),
            if (manual.videoUrl != null && manual.videoUrl!.trim().isNotEmpty) ...[
              20.verticalGap,
              _buildVideoButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(20.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
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
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(14).rt,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 15.st),
                    6.horizontalGap,
                    AppText(
                      manual.categoryDisplay,
                      style: Get.bodySmall.px12.w700.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          16.verticalGap,
          AppText(
            manual.title,
            style: Get.bodyLarge.px20.w700.copyWith(
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

  Widget _buildImage() {
    final imageUrl = Get.imageUrl(manual.image!);
    
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
            child: const Center(child: CircularProgressIndicator()),
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

  Widget _buildContent() {
    return Container(
      padding: EdgeInsets.all(18.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.1)),
      ),
      child: AppText(
        manual.content,
        style: Get.bodyMedium.px14.copyWith(
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

  Widget _buildVideoButton(BuildContext context) {
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
          onPressed: () => _openVideo(context, manual.videoUrl!),
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

