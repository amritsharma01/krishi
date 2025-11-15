import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../../core/core_service_providers.dart';
import 'app_text.dart';

class PlatformSwitcher extends StatelessWidget {
  const PlatformSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: platformProvider,
      builder: (context, platform, child) {
        final isAndroid = platform == PlatformStyle.Material;
        
        return Row(
          children: [
            _buildPlatformOption(
              context,
              'android',
              Icons.android,
              true,
              isAndroid,
            ),
            12.horizontalGap,
            _buildPlatformOption(
              context,
              'ios',
              Icons.apple,
              false,
              !isAndroid,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlatformOption(
    BuildContext context,
    String label,
    IconData icon,
    bool isAndroid,
    bool isSelected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          platformProvider.value = isAndroid
              ? PlatformStyle.Material
              : PlatformStyle.Cupertino;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8).rt,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : Get.cardColor,
            borderRadius: BorderRadius.circular(10).rt,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : Get.disabledColor.o2,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.white
                    : Get.disabledColor.o7,
                size: 20.st,
              ),
              8.horizontalGap,
              AppText(
                label.tr(context),
                style: Get.bodyMedium.px13.w600.copyWith(
                  color: isSelected
                      ? AppColors.white
                      : Get.disabledColor.o7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

