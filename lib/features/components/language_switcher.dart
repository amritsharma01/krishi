import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core_service_providers.dart';
import 'app_text.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langProvider = ref.watch(languageProvider);
    final isLoading = langProvider.isLoading;

    return Stack(
      children: [
        Opacity(
          opacity: isLoading ? 0.5 : 1.0,
          child: Row(
            children: [
              _buildLanguageOption(
                context,
                ref,
                'english',
                '🇬🇧',
                0,
                langProvider.index == 0,
                isLoading,
              ),
              12.horizontalGap,
              _buildLanguageOption(
                context,
                ref,
                'nepali',
                '🇳🇵',
                1,
                langProvider.index == 1,
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

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    String flag,
    int index,
    bool isSelected,
    bool isDisabled,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                ref.read(languageProvider).toggleLanguage(index);
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8).rt,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Get.cardColor,
            borderRadius: BorderRadius.circular(10).rt,
            border: Border.all(
              color: isSelected ? AppColors.primary : Get.disabledColor.o2,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: TextStyle(fontSize: 20.st)),
              8.horizontalGap,
              AppText(
                label.tr(context),
                style: Get.bodyMedium.px13.w600.copyWith(
                  color: isSelected ? AppColors.white : Get.disabledColor.o7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
