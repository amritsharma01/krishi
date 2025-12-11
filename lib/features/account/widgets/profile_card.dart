import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/account/providers/user_profile_providers.dart';
import 'package:krishi/features/account/widgets/profile_avatar.dart';
import 'package:krishi/features/components/app_text.dart';

class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (user) => _buildProfileContent(context, user),
      loading: () => _buildLoadingCard(context),
      error: (error, _) => _buildErrorCard(context, ref),
    );
  }

  Widget _buildProfileContent(BuildContext context, user) {
    final profileImage = user.profile?.profileImage;
    final fullName = user.profile?.fullName ?? user.email ?? 'user'.tr(context);
    final email = user.email ?? '';
    final phone = user.profile?.phoneNumber;
    final address = user.profile?.address;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(30).rt,
        border: Border.all(
          color: Get.disabledColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileAvatar(imagePath: profileImage),
          10.verticalGap,
          AppText(
            fullName,
            style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          5.verticalGap,
          AppText(
            email,
            style: Get.bodyMedium.px12.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (phone != null || address != null) ...[
            10.verticalGap,
            _buildContactInfo(phone, address),
          ],
        ],
      ),
    );
  }

  Widget _buildContactInfo(String? phone, String? address) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.rt, vertical: 6.rt),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16).rt,
      ),
      child: Column(
        children: [
          if (phone != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16.st,
                  color: AppColors.primary,
                ),
                8.horizontalGap,
                AppText(
                  phone,
                  style: Get.bodyMedium.px12.w500.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
              ],
            ),
            if (address != null) 5.verticalGap,
          ],
          if (address != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16.st,
                  color: AppColors.primary,
                ),
                8.horizontalGap,
                Flexible(
                  child: AppText(
                    address,
                    style: Get.bodyMedium.px12.w500.copyWith(
                      color: Get.disabledColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20).rt,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24).rt,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20).rt,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.white, size: 48.st),
          16.verticalGap,
          AppText(
            'error_loading_profile'.tr(context),
            style: Get.bodyMedium.px14.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          16.verticalGap,
          GestureDetector(
            onTap: () => ref.read(userProfileProvider.notifier).refresh(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ).rt,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10).rt,
              ),
              child: AppText(
                'retry'.tr(context),
                style: Get.bodyMedium.px14.w600.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
