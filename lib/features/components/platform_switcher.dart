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

        return Container(
          padding: const EdgeInsets.all(4).rt,
          decoration: BoxDecoration(
            color: Get.cardColor,
            borderRadius: BorderRadius.circular(14).rt,
            border: Border.all(
              color: Get.disabledColor.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              _buildPlatformOption(
                context,
                'android',
                Icons.android_rounded,
                true,
                isAndroid,
              ),
              _buildPlatformOption(
                context,
                'ios',
                Icons.phone_iphone_rounded,
                false,
                !isAndroid,
              ),
            ],
          ),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            platformProvider.value = isAndroid
                ? PlatformStyle.Material
                : PlatformStyle.Cupertino;
          },
          borderRadius: BorderRadius.circular(12).rt,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8).rt,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.orange
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12).rt,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppColors.white
                      : Get.disabledColor.withValues(alpha: 0.6),
                  size: 22.st,
                ),
                8.horizontalGap,
                Flexible(
                  child: AppText(
                    label.tr(context),
                    style: Get.bodySmall.px12.w600.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : Get.disabledColor.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
