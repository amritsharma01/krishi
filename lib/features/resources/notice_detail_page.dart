import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
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
        padding: EdgeInsets.all(20.rt),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, typeColor, typeIcon),
            if (notice.image != null && notice.image!.trim().isNotEmpty) ...[
              20.verticalGap,
              _buildImage(),
            ],
            20.verticalGap,
            _buildDescription(),
            if (notice.pdfFile != null &&
                notice.pdfFile!.trim().isNotEmpty) ...[
              20.verticalGap,
              _buildPdfButton(context),
            ],
            if (notice.createdByEmail.isNotEmpty) ...[
              20.verticalGap,
              _buildPostedBy(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color typeColor,
    IconData typeIcon,
  ) {
    return Container(
      padding: EdgeInsets.all(20.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(color: typeColor.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: typeColor.withValues(alpha: 0.1),
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
                    colors: [typeColor, typeColor.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(14).rt,
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(typeIcon, color: Colors.white, size: 15.st),
                    6.horizontalGap,
                    AppText(
                      notice.noticeTypeDisplay,
                      style: Get.bodySmall.px12.w700.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Get.disabledColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10).rt,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13.st,
                      color: Get.disabledColor.withValues(alpha: 0.7),
                    ),
                    6.horizontalGap,
                    AppText(
                      DateFormat('MMM dd, yyyy').format(notice.publishedDate),
                      style: Get.bodySmall.px12.w500.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          16.verticalGap,
          AppText(
            notice.title,
            style: Get.bodyLarge.px18.w700.copyWith(
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
    final imageUrl = Get.imageUrl(notice.image!);

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

  Widget _buildDescription() {
    return Container(
      padding: EdgeInsets.all(18.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.1)),
      ),
      child: AppText(
        notice.description,
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

  Widget _buildPdfButton(BuildContext context) {
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
          onPressed: () => _openPdf(context, notice.pdfFile!),
          icon: Icon(Icons.picture_as_pdf_rounded, size: 20.st),
          label: AppText(
            'open_pdf_document'.tr(context),
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

  Widget _buildPostedBy(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.rt),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Get.primaryColor,
                  Get.primaryColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12).rt,
              boxShadow: [
                BoxShadow(
                  color: Get.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.person_rounded, size: 18.st, color: Colors.white),
          ),
          14.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'posted_by'.tr(context),
                  style: Get.bodySmall.px12.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                4.verticalGap,
                AppText(
                  notice.createdByEmail,
                  style: Get.bodyMedium.px14.w600.copyWith(
                    color:
                        Get.bodyMedium.color ??
                        (Get.isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
