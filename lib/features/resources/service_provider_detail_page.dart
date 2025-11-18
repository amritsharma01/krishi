import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceProviderDetailPage extends StatelessWidget {
  final ServiceProvider provider;

  const ServiceProviderDetailPage({super.key, required this.provider});

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

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'seeds':
        return Colors.green;
      case 'fertilizer':
        return Colors.brown;
      case 'pesticide':
        return Colors.red;
      case 'equipment':
        return Colors.orange;
      case 'veterinary':
        return Colors.blue;
      case 'transport':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'seeds':
        return Icons.spa_rounded;
      case 'fertilizer':
        return Icons.science_rounded;
      case 'pesticide':
        return Icons.bug_report_rounded;
      case 'equipment':
        return Icons.construction_rounded;
      case 'veterinary':
        return Icons.pets_rounded;
      case 'transport':
        return Icons.local_shipping_rounded;
      default:
        return Icons.store_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(provider.serviceType);
    final typeIcon = _getTypeIcon(provider.serviceType);

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'provider_details'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Colors.white),
        ),
        backgroundColor: Get.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24).rt,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    typeColor,
                    typeColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20).rt,
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
                    child: Icon(
                      typeIcon,
                      size: 48.st,
                      color: typeColor,
                    ),
                  ),
                  16.verticalGap,
                  AppText(
                    provider.businessName,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          typeIcon,
                          color: Colors.white,
                          size: 18.st,
                        ),
                        8.horizontalGap,
                        AppText(
                          provider.serviceTypeDisplay,
                          style: Get.bodyMedium.px15.w600.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (provider.deliveryAvailable) ...[
                    8.verticalGap,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ).rt,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6).rt,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_shipping_rounded,
                            color: Colors.white,
                            size: 16.st,
                          ),
                          6.horizontalGap,
                          AppText(
                            'delivery_available'.tr(context),
                            style: Get.bodySmall.px13.w600.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20).rt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  AppText(
                    'about'.tr(context),
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
                      provider.description,
                      style: Get.bodyMedium.px14.w400.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ),
                  24.verticalGap,

                  // Contact Person
                  AppText(
                    'contact_person'.tr(context),
                    style: Get.bodyLarge.px18.w700,
                  ),
                  12.verticalGap,
                  Container(
                    padding: const EdgeInsets.all(16).rt,
                    decoration: BoxDecoration(
                      color: Get.cardColor,
                      borderRadius: BorderRadius.circular(12).rt,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10).rt,
                          decoration: BoxDecoration(
                            color: Get.primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10).rt,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: Get.primaryColor,
                            size: 24.st,
                          ),
                        ),
                        16.horizontalGap,
                        Expanded(
                          child: AppText(
                            provider.contactPerson,
                            style: Get.bodyLarge.px16.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.verticalGap,

                  // Contact Information
                  AppText(
                    'contact_information'.tr(context),
                    style: Get.bodyLarge.px18.w700,
                  ),
                  16.verticalGap,

                  // Primary Phone
                  _buildContactCard(
                    icon: Icons.phone_rounded,
                    iconColor: Colors.green,
                    title: 'phone_number'.tr(context),
                    value: provider.phoneNumber,
                    onTap: () => _makePhoneCall(provider.phoneNumber),
                  ),
                  12.verticalGap,

                  // Alternate Phone
                  if (provider.alternatePhone.isNotEmpty) ...[
                    _buildContactCard(
                      icon: Icons.phone_android_rounded,
                      iconColor: Colors.teal,
                      title: 'alternate_phone'.tr(context),
                      value: provider.alternatePhone,
                      onTap: () => _makePhoneCall(provider.alternatePhone),
                    ),
                    12.verticalGap,
                  ],

                  // Email
                  if (provider.email.isNotEmpty) ...[
                    _buildContactCard(
                      icon: Icons.email_rounded,
                      iconColor: Colors.blue,
                      title: 'email'.tr(context),
                      value: provider.email,
                      onTap: () => _sendEmail(provider.email),
                    ),
                    12.verticalGap,
                  ],

                  // Address
                  _buildInfoCard(
                    icon: Icons.location_on_rounded,
                    iconColor: Colors.red,
                    title: 'address'.tr(context),
                    value: provider.address,
                  ),
                  24.verticalGap,

                  // Price Range
                  AppText(
                    'price_range'.tr(context),
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
                            provider.priceRange,
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

