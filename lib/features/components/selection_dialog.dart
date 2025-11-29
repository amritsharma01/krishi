import 'package:flutter/material.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';

class SelectionDialog<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) getItemName;
  final int? Function(T) getItemId;
  final Function(T) onItemSelected;

  const SelectionDialog({
    super.key,
    required this.title,
    required this.items,
    this.selectedItem,
    required this.getItemName,
    required this.getItemId,
    required this.onItemSelected,
  });

  static void show<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    T? selectedItem,
    required String Function(T) getItemName,
    required int? Function(T) getItemId,
    required Function(T) onItemSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SelectionDialog<T>(
          title: title,
          items: items,
          selectedItem: selectedItem,
          getItemName: getItemName,
          getItemId: getItemId,
          onItemSelected: onItemSelected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.rt),
          topRight: Radius.circular(24.rt),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12).rt,
              width: 40.rt,
              height: 4.rt,
              decoration: BoxDecoration(
                color: Get.disabledColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2).rt,
              ),
            ),
            20.verticalGap,
            AppText(
              title,
              style: Get.bodyLarge.px20.w700.copyWith(
                color: Get.disabledColor,
              ),
            ),
            24.verticalGap,
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20).rt,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = selectedItem != null &&
                      getItemId(selectedItem as T) == getItemId(item);
                  return GestureDetector(
                    onTap: () {
                      onItemSelected(item);
                      Get.pop();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12).rt,
                      padding: const EdgeInsets.all(16).rt,
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
                      child: Row(
                        children: [
                          Expanded(
                            child: AppText(
                              getItemName(item),
                              style: Get.bodyMedium.px15.w600.copyWith(
                                color: isSelected
                                    ? AppColors.white
                                    : Get.disabledColor,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppColors.white,
                              size: 20.st,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            20.verticalGap,
          ],
        ),
      ),
    );
  }
}

