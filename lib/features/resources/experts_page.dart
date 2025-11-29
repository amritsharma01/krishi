import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpertsPage extends ConsumerStatefulWidget {
  const ExpertsPage({super.key});

  @override
  ConsumerState<ExpertsPage> createState() => _ExpertsPageState();
}

class _ExpertsPageState extends ConsumerState<ExpertsPage> {
  List<Expert> _experts = [];
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _loadExperts();
  }

  @override
  void dispose() {
    _isLoading.dispose();
    super.dispose();
  }

  Future<void> _loadExperts() async {
    _isLoading.value = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final experts = await apiService.getExperts();
      if (mounted) {
        _experts = experts;
        _isLoading.value = false;
      }
    } catch (e) {
      if (mounted) {
        _isLoading.value = false;
        Get.snackbar('error_loading_products'.tr(context));
      }
    }
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('could_not_make_call'.tr(context));
    }
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    if (email.isEmpty) {
      Get.snackbar('no_email_available'.tr(context));
      return;
    }
    try {
      final uri = Uri.parse('mailto:$email');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        Get.snackbar('could_not_send_email'.tr(context));
      }
    }
  }

  Future<void> _openWhatsApp(BuildContext context, String phoneNumber) async {
    try {
      // Remove any spaces or special characters
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Add country code if not present (Nepal country code is +977)
      if (!cleanNumber.startsWith('+') && !cleanNumber.startsWith('977')) {
        cleanNumber = '977$cleanNumber';
      }
      
      // Ensure it starts with + for WhatsApp
      if (!cleanNumber.startsWith('+')) {
        cleanNumber = '+$cleanNumber';
      }
      
      final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');
      
      // Try multiple launch modes
      try {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        try {
          await launchUrl(whatsappUri, mode: LaunchMode.platformDefault);
        } catch (e2) {
          try {
            await launchUrl(whatsappUri, mode: LaunchMode.inAppWebView);
          } catch (e3) {
            if (mounted) {
              Get.snackbar('whatsapp_failed'.tr(context), color: Colors.red);
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('whatsapp_failed'.tr(context), color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'agri_experts'.tr(context),
          style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Get.disabledColor),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (context, isLoading, _) {
          return isLoading
              ? Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : _experts.isEmpty
              ? _buildEmptyState(context)
              : _buildExpertsList(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 80.st,
            color: Colors.grey.shade400,
          ),
          16.verticalGap,
          AppText(
            'no_experts_available'.tr(context),
            style: Get.bodyLarge.px18.w600.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          8.verticalGap,
          AppText(
            'check_back_later'.tr(context),
            style: Get.bodyMedium.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertsList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadExperts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16).rt,
        itemCount: _experts.length,
        itemBuilder: (context, index) {
          final expert = _experts[index];
          return _buildExpertCard(context, expert);
        },
      ),
    );
  }

  Widget _buildExpertCard(BuildContext context, Expert expert) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(
          color: Get.disabledColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20).rt,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                // Header with photo and basic info
                Row(
                  children: [
                    // Profile Photo
                    Container(
                      width: 70.rt,
                      height: 70.rt,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: expert.photo != null && expert.photo!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: Get.imageUrl(expert.photo!),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 35.st,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : Container(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 35.st,
                                  color: AppColors.primary,
                                ),
                              ),
                      ),
                    ),
                    16.horizontalGap,
                    // Name and Specialization
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            expert.name,
                            style: Get.bodyLarge.px18.w700.copyWith(
                              color: Get.disabledColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          6.verticalGap,
                          AppText(
                            expert.specialization,
                            style: Get.bodyMedium.px14.w500.copyWith(
                              color: Get.disabledColor.withValues(alpha: 0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                20.verticalGap,
                // Key Information Pills
                Wrap(
                  spacing: 8.rt,
                  runSpacing: 8.rt,
                  children: [
                    _buildInfoPill(
                      icon: Icons.access_time_rounded,
                      text: expert.availableHours,
                    ),
                    _buildInfoPill(
                      icon: Icons.calendar_today_rounded,
                      text: expert.availableDays,
                    ),
                    _buildInfoPill(
                      icon: Icons.payments_rounded,
                      text: expert.consultationFee,
                    ),
                  ],
                ),
                20.verticalGap,
                // Contact Actions
                Column(
                  children: [
                    // Call and WhatsApp side by side
                    Row(
                      children: [
                        Expanded(
                          child: _buildContactButton(
                            icon: Icons.phone_rounded,
                            label: 'call'.tr(context),
                            color: Colors.green,
                            onTap: () => _makePhoneCall(context, expert.phoneNumber),
                          ),
                        ),
                        12.horizontalGap,
                        Expanded(
                          child: _buildContactButton(
                            icon: Icons.chat_rounded,
                            label: 'whatsapp'.tr(context),
                            color: const Color(0xFF25D366),
                            onTap: () => _openWhatsApp(context, expert.phoneNumber),
                          ),
                        ),
                      ],
                    ),
                    // Email button below if email exists
                    if (expert.email.isNotEmpty) ...[
                      12.verticalGap,
                      _buildContactButton(
                        icon: Icons.email_rounded,
                        label: 'email'.tr(context),
                        color: Colors.blue,
                        onTap: () => _sendEmail(context, expert.email),
                      ),
                    ],
                  ],
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildInfoPill({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.rt, vertical: 8.rt),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.st,
            color: AppColors.primary,
          ),
          6.horizontalGap,
          Flexible(
            child: AppText(
              text,
              style: Get.bodySmall.px12.w600.copyWith(
                color: Get.disabledColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12).rt,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.rt, horizontal: 8.rt),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12).rt,
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.st, color: color),
              6.horizontalGap,
              Flexible(
                child: AppText(
                  label,
                  style: Get.bodyMedium.px14.w600.copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
