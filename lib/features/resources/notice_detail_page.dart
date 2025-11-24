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
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('could_not_open_pdf'.tr(context));
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
        padding: EdgeInsets.all(16.rt),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, typeColor, typeIcon),
            if (notice.image != null && notice.image!.isNotEmpty) ...[
              20.verticalGap,
              _buildImage(),
            ],
            20.verticalGap,
            _buildDescription(),
            if (notice.pdfFile != null) ...[
              20.verticalGap,
              _buildPdfButton(context),
            ],
            20.verticalGap,
            _buildPostedBy(context),
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
      padding: EdgeInsets.all(18.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(18).rt,
        border: Border.all(color: typeColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: Get.isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(20).rt,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(typeIcon, color: typeColor, size: 16.st),
                    6.horizontalGap,
                    AppText(
                      notice.noticeTypeDisplay,
                      style: Get.bodySmall.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(
                Icons.calendar_today_outlined,
                size: 14.st,
                color: Get.disabledColor.withValues(alpha: 0.7),
              ),
              6.horizontalGap,
              AppText(
                DateFormat('MMMM dd, yyyy').format(notice.publishedDate),
                style: Get.bodySmall.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          12.verticalGap,
          AppText(
            notice.title,
            style: Get.bodyLarge.px20.w700.copyWith(
              color:
                  Get.bodyLarge.color ??
                  (Get.isDark ? Colors.white : Colors.black87),
              height: 1.4,
            ),
          ),
          8.verticalGap,
          AppText(
            notice.createdByEmail,
            style: Get.bodySmall.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16).rt,
      child: CachedNetworkImage(
        imageUrl: notice.image!,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 210.h,
          color: Get.cardColor.withValues(alpha: Get.isDark ? 0.4 : 0.8),
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          height: 210.h,
          color: Get.cardColor.withValues(alpha: Get.isDark ? 0.4 : 0.8),
          child: Icon(
            Icons.image_not_supported,
            color: Get.disabledColor,
            size: 30.st,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return AppText(
      notice.description,
      style: Get.bodyLarge.copyWith(
        color:
            Get.bodyLarge.color ?? (Get.isDark ? Colors.white : Colors.black87),
        height: 1.65,
      ),
    );
  }

  Widget _buildPdfButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _openPdf(context, notice.pdfFile!),
      icon: Icon(Icons.picture_as_pdf_rounded, size: 20.st),
      label: AppText(
        'open_pdf_document'.tr(context),
        style: Get.bodyMedium.w600.copyWith(color: Colors.red.shade600),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        side: BorderSide(color: Colors.red.shade600, width: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12).rt,
        ),
      ),
    );
  }

  Widget _buildPostedBy(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.rt),
            decoration: BoxDecoration(
              color: Get.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12).rt,
            ),
            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: Get.primaryColor,
              size: 20.st,
            ),
          ),
          12.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'posted_by'.tr(context),
                  style: Get.bodySmall.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.7),
                  ),
                ),
                4.verticalGap,
                AppText(
                  notice.createdByEmail,
                  style: Get.bodyMedium.w600.copyWith(
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
