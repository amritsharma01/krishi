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
import 'package:krishi/features/components/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:krishi/features/auth/login_notifier.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loginState = ref.watch(loginProvider);
    final loginNotifier = ref.read(loginProvider.notifier);

    return PlatformScaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Get.scaffoldBackgroundColor,
                      Get.scaffoldBackgroundColor.withValues(alpha: 0.95),
                    ]
                  : [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              physics: Get.scrollPhysics,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20).rt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    80.verticalGap,

                    // Animated Logo Container with Shadow
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        width: 140.wt,
                        height: 140.ht,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    40.verticalGap,

                    // App Name with Gradient
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                      ).createShader(bounds),
                      child: AppText(
                        'krishi'.tr(context),
                        style: Get.bodyLarge.px32.w700.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    16.verticalGap,

                    // Welcome Text
                    AppText(
                      'welcome_back'.tr(context),
                      style: Get.bodyMedium.px16.copyWith(
                        color: Get.disabledColor.o7,
                        letterSpacing: 0.5,
                      ),
                    ),

                    60.verticalGap,

                    // Info Text with better styling
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ).rt,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16).rt,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: AppText(
                        'google_signin_info'.tr(context),
                        style: Get.bodyMedium.px14.copyWith(
                          color: Get.disabledColor.o8,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 4,
                      ),
                    ),

                    40.verticalGap,

                    // Beautiful Google Sign In Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: loginState.isLoading
                            ? null
                            : () => loginNotifier.signInWithGoogle(context),
                        borderRadius: BorderRadius.circular(12).rt,
                        splashColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.shade200,
                        highlightColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade100,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: 45.ht,
                          decoration: BoxDecoration(
                            color: isDark ? Get.cardColor : Colors.white,
                            borderRadius: BorderRadius.circular(20).rt,
                            border: Border.all(
                              color: isDark
                                  ? Get.disabledColor.withValues(alpha: 0.2)
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.3 : 0.08,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.15 : 0.04,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: loginState.isLoading
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
                                    // Google Logo SVG
                                    SizedBox(
                                      height: 22.st,
                                      width: 22.st,
                                      child: SvgPicture.asset(
                                        'assets/images/google_logo.svg',
                                        fit: BoxFit.contain,
                                        placeholderBuilder: (context) =>
                                            Container(
                                              height: 24.st,
                                              width: 24.st,
                                              color: isDark
                                                  ? Get.disabledColor
                                                        .withValues(alpha: 0.2)
                                                  : Colors.grey.shade200,
                                            ),
                                      ),
                                    ),
                                    12.horizontalGap,
                                    AppText(
                                      'sign_in_with_google'.tr(context),
                                      style: Get.bodyMedium.px14.w600.copyWith(
                                        color: isDark
                                            ? Get.disabledColor
                                            : const Color(0xFF3C4043),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    20.verticalGap,

                    // Additional Info with icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 14.st,
                          color: Get.disabledColor.o5,
                        ),
                        8.horizontalGap,
                        Flexible(
                          child: AppText(
                            'auth_info'.tr(context),
                            style: Get.bodySmall.px10.copyWith(
                              color: Get.disabledColor.o5,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.justify,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),

                    20.verticalGap,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
