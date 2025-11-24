import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/services/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core_service_providers.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = ref.watch(themeModeProvider);
    final currentIndex = themeProvider.index;

    return Container(
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(
          color: Get.disabledColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildThemeOption(
            context,
            ref,
            Icons.light_mode_rounded,
            0,
            currentIndex == 0,
          ),
          Container(
            width: 1,
            height: 24.rt,
            color: Get.disabledColor.withValues(alpha: 0.1),
          ),
          _buildThemeOption(
            context,
            ref,
            Icons.dark_mode_rounded,
            1,
            currentIndex == 1,
          ),
          Container(
            width: 1,
            height: 24.rt,
            color: Get.disabledColor.withValues(alpha: 0.1),
          ),
          _buildThemeOption(
            context,
            ref,
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
          borderRadius: BorderRadius.circular(16).rt,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 14.rt),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16).rt),
            child: Center(
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.primary
                    : Get.disabledColor.withValues(alpha: 0.5),
                size: 22.st,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
