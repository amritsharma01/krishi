import 'package:flutter/material.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'about'.tr(context),
          style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Get.disabledColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.rt),
          child: Column(
            children: [
              // App Logo
              Container(
                width: 140.rt,
                height: 140.rt,
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
                child: Image.asset('assets/logo.png', fit: BoxFit.contain),
              ),

              32.verticalGap,

              // App Name
              AppText(
                'Krishi',
                style: Get.bodyLarge.px28.w700.copyWith(
                  color: Get.disabledColor,
                ),
              ),

              8.verticalGap,

              // App Tagline
              AppText(
                'app_tagline'.tr(context),
                style: Get.bodyMedium.px15.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.visible,
              ),

              40.verticalGap,

              // Version Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.rt),
                decoration: BoxDecoration(
                  color: Get.cardColor,
                  borderRadius: BorderRadius.circular(20).rt,
                  border: Border.all(
                    color: Get.disabledColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 24.st,
                      color: AppColors.primary,
                    ),
                    12.horizontalGap,
                    AppText(
                      'version'.tr(context),
                      style: Get.bodyMedium.px16.w600.copyWith(
                        color: Get.disabledColor,
                      ),
                    ),
                    8.horizontalGap,
                    AppText(
                      '1.0.0',
                      style: Get.bodyMedium.px16.w600.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              24.verticalGap,

              // About Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.rt),
                decoration: BoxDecoration(
                  color: Get.cardColor,
                  borderRadius: BorderRadius.circular(20).rt,
                  border: Border.all(
                    color: Get.disabledColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'about_app'.tr(context),
                      style: Get.bodyLarge.px18.w700.copyWith(
                        color: Get.disabledColor,
                      ),
                    ),
                    16.verticalGap,
                    AppText(
                      'about_app_description'.tr(context),
                      style: Get.bodyMedium.px12.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.8),
                        height: 1.6,
                      ),
                      maxLines: 20,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),

              40.verticalGap,

              // Footer
              AppText(
                '© 2025 Krishi. All rights reserved.',
                style: Get.bodySmall.px12.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
