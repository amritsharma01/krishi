import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
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

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Could not open PDF');
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
          'Notice Details',
          style: Get.bodyLarge.px24.w600.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Get.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.rt),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [typeColor, typeColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.rt),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12).rt,
                        ),
                        child: Icon(
                          typeIcon,
                          color: Colors.white,
                          size: 28.st,
                        ),
                      ),
                      12.horizontalGap,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(6).rt,
                              ),
                              child: AppText(
                                notice.noticeTypeDisplay.toUpperCase(),
                                style: Get.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            6.verticalGap,
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14.st,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                6.horizontalGap,
                                AppText(
                                  DateFormat('MMMM dd, yyyy')
                                      .format(notice.publishedDate),
                                  style: Get.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  16.verticalGap,
                  AppText(
                    notice.title,
                    style: Get.bodyLarge.px22.w700.copyWith(
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(20.rt),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  AppText(
                    notice.description,
                    style: Get.bodyLarge.copyWith(
                      color: Colors.grey.shade800,
                      height: 1.6,
                    ),
                  ),

                  // Image
                  if (notice.image != null) ...[
                    24.verticalGap,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16).rt,
                      child: CachedNetworkImage(
                        imageUrl: notice.image!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200.h,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200.h,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ],

                  // PDF Button
                  if (notice.pdfFile != null) ...[
                    24.verticalGap,
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade600, Colors.red.shade700],
                        ),
                        borderRadius: BorderRadius.circular(12).rt,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _openPdf(notice.pdfFile!),
                          borderRadius: BorderRadius.circular(12).rt,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: Colors.white,
                                  size: 24.st,
                                ),
                                12.horizontalGap,
                                AppText(
                                  'Open PDF Document',
                                  style: Get.bodyLarge.w600.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Posted by
                  24.verticalGap,
                  Container(
                    padding: EdgeInsets.all(16.rt),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12).rt,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Get.primaryColor,
                          size: 24.st,
                        ),
                        12.horizontalGap,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                'Posted By',
                                style: Get.bodySmall.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              4.verticalGap,
                              AppText(
                                notice.createdByEmail,
                                style: Get.bodyMedium.w600,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
