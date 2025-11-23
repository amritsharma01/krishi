import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core_service_providers.dart';
import 'app_text.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = ref.watch(themeModeProvider);
    final currentIndex = themeProvider.index;

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
          _buildThemeOption(
            context,
            ref,
            'light',
            Icons.light_mode_rounded,
            0,
            currentIndex == 0,
          ),
          _buildThemeOption(
            context,
            ref,
            'dark',
            Icons.dark_mode_rounded,
            1,
            currentIndex == 1,
          ),
          _buildThemeOption(
            context,
            ref,
            'system',
            Icons.brightness_auto_rounded,
            2,
            currentIndex == 2,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    int index,
    bool isSelected,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(themeModeProvider).toggleTheme(index);
          },
          borderRadius: BorderRadius.circular(12).rt,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8).rt,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12).rt,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppColors.white
                      : Get.disabledColor.withValues(alpha: 0.6),
                  size: 22.st,
                ),
                6.verticalGap,
                AppText(
                  label.tr(context),
                  style: Get.bodySmall.px11.w600.copyWith(
                    color: isSelected
                        ? AppColors.white
                        : Get.disabledColor.withValues(alpha: 0.7),
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
