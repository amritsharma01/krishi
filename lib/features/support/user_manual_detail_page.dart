import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/support/widgets/user_manual_detail_widgets.dart';
import 'package:krishi/models/resources.dart';
import 'package:url_launcher/url_launcher.dart';

class UserManualDetailPage extends StatelessWidget {
  final UserManual manual;

  const UserManualDetailPage({super.key, required this.manual});

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
        if (videoUrl.length == 11 &&
            RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(videoUrl)) {
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
        final match = RegExp(
          r'/embed/([a-zA-Z0-9_-]{11})',
        ).firstMatch(videoUrl);
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
        padding: EdgeInsets.all(10.rt),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserManualDetailHeader(manual: manual, icon: icon),
            if (manual.image != null && manual.image!.trim().isNotEmpty) ...[
              10.verticalGap,
              UserManualDetailImage(imageUrl: Get.imageUrl(manual.image!)),
            ],
            10.verticalGap,
            UserManualDetailContent(content: manual.content),
            if (manual.videoUrl != null &&
                manual.videoUrl!.trim().isNotEmpty) ...[
              20.verticalGap,
              UserManualVideoButton(
                videoUrl: manual.videoUrl!,
                onOpenVideo: (url) => _openVideo(context, url),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
