import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/widgets/detail/notice_detail_widgets.dart';
import 'package:krishi/models/resources.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticeDetailPage extends StatelessWidget {
  final Notice notice;

  const NoticeDetailPage({super.key, required this.notice});

  Color _getNoticeTypeColor(String type) {
    switch (type) {
      case 'urgent':
        return Colors.red;
      case 'important':
        return Colors.orange;
      case 'event':
        return Colors.blue;
      case 'training':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getNoticeTypeIcon(String type) {
    switch (type) {
      case 'urgent':
        return Icons.warning_amber_rounded;
      case 'important':
        return Icons.info_rounded;
      case 'event':
        return Icons.event_rounded;
      case 'training':
        return Icons.school_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  Future<void> _openPdf(BuildContext context, String url) async {
    try {
      // Process the URL to ensure it's a full URL
      String pdfUrl = url.trim();

      // If URL is empty, return early
      if (pdfUrl.isEmpty) {
        Get.snackbar('could_not_open_pdf'.tr(context), color: Colors.red);
        return;
      }

      // If URL is relative, construct full URL
      if (!pdfUrl.startsWith('http://') && !pdfUrl.startsWith('https://')) {
        pdfUrl = Get.imageUrl(pdfUrl);
      } else {
        // Use Get.imageUrl to handle localhost URLs properly
        pdfUrl = Get.imageUrl(pdfUrl);
      }

      final uri = Uri.parse(pdfUrl);

      // Try multiple launch modes
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e2) {
          try {
            await launchUrl(uri, mode: LaunchMode.inAppWebView);
          } catch (e3) {
            Get.snackbar('could_not_open_pdf'.tr(context), color: Colors.red);
          }
        }
      }
    } catch (e) {
      Get.snackbar('could_not_open_pdf'.tr(context), color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getNoticeTypeColor(notice.noticeType);
    final typeIcon = _getNoticeTypeIcon(notice.noticeType);

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'notice_details'.tr(context),
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
            NoticeDetailHeader(
              notice: notice,
              typeColor: typeColor,
              typeIcon: typeIcon,
            ),
            if (notice.image != null && notice.image!.trim().isNotEmpty) ...[
              20.verticalGap,
              NoticeDetailImage(imageUrl: Get.imageUrl(notice.image!)),
            ],
            10.verticalGap,
            NoticeDetailDescription(description: notice.description),
            if (notice.pdfFile != null &&
                notice.pdfFile!.trim().isNotEmpty) ...[
              10.verticalGap,
              NoticePdfButton(
                pdfUrl: notice.pdfFile!,
                onOpenPdf: (url) => _openPdf(context, url),
              ),
            ],
            if (notice.createdByEmail.isNotEmpty) ...[
              10.verticalGap,
              NoticePostedBy(email: notice.createdByEmail),
            ],
          ],
        ),
      ),
    );
  }
}
