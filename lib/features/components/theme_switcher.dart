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
    final isLoading = themeProvider.isLoading;

    return Stack(
      children: [
        Opacity(
          opacity: isLoading ? 0.5 : 1.0,
          child: Row(
            children: [
              _buildThemeOption(
                context,
                ref,
                'light',
                Icons.light_mode_outlined,
                0,
                themeProvider.index == 0,
                isLoading,
              ),
              8.horizontalGap,
              _buildThemeOption(
                context,
                ref,
                'dark',
                Icons.dark_mode_outlined,
                1,
                themeProvider.index == 1,
                isLoading,
              ),
              8.horizontalGap,
              _buildThemeOption(
                context,
                ref,
                'system',
                Icons.brightness_auto_outlined,
                2,
                themeProvider.index == 2,
                isLoading,
              ),
            ],
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8).rt,
                decoration: BoxDecoration(
                  color: Get.cardColor,
                  borderRadius: BorderRadius.circular(8).rt,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 20.st,
                  height: 20.st,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    int index,
    bool isSelected,
    bool isDisabled,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                ref.read(themeModeProvider).toggleTheme(index);
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8).rt,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.85),
                    ],
                  )
                : null,
            color: isSelected ? null : Get.cardColor,
            borderRadius: BorderRadius.circular(12).rt,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : Get.disabledColor.withValues(alpha: 0.1),
              width: isSelected ? 0 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.white
                    : Get.disabledColor.withValues(alpha: 0.7),
                size: 24.st,
              ),
              8.verticalGap,
              AppText(
                label.tr(context),
                style: Get.bodySmall.px12.w600.copyWith(
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
