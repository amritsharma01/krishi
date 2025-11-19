import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../../../core/core_service_providers.dart';
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12).rt,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      Colors.orange,
                      Colors.orange.withValues(alpha: 0.85),
                    ],
                  )
                : null,
            color: isSelected ? null : Get.cardColor,
            borderRadius: BorderRadius.circular(12).rt,
            border: Border.all(
              color: isSelected
                  ? Colors.orange
                  : Get.disabledColor.withValues(alpha: 0.1),
              width: isSelected ? 0 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.white
                    : Get.disabledColor.withValues(alpha: 0.8),
                size: 22.st,
              ),
              10.horizontalGap,
              AppText(
                label.tr(context),
                style: Get.bodyMedium.px14.w600.copyWith(
                  color: isSelected
                      ? AppColors.white
                      : Get.disabledColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
