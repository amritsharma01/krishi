import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
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
                  'Create Account',
                  style: Get.bodyLarge.px28.w700.primary,
                ),

                8.verticalGap,

                AppText(
                  'Join our community today',
                  style: Get.bodyMedium.px14.copyWith(
                    color: Get.disabledColor.o6,
                  ),
                ),

                30.verticalGap,

                // Full Name Field
                AppTextFormField(
                  controller: _nameController,
                  hintText: 'Full Name',
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
                  hintText: 'Phone Number',
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
                  hintText: 'Email Address',
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
                  hintText: 'Password',
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
                  hintText: 'Confirm Password',
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

                30.verticalGap,

                // Sign Up Button
                AppButton(
                  onTap: _handleSignup,
                  text: 'Sign Up',
                  bgcolor: AppColors.primary,
                  textColor: AppColors.white,
                  height: 50.ht,
                  radius: 12,
                ),

                20.verticalGap,

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      'Already have an account?  ',
                      style: Get.bodyMedium.px14.copyWith(
                        color: Get.disabledColor.o7,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.pop();
                      },
                      child: AppText(
                        'Sign In',
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
                    'By signing up, you agree to our Terms of Service and Privacy Policy. Your information will be securely stored.',
                    style: Get.bodySmall.px11.copyWith(
                      color: Get.disabledColor.o7,
                      height: 1.5,
                    ),
                    maxLines: 3,
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
