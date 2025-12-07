import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/home/home_notifier.dart';

class WelcomeCard extends ConsumerWidget {
  const WelcomeCard({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning';
    if (hour < 17) return 'good_afternoon';
    return 'good_evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final userName = (homeState.currentUser?.displayName ?? '').trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/image.png'),
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
          colorFilter: ColorFilter.mode(
            AppColors.primary.withValues(alpha: 0.25),
            BlendMode.srcATop,
          ),
        ),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.5),
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.05, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20).rt,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100.rt,
              height: 100.rt,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 120.rt,
              height: 120.rt,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15).rt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  _getGreeting().tr(context),
                  style: Get.bodyMedium.px12.w500.copyWith(
                    color: AppColors.white.withValues(alpha: 0.95),
                    letterSpacing: 0.5,
                  ),
                ),

                AppText(
                  userName.isNotEmpty ? userName : 'welcome_user'.tr(context),
                  style: Get.bodyLarge.px22.w800.copyWith(
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                12.verticalGap,
                AppText(
                  'app_tagline'.tr(context),
                  style: Get.bodyMedium.px12.w400.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                    height: 1.4,
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
