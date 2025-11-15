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

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
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
            content: Text('signin_success'.tr(context)),
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
                  60.verticalGap,

                  // Logo/Icon
                  Container(
                    width: 100.wt,
                    height: 100.ht,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(30).rt,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.agriculture_rounded,
                        size: 60.st,
                        color: AppColors.white,
                      ),
                    ),
                  ),

                  30.verticalGap,

                  // App Name
                  AppText(
                    'krishi'.tr(context),
                    style: Get.bodyLarge.px36.w700.primary,
                  ),

                  12.verticalGap,

                  AppText(
                    'welcome_back'.tr(context),
                    style: Get.bodyMedium.px16.copyWith(
                      color: Get.disabledColor.o6,
                    ),
                  ),

                  50.verticalGap,

                  // Info Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20).rt,
                    child: AppText(
                      'google_signin_info'.tr(context),
                      style: Get.bodyMedium.px14.copyWith(
                        color: Get.disabledColor.o7,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ),

                  30.verticalGap,

                  // Google Sign In Button
                  GestureDetector(
                    onTap: _isLoading ? null : _handleGoogleSignIn,
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
                                  'sign_in_with_google'.tr(context),
                                  style: Get.bodyMedium.px17.w600.copyWith(
                                    color: Get.disabledColor,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  40.verticalGap,

                  // Additional Info
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

                  60.verticalGap,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
