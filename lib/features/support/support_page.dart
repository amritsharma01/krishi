import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        title: AppText(
          'help_center'.tr(context),
          style: Get.bodyLarge.px22.w700.copyWith(color: Get.disabledColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: Get.scrollPhysics,
          child: Padding(
            padding: const EdgeInsets.all(16).rt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24).rt,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20).rt,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16).rt,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.support_agent_rounded,
                          color: AppColors.primary,
                          size: 48.st,
                        ),
                      ),
                      16.verticalGap,
                      AppText(
                        'how_can_we_help'.tr(context),
                        style: Get.bodyLarge.px20.w700.copyWith(
                          color: Get.disabledColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                24.verticalGap,

                // Support Options
                _buildSupportOption(
                  context,
                  title: 'faq',
                  subtitle: 'common_questions',
                  icon: Icons.quiz_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                  ),
                  onTap: () {
                    // TODO: Navigate to FAQ page
                    Get.snackbar('FAQ page coming soon!');
                  },
                ),

                12.verticalGap,

                _buildSupportOption(
                  context,
                  title: 'contact_us',
                  subtitle: 'get_in_touch',
                  icon: Icons.phone_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                  ),
                  onTap: () {
                    // TODO: Navigate to Contact page
                    Get.snackbar('Contact page coming soon!');
                  },
                ),

                12.verticalGap,

                _buildSupportOption(
                  context,
                  title: 'report_issue',
                  subtitle: 'report_problem',
                  icon: Icons.bug_report_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFEF5350)],
                  ),
                  onTap: () {
                    // TODO: Navigate to Report Issue page
                    Get.snackbar('Report issue page coming soon!');
                  },
                ),

                12.verticalGap,

                _buildSupportOption(
                  context,
                  title: 'user_guide',
                  subtitle: 'learn_how_to_use',
                  icon: Icons.menu_book_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
                  ),
                  onTap: () {
                    // TODO: Navigate to User Guide page
                    Get.snackbar('User guide coming soon!');
                  },
                ),

                24.verticalGap,

                // Quick Contact Info
                Container(
                  padding: const EdgeInsets.all(20).rt,
                  decoration: BoxDecoration(
                    color: Get.cardColor,
                    borderRadius: BorderRadius.circular(16).rt,
                    border: Border.all(
                      color: Get.disabledColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Quick Contact',
                        style: Get.bodyMedium.px16.w700.copyWith(
                          color: Get.disabledColor,
                        ),
                      ),
                      16.verticalGap,
                      _buildContactRow(
                        context,
                        icon: Icons.email_rounded,
                        text: 'support@krishi.com',
                      ),
                      12.verticalGap,
                      _buildContactRow(
                        context,
                        icon: Icons.phone_rounded,
                        text: '+977 9800000000',
                      ),
                      12.verticalGap,
                      _buildContactRow(
                        context,
                        icon: Icons.access_time_rounded,
                        text: 'Mon - Fri, 9:00 AM - 5:00 PM',
                      ),
                    ],
                  ),
                ),

                20.verticalGap,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(16).rt,
          border: Border.all(
            color: Get.disabledColor.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12).rt,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12).rt,
              ),
              child: Icon(icon, color: AppColors.white, size: 24.st),
            ),
            16.horizontalGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title.tr(context),
                    style: Get.bodyMedium.px15.w700.copyWith(
                      color: Get.disabledColor,
                    ),
                  ),
                  4.verticalGap,
                  AppText(
                    subtitle.tr(context),
                    style: Get.bodySmall.px12.w500.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Get.disabledColor.withValues(alpha: 0.3),
              size: 18.st,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20.st),
        12.horizontalGap,
        Expanded(
          child: AppText(
            text,
            style: Get.bodyMedium.px13.w500.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}
