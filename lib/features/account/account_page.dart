import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/auth/login_page.dart';
import 'package:krishi/features/widgets/app_text.dart';
import 'package:krishi/features/widgets/button.dart';
import 'package:krishi/features/widgets/language_switcher.dart';
import 'package:krishi/features/widgets/platform_switcher.dart';
import 'package:krishi/features/widgets/settings_tile.dart';
import 'package:krishi/features/widgets/theme_switcher.dart';
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
          style: Get.bodyLarge.px22.w700.copyWith(color: Get.disabledColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: Get.scrollPhysics,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15).rt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                20.verticalGap,
                
                // Profile Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20).rt,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.o8,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16).rt,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40.rt,
                        backgroundColor: AppColors.white.o3,
                        child: Icon(
                          Icons.person,
                          size: 40.st,
                          color: AppColors.white,
                        ),
                      ),
                      16.verticalGap,
                      AppText(
                        'guest_user'.tr(context),
                        style: Get.bodyLarge.px20.w700.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      6.verticalGap,
                      AppText(
                        'guest@jaljala.com',
                        style: Get.bodyMedium.px13.copyWith(
                          color: AppColors.white.o8,
                        ),
                      ),
                    ],
                  ),
                ),
                
                24.verticalGap,
                
                // App Settings Section
                AppText(
                  'app_settings'.tr(context),
                  style: Get.bodyLarge.px16.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                
                12.verticalGap,
                
                // Theme Mode
                SettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'theme_mode'.tr(context),
                  subtitle: 'choose_theme'.tr(context),
                  trailing: Container(),
                ),
                
                12.verticalGap,
                
                const ThemeSwitcher(),
                
                16.verticalGap,
                
                // Language
                SettingsTile(
                  icon: Icons.language_outlined,
                  title: 'language'.tr(context),
                  subtitle: 'select_language'.tr(context),
                  trailing: Container(),
                ),
                
                12.verticalGap,
                
                const LanguageSwitcher(),
                
                24.verticalGap,
                
                // Developer Settings
                Container(
                  padding: const EdgeInsets.all(12).rt,
                  decoration: BoxDecoration(
                    color: Colors.orange.o1,
                    borderRadius: BorderRadius.circular(10).rt,
                    border: Border.all(
                      color: Colors.orange.o3,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.code,
                        color: Colors.orange,
                        size: 18.st,
                      ),
                      8.horizontalGap,
                      AppText(
                        'developer_settings'.tr(context),
                        style: Get.bodyMedium.px13.w600.copyWith(
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                
                12.verticalGap,
                
                // Platform Switcher
                SettingsTile(
                  icon: Icons.smartphone_outlined,
                  iconColor: Colors.orange,
                  title: 'platform_dev'.tr(context),
                  subtitle: 'test_platform'.tr(context),
                  trailing: Container(),
                ),
                
                12.verticalGap,
                
                const PlatformSwitcher(),
                
                24.verticalGap,
                
                // Account Actions
                AppText(
                  'account_actions'.tr(context),
                  style: Get.bodyLarge.px16.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                
                12.verticalGap,
                
                SettingsTile(
                  icon: Icons.edit_outlined,
                  title: 'edit_profile'.tr(context),
                  subtitle: 'update_information'.tr(context),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16.st,
                    color: Get.disabledColor.o5,
                  ),
                  onTap: () {
                    // TODO: Navigate to edit profile
                  },
                ),
                
                12.verticalGap,
                
                SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'notifications'.tr(context),
                  subtitle: 'manage_notifications'.tr(context),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16.st,
                    color: Get.disabledColor.o5,
                  ),
                  onTap: () {
                    // TODO: Navigate to notifications settings
                  },
                ),
                
                12.verticalGap,
                
                SettingsTile(
                  icon: Icons.help_outline,
                  title: 'help_support'.tr(context),
                  subtitle: 'get_help'.tr(context),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16.st,
                    color: Get.disabledColor.o5,
                  ),
                  onTap: () {
                    // TODO: Navigate to help
                  },
                ),
                
                12.verticalGap,
                
                SettingsTile(
                  icon: Icons.info_outline,
                  title: 'about'.tr(context),
                  subtitle: 'version'.tr(context),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16.st,
                    color: Get.disabledColor.o5,
                  ),
                  onTap: () {
                    // TODO: Navigate to about
                  },
                ),
                
                24.verticalGap,
                
                // Logout Button
                AppButton(
                  onTap: () async {
                    await ref.read(authServiceProvider).logout();
                    if (context.mounted) {
                      Get.offAll(const LoginPage());
                    }
                  },
                  text: 'logout'.tr(context),
                  bgcolor: Colors.red,
                  textColor: AppColors.white,
                  height: 40.ht,
                  radius: 12,
                ),
                
                30.verticalGap,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

