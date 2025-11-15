import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/auth/signup_page.dart';
import 'package:krishi/features/navigation/main_navigation.dart';
import 'package:krishi/features/widgets/app_text.dart';
import 'package:krishi/features/widgets/button.dart';
import 'package:krishi/features/widgets/form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // TODO: Implement actual login API logic
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      await ref.read(authServiceProvider).login();
      Get.offAll(const MainNavigation());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: Get.scrollPhysics,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15).rt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                40.verticalGap,

                // Logo/Icon
                Container(
                  width: 70.wt,
                  height: 70.ht,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(25).rt,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.store,
                      size: 50.st,
                      color: AppColors.white,
                    ),
                  ),
                ),

                20.verticalGap,

                // App Name
                AppText(
                  'app_name'.tr(context),
                  style: Get.bodyLarge.px30.w700.primary,
                ),

                8.verticalGap,

                AppText(
                  'welcome_back'.tr(context),
                  style: Get.bodyMedium.px16.copyWith(
                    color: Get.disabledColor.o6,
                  ),
                ),

                40.verticalGap,

                // Phone Number Field
                AppTextFormField(
                  controller: _phoneController,
                  hintText: 'phone_number'.tr(context),
                  textInputType: TextInputType.phone,
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: Get.disabledColor.o5,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ).rt,
                  radius: 12,
                ),

                10.verticalGap,

                // Password Field
                AppTextFormField(
                  controller: _passwordController,
                  hintText: 'password'.tr(context),
                  toHide: _obscurePassword,
                  textInputType: TextInputType.visiblePassword,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Get.disabledColor.o5,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Get.disabledColor.o5,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ).rt,
                  radius: 12,
                ),

                10.verticalGap,

                // Sign In Button
                AppButton(
                  onTap: _handleLogin,
                  text: 'sign_in'.tr(context),
                  bgcolor: AppColors.primary,
                  textColor: AppColors.white,
                  height: 40.ht,
                  radius: 12,
                ),

                20.verticalGap,

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      'dont_have_account'.tr(context),
                      style: Get.bodyMedium.px14.copyWith(
                        color: Get.disabledColor.o7,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(const SignupPage());
                      },
                      child: AppText(
                        'signup'.tr(context),
                        style: Get.bodyMedium.px14.w700.primary,
                      ),
                    ),
                  ],
                ),

                30.verticalGap,

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16).rt,
                  decoration: BoxDecoration(
                    color: AppColors.primary.o1,
                    borderRadius: BorderRadius.circular(12).rt,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20.st,
                      ),
                      12.horizontalGap,
                      Expanded(
                        child: AppText(
                          'auth_info'.tr(context),
                          style: Get.bodySmall.px12.copyWith(
                            color: Get.disabledColor.o7,
                            height: 1.4,
                          ),
                          maxLines: 4,
                        ),
                      ),
                    ],
                  ),
                ),

                40.verticalGap,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
