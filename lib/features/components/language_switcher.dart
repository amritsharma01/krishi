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

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langProvider = ref.watch(languageProvider);
    final currentIndex = langProvider.index;

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
          _buildLanguageOption(
            context,
            ref,
            'english',
            '🇬🇧',
            0,
            currentIndex == 0,
          ),
          _buildLanguageOption(
            context,
            ref,
            'nepali',
            '🇳🇵',
            1,
            currentIndex == 1,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    String flag,
    int index,
    bool isSelected,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(languageProvider).toggleLanguage(index);
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  flag,
                  style: TextStyle(fontSize: 20.st),
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
