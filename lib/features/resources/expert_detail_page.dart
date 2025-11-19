import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpertDetailPage extends StatelessWidget {
  final Expert expert;

  const ExpertDetailPage({super.key, required this.expert});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    if (email.isEmpty) return;
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.indigo.shade700;

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          expert.name,
          style: Get.bodyLarge.px20.w700.copyWith(color: Colors.white),
        ),
        backgroundColor: color,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.rt),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(color),
            20.verticalGap,
            _buildInfoSection(),
            20.verticalGap,
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Color color) {
    return Container(
      padding: EdgeInsets.all(16.rt),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.85)],
        ),
        borderRadius: BorderRadius.circular(16).rt,
      ),
      child: Row(
        children: [
          Container(
            width: 90.w,
            height: 90.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipOval(
              child: expert.photo != null && expert.photo!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: expert.photo!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 40.st,
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 40.st,
                    ),
            ),
          ),
          16.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  expert.name,
                  style: Get.bodyLarge.px22.w700.copyWith(color: Colors.white),
                ),
                6.verticalGap,
                AppText(
                  expert.specialization,
                  style: Get.bodyMedium.px14.w600.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: EdgeInsets.all(16.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            Icons.school_rounded,
            'Qualifications',
            expert.qualifications,
          ),
          12.verticalGap,
          _buildInfoRow(
            Icons.location_on_rounded,
            'Office',
            expert.officeAddress,
          ),
          12.verticalGap,
          _buildInfoRow(
            Icons.calendar_month_rounded,
            'Available Days',
            expert.availableDays,
          ),
          12.verticalGap,
          _buildInfoRow(
            Icons.access_time_filled_rounded,
            'Available Hours',
            expert.availableHours,
          ),
          12.verticalGap,
          _buildInfoRow(
            Icons.payments_rounded,
            'Consultation Fee',
            expert.consultationFee,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.rt),
          decoration: BoxDecoration(
            color: Get.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10).rt,
          ),
          child: Icon(icon, size: 18.st, color: Get.primaryColor),
        ),
        12.horizontalGap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                label,
                style: Get.bodySmall.px12.w600.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.7),
                ),
              ),
              4.verticalGap,
              AppText(
                value,
                style: Get.bodyMedium.px14.w600.copyWith(
                  color: Get.disabledColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _makePhoneCall(expert.phoneNumber),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12).rt,
              ),
            ),
            icon: const Icon(Icons.phone_rounded),
            label: AppText(
              'Call',
              style: Get.bodyMedium.w600.copyWith(color: Colors.white),
            ),
          ),
        ),
        if (expert.email.isNotEmpty) ...[
          12.horizontalGap,
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _sendEmail(expert.email),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12).rt,
                ),
              ),
              icon: const Icon(Icons.email_rounded),
              label: AppText(
                'Email',
                style: Get.bodyMedium.w600.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
