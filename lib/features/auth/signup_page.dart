import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/navigation/main_navigation.dart';
import 'package:krishi/features/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final success = await authService.signInWithGoogle();

      if (success && mounted) {
        // Authentication successful, navigate to home
        Get.offAll(const MainNavigation());

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('signup_success'.tr(context)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        // User cancelled or authentication failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('google_signin_cancelled'.tr(context)),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${'google_signin_failed'.tr(context)}: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        child: Center(
          child: SingleChildScrollView(
            physics: Get.scrollPhysics,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24).rt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  40.verticalGap,

                  // Title
                  AppText(
                    'create_account'.tr(context),
                    style: Get.bodyLarge.px32.w700.primary,
                  ),

                  12.verticalGap,

                  AppText(
                    'join_community'.tr(context),
                    style: Get.bodyMedium.px15.copyWith(
                      color: Get.disabledColor.o6,
                    ),
                  ),

                  40.verticalGap,

                  // Info Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20).rt,
                    child: AppText(
                      'google_signup_info'.tr(context),
                      style: Get.bodyMedium.px14.copyWith(
                        color: Get.disabledColor.o7,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ),

                  30.verticalGap,

                  // Google Sign Up Button
                  GestureDetector(
                    onTap: _isLoading ? null : _handleGoogleSignUp,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16).rt,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15).rt,
                        border: Border.all(
                          color: Get.disabledColor.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? Center(
                              child: SizedBox(
                                height: 24.st,
                                width: 24.st,
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google_logo.png',
                                  height: 28.st,
                                  width: 28.st,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.g_mobiledata_rounded,
                                      size: 32.st,
                                      color: Colors.red,
                                    );
                                  },
                                ),
                                16.horizontalGap,
                                AppText(
                                  'sign_up_with_google'.tr(context),
                                  style: Get.bodyMedium.px17.w600.copyWith(
                                    color: Get.disabledColor,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  40.verticalGap,

                  // Info Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20).rt,
                    child: AppText(
                      'auth_info'.tr(context),
                      style: Get.bodySmall.px11.copyWith(
                        color: Get.disabledColor.o5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ),

                  30.verticalGap,

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        'already_have_account'.tr(context),
                        style: Get.bodyMedium.px14.copyWith(
                          color: Get.disabledColor.o6,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.pop();
                        },
                        child: AppText(
                          'login'.tr(context),
                          style: Get.bodyMedium.px14.w700.primary,
                        ),
                      ),
                    ],
                  ),

                  40.verticalGap,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
