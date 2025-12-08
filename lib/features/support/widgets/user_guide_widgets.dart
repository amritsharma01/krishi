import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';
import 'package:krishi/features/resources/widgets/filter_pill.dart';
import 'package:krishi/features/support/providers/user_guides_providers.dart';
import 'package:krishi/models/resources.dart';

class UserGuideFilter extends ConsumerWidget {
  final Map<String, String> categories;
  final Map<String, IconData> categoryIcons;
  final Map<String, Color> categoryColors;
  final Function(String) onFilterSelected;

  const UserGuideFilter({
    super.key,
    required this.categories,
    required this.categoryIcons,
    required this.categoryColors,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedUserGuideCategoryProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wt, vertical: 12.ht),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.vertical(
          bottom: const Radius.circular(28),
        ).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.entries.map((entry) {
            final isSelected = selectedCategory == entry.key;
            final color = categoryColors[entry.key] ?? AppColors.primary;
            final icon = entry.key == 'all'
                ? Icons.all_inclusive
                : categoryIcons[entry.key] ?? Icons.help_outline_rounded;
            return Padding(
              padding: EdgeInsets.only(right: 8.wt),
              child: FilterPill(
                label: entry.value,
                icon: icon,
                color: color,
                isSelected: isSelected,
                onTap: () => onFilterSelected(entry.key),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class UserGuideList extends ConsumerWidget {
  final Future<void> Function(String?) onRefresh;
  final Map<String, Color> categoryColors;
  final Map<String, IconData> categoryIcons;
  final Function(UserManual) onManualTap;

  const UserGuideList({
    super.key,
    required this.onRefresh,
    required this.categoryColors,
    required this.categoryIcons,
    required this.onManualTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manuals = ref.watch(userGuidesListProvider);
    final selectedCategory = ref.watch(selectedUserGuideCategoryProvider);

    return RefreshIndicator(
      onRefresh: () => onRefresh(selectedCategory),
      child: ListView.builder(
        padding: EdgeInsets.all(16.rt),
        itemCount: manuals.length,
        itemBuilder: (context, index) {
          final manual = manuals[index];
          return UserGuideCard(
            manual: manual,
            categoryColors: categoryColors,
            categoryIcons: categoryIcons,
            onTap: () => onManualTap(manual),
          );
        },
      ),
    );
  }
}

class UserGuideCard extends StatelessWidget {
  final UserManual manual;
  final Map<String, Color> categoryColors;
  final Map<String, IconData> categoryIcons;
  final VoidCallback onTap;

  const UserGuideCard({
    super.key,
    required this.manual,
    required this.categoryColors,
    required this.categoryIcons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColors[manual.category] ?? AppColors.primary;
    final icon = categoryIcons[manual.category] ?? Icons.help_outline_rounded;

    return Container(
      margin: EdgeInsets.only(bottom: 16.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(
          color: Get.disabledColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20).rt,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20).rt,
          child: Padding(
            padding: EdgeInsets.all(20.rt),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.rt),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14).rt,
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Icon(icon, color: color, size: 28.st),
                    ),
                    16.horizontalGap,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            manual.title,
                            style: Get.bodyLarge.px18.w700.copyWith(
                              color: Get.disabledColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          6.verticalGap,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.wt,
                              vertical: 4.ht,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8).rt,
                            ),
                            child: AppText(
                              manual.categoryDisplay,
                              style: Get.bodySmall.px12.w600.copyWith(
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (manual.image != null && manual.image!.isNotEmpty) ...[
                  16.verticalGap,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12).rt,
                    child: CachedNetworkImage(
                      imageUrl: Get.imageUrl(manual.image!),
                      width: double.infinity,
                      height: 160.ht,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 160.ht,
                        color: Get.cardColor.withValues(alpha: 0.3),
                        child: const Center(child: CircularProgressIndicator.adaptive()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 160.ht,
                        color: Get.cardColor.withValues(alpha: 0.3),
                        child: Icon(
                          Icons.image_not_supported,
                          color: Get.disabledColor,
                          size: 32.st,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

