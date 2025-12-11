import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/auth/logout_notifier.dart';
import 'package:krishi/features/account/edit_profile_page.dart';
import 'package:krishi/features/account/about_page.dart';
import 'package:krishi/features/account/providers/user_profile_providers.dart';
import 'package:krishi/features/account/widgets/profile_card.dart';
import 'package:krishi/features/account/widgets/settings_section.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/dialog_box.dart';
import 'package:krishi/features/components/language_switcher.dart';
import 'package:krishi/features/components/platform_switcher.dart';
import 'package:krishi/features/components/settings_tile.dart';
import 'package:krishi/features/components/theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        title: AppText(
          'my_account'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(userProfileProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: Get.scrollPhysics,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8).rt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProfileCard(),
                  12.verticalGap,
                  AppText(
                    'app_settings'.tr(context),
                    style: Get.bodyLarge.px16.w700.copyWith(
                      color: Get.disabledColor,
                    ),
                  ),
                  6.verticalGap,
                  SettingsSection(
                    icon: Icons.palette_outlined,
                    title: 'theme_mode'.tr(context),
                    subtitle: 'choose_theme'.tr(context),
                    child: const ThemeSwitcher(),
                  ),
                  6.verticalGap,
                  SettingsSection(
                    icon: Icons.language_outlined,
                    title: 'language'.tr(context),
                    subtitle: 'select_language'.tr(context),
                    child: const LanguageSwitcher(),
                  ),
                  6.verticalGap,
                  // _buildDeveloperBanner(context),
                  // 6.verticalGap,
                  // SettingsTile(
                  //   icon: Icons.smartphone_outlined,
                  //   iconColor: Colors.orange,
                  //   title: 'platform_dev'.tr(context),
                  //   subtitle: 'test_platform'.tr(context),
                  //   trailing: Container(),
                  // ),
                  // 6.verticalGap,
                  // const PlatformSwitcher(),
                  // 6.verticalGap,
                  AppText(
                    'account_actions'.tr(context),
                    style: Get.bodyLarge.px16.w700.copyWith(
                      color: Get.disabledColor,
                    ),
                  ),
                  6.verticalGap,
                  _buildEditProfileTile(context, ref),
                  6.verticalGap,
                  // SettingsTile(
                  //   icon: Icons.notifications_outlined,
                  //   title: 'notifications'.tr(context),
                  //   subtitle: 'manage_notifications'.tr(context),
                  //   trailing: Icon(
                  //     Icons.arrow_forward_ios,
                  //     size: 16.st,
                  //     color: Get.disabledColor.o5,
                  //   ),
                  //   onTap: () {
                  //     // TODO: Navigate to notifications settings
                  //   },
                  // ),
                  // 6.verticalGap,
                  SettingsTile(
                    icon: Icons.info_outline,
                    title: 'about'.tr(context),
                    subtitle: 'version'.tr(context),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16.st,
                      color: Get.disabledColor.o5,
                    ),
                    onTap: () => Get.to(const AboutPage()),
                  ),
                  6.verticalGap,
                  _buildLogoutButton(context, ref),
                  16.verticalGap,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeveloperBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12).rt,
      decoration: BoxDecoration(
        color: Colors.orange.o1,
        borderRadius: BorderRadius.circular(10).rt,
        border: Border.all(color: Colors.orange.o3, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.code, color: Colors.orange, size: 18.st),
          8.horizontalGap,
          AppText(
            'developer_settings'.tr(context),
            style: Get.bodyMedium.px13.w600.copyWith(
              color: Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileTile(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.maybeWhen(
      data: (user) => SettingsTile(
        icon: Icons.edit_outlined,
        title: 'edit_profile'.tr(context),
        subtitle: 'update_information'.tr(context),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.st,
          color: Get.disabledColor.o5,
        ),
        onTap: () async {
          final updated = await Get.to(EditProfilePage(user: user));
          if (updated == true && context.mounted) {
            // Use a small delay to ensure navigation completes before refresh
            await Future.delayed(const Duration(milliseconds: 100));
            if (context.mounted) {
              ref.read(userProfileProvider.notifier).refresh();
            }
          }
        },
      ),
      orElse: () => SettingsTile(
        icon: Icons.edit_outlined,
        title: 'edit_profile'.tr(context),
        subtitle: 'update_information'.tr(context),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.st,
          color: Get.disabledColor.o5,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    final logoutState = ref.watch(logoutProvider);

    return SizedBox(
      width: double.infinity,
      height: 40.ht,
      child: ElevatedButton(
        onPressed: logoutState.isLoading
            ? null
            : () {
                AppDialog.showConfirmation(
                  title: 'logout'.tr(context),
                  content: 'logout_confirmation'.tr(context),
                  confirmText: 'logout'.tr(context),
                  confirmColor: Colors.red,
                  onConfirm: () async {
                    await ref.read(logoutProvider.notifier).signOut(context);
                  },
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          disabledBackgroundColor: Colors.red.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12).rt,
          ),
          elevation: 0,
        ),
        child: logoutState.isLoading
            ? SizedBox(
                height: 20.st,
                width: 20.st,
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  strokeWidth: 2,
                ),
              )
            : AppText(
                'logout'.tr(context),
                style: Get.bodyMedium.px14.w600.copyWith(
                  color: AppColors.white,
                ),
              ),
      ),
    );
  }
}
