import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/marketplace/providers/marketplace_providers.dart';
import 'package:krishi/features/marketplace/widgets/marketplace_skeleton_widgets.dart';
import 'package:krishi/features/marketplace/widgets/marketplace_widgets.dart';

import 'package:krishi/models/category.dart';

class CategoryFiltersSection extends ConsumerWidget {
  final bool isNepali;
  final Function(int?) onCategorySelected;

  const CategoryFiltersSection({
    super.key,
    required this.isNepali,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(30).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.1)),
      ),
      child: categoriesAsync.when(
        loading: () => const CategoryFiltersSkeleton(),
        error: (_, __) => const SizedBox.shrink(),
        data: (categories) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CategoryPill(
                label: 'all_categories'.tr(context),
                isSelected: selectedCategoryId == null,
                icon: Icons.all_inclusive,
                onTap: () => onCategorySelected(null),
              ),
              ...categories.map(
                (category) => Padding(
                  padding: EdgeInsets.only(left: 6.rt),
                  child: CategoryPill(
                    label: category.localizedName(isNepali),
                    isSelected: selectedCategoryId == category.id,
                    onTap: () => onCategorySelected(category.id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SellStatusFiltersSection extends ConsumerWidget {
  final Function(String) onStatusChanged;

  const SellStatusFiltersSection({
    super.key,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = ref.watch(sellStatusFilterProvider);
    final filters = [
      {'key': 'all', 'label': 'all_statuses'.tr(context)},
      {'key': 'approved', 'label': 'approved'.tr(context)},
      {'key': 'pending', 'label': 'pending'.tr(context)},
      {'key': 'rejected', 'label': 'rejected'.tr(context)},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedStatus == filter['key'];
          return Padding(
            padding: EdgeInsets.only(right: 8.rt),
            child: _StatusFilterChip(
              label: filter['label']!,
              isSelected: isSelected,
              onTap: () => onStatusChanged(filter['key']!),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24).rt,
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 8.rt, vertical: 6.rt),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.85),
                    ],
                  )
                : null,
            color: isSelected ? null : Get.disabledColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24).rt,
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Get.disabledColor.withValues(alpha: 0.2),
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: AppText(
            label,
            style: Get.bodySmall.w600.copyWith(
              fontSize: 12.sp,
              color: isSelected ? Colors.white : Get.disabledColor,
            ),
          ),
        ),
      ),
    );
  }
}
