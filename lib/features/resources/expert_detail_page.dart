import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpertDetailPage extends StatelessWidget {
  final Expert expert;

  const ExpertDetailPage({super.key, required this.expert});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'expert_details'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Colors.white),
        ),
        backgroundColor: Get.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with photo and basic info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24).rt,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Get.primaryColor,
                    Get.primaryColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Photo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: expert.photo != null && expert.photo!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              expert.photo!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 60.st,
                                    color: Get.primaryColor,
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 60.st,
                              color: Get.primaryColor,
                            ),
                          ),
                  ),
                  16.verticalGap,
                  AppText(
                    expert.name,
                    style: Get.bodyLarge.px22.w700.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  8.verticalGap,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ).rt,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8).rt,
                    ),
                    child: AppText(
                      expert.specialization,
                      style: Get.bodyMedium.px15.w600.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20).rt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Qualifications
                  AppText(
                    'qualifications'.tr(context),
                    style: Get.bodyLarge.px18.w700,
                  ),
                  12.verticalGap,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16).rt,
                    decoration: BoxDecoration(
                      color: Get.cardColor,
                      borderRadius: BorderRadius.circular(12).rt,
                    ),
                    child: AppText(
                      expert.qualifications,
                      style: Get.bodyMedium.px14.w400.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ),
                  24.verticalGap,

                  // Contact Information
                  AppText(
                    'contact_information'.tr(context),
                    style: Get.bodyLarge.px18.w700,
                  ),
                  16.verticalGap,

                  // Phone
                  _buildContactCard(
                    icon: Icons.phone_rounded,
                    iconColor: Colors.green,
                    title: 'phone_number'.tr(context),
                    value: expert.phoneNumber,
                    onTap: () => _makePhoneCall(expert.phoneNumber),
                  ),
                  12.verticalGap,

                  // Email
                  if (expert.email.isNotEmpty) ...[
                    _buildContactCard(
                      icon: Icons.email_rounded,
                      iconColor: Colors.blue,
                      title: 'email'.tr(context),
                      value: expert.email,
                      onTap: () => _sendEmail(expert.email),
                    ),
                    12.verticalGap,
                  ],

                  // Office Address
                  _buildInfoCard(
                    icon: Icons.location_on_rounded,
                    iconColor: Colors.red,
                    title: 'office_address'.tr(context),
                    value: expert.officeAddress,
                  ),
                  24.verticalGap,

                  // Availability
                  AppText(
                    'availability'.tr(context),
                    style: Get.bodyLarge.px18.w700,
                  ),
                  16.verticalGap,
                  Container(
                    padding: const EdgeInsets.all(16).rt,
                    decoration: BoxDecoration(
                      color: Get.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12).rt,
                      border: Border.all(
                        color: Get.primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: Get.primaryColor,
                              size: 20.st,
                            ),
                            12.horizontalGap,
                            Expanded(
                              child: AppText(
                                expert.availableDays,
                                style: Get.bodyMedium.px14.w500,
                              ),
                            ),
                          ],
                        ),
                        12.verticalGap,
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: Get.primaryColor,
                              size: 20.st,
                            ),
                            12.horizontalGap,
                            Expanded(
                              child: AppText(
                                expert.availableHours,
                                style: Get.bodyMedium.px14.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  24.verticalGap,

                  // Consultation Fee
                  AppText(
                    'consultation_fee'.tr(context),
                    style: Get.bodyLarge.px18.w700,
                  ),
                  12.verticalGap,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16).rt,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12).rt,
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.monetization_on_rounded,
                          color: Colors.green,
                          size: 24.st,
                        ),
                        12.horizontalGap,
                        Expanded(
                          child: AppText(
                            expert.consultationFee,
                            style: Get.bodyMedium.px14.w600.copyWith(
                              color: Colors.green.shade700,
                            ),
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

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12).rt,
      child: Container(
        padding: const EdgeInsets.all(16).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(12).rt,
          border: Border.all(
            color: iconColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10).rt,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10).rt,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24.st,
              ),
            ),
            16.horizontalGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    style: Get.bodySmall.px12.w600.copyWith(
                      color: Get.disabledColor,
                    ),
                  ),
                  4.verticalGap,
                  AppText(
                    value,
                    style: Get.bodyMedium.px14.w600,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              color: iconColor,
              size: 20.st,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(12).rt,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10).rt,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10).rt,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24.st,
            ),
          ),
          16.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: Get.bodySmall.px12.w600.copyWith(
                    color: Get.theme.hintColor,
                  ),
                ),
                6.verticalGap,
                AppText(
                  value,
                  style: Get.bodyMedium.px14.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

