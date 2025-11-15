import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/home/home_page.dart';
import 'package:krishi/features/widgets/app_text.dart';
import 'package:krishi/features/widgets/button.dart';
import 'package:krishi/features/widgets/form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    // TODO: Implement signup logic
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Get.offAll(const HomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: PlatformAppBar(
        backgroundColor: Get.scaffoldBackgroundColor,
        leading: PlatformIconButton(
          icon: Icon(Icons.arrow_back, color: Get.disabledColor),
          onPressed: () => Get.pop(),
        ),
        material: (_, __) => MaterialAppBarData(elevation: 0),
        cupertino: (_, __) => CupertinoNavigationBarData(border: null),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: Get.scrollPhysics,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24).rt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                20.verticalGap,

                // Title
                AppText(
                  'create_account'.tr(context),
                  style: Get.bodyLarge.px28.w700.primary,
                ),

                8.verticalGap,

                AppText(
                  'join_community'.tr(context),
                  style: Get.bodyMedium.px14.copyWith(
                    color: Get.disabledColor.o6,
                  ),
                ),

                30.verticalGap,

                // Full Name Field
                AppTextFormField(
                  controller: _nameController,
                  hintText: 'full_name'.tr(context),
                  textInputType: TextInputType.name,
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Get.disabledColor.o5,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ).rt,
                  radius: 12,
                ),

                10.verticalGap,

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

                // Email Field
                AppTextFormField(
                  controller: _emailController,
                  hintText: 'email_address'.tr(context),
                  textInputType: TextInputType.emailAddress,
                  prefixIcon: Icon(
                    Icons.email_outlined,
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

                // Confirm Password Field
                AppTextFormField(
                  controller: _confirmPasswordController,
                  hintText: 'confirm_password'.tr(context),
                  toHide: _obscureConfirmPassword,
                  textInputType: TextInputType.visiblePassword,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Get.disabledColor.o5,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Get.disabledColor.o5,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
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

                // Sign Up Button
                AppButton(
                  onTap: _handleSignup,
                  text: 'signup'.tr(context),
                  bgcolor: AppColors.primary,
                  textColor: AppColors.white,
                  height: 40.ht,
                  radius: 12,
                ),

                20.verticalGap,

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      'already_have_account'.tr(context),
                      style: Get.bodyMedium.px14.copyWith(
                        color: Get.disabledColor.o7,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.pop();
                      },
                      child: AppText(
                        'sign_in'.tr(context),
                        style: Get.bodyMedium.px14.w700.primary,
                      ),
                    ),
                  ],
                ),

                30.verticalGap,

                // Terms and Conditions
                Container(
                  padding: const EdgeInsets.all(16).rt,
                  decoration: BoxDecoration(
                    color: AppColors.primary.o1,
                    borderRadius: BorderRadius.circular(12).rt,
                  ),
                  child: AppText(
                    'terms_info'.tr(context),
                    style: Get.bodySmall.px11.copyWith(
                      color: Get.disabledColor.o7,
                      height: 1.5,
                    ),
                    maxLines: 4,
                    textAlign: TextAlign.center,
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
