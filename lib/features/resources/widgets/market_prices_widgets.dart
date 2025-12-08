import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/providers/market_prices_providers.dart';
import 'package:krishi/models/resources.dart';

class MarketPricesHeader extends StatelessWidget {
  final Widget searchField;

  const MarketPricesHeader({
    super.key,
    required this.searchField,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.wt, 20.ht, 16.wt, 16.ht),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.vertical(bottom: const Radius.circular(28)).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'market_prices_overview'.tr(context),
            style: Get.bodyLarge.px14.w700.copyWith(color: Get.disabledColor),
          ),
          8.verticalGap,
          AppText(
            'market_prices_intro'.tr(context),
            maxLines: 4,
            style: Get.bodyMedium.px12.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          16.verticalGap,
          searchField,
        ],
      ),
    );
  }
}

class MarketPricesCategoryChips extends ConsumerWidget {
  final void Function(String) onCategorySelected;

  const MarketPricesCategoryChips({
    super.key,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(marketPricesCategoriesProvider);
    final selectedCategory = ref.watch(selectedMarketPriceCategoryProvider);
    final entries = [
      MapEntry('all', 'all_categories'.tr(context)),
      ...categories.entries,
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.wt, vertical: 12.ht),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: entries.map((entry) {
            final isSelected = entry.key == selectedCategory;
            return Padding(
              padding: EdgeInsets.only(right: 8.wt),
              child: GestureDetector(
                onTap: () => onCategorySelected(entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 14.wt, vertical: 8.ht),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Get.primaryColor
                        : Get.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20).rt,
                    border: Border.all(
                      color: isSelected
                          ? Get.primaryColor
                          : Get.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.category_rounded,
                        size: 14.st,
                        color: isSelected ? Colors.white : Get.primaryColor,
                      ),
                      6.horizontalGap,
                      AppText(
                        entry.value,
                        style: Get.bodySmall.px12.w600.copyWith(
                          color: isSelected ? Colors.white : Get.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class MarketPriceCard extends StatelessWidget {
  final MarketPrice price;

  const MarketPriceCard({
    super.key,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final updatedText = DateFormat('MMM dd, yyyy').format(price.updatedAt);
    final formattedPrice = _formatPrice(price.price);

    return Container(
      margin: EdgeInsets.only(bottom: 16.ht),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.rt),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.wt, vertical: 6.ht),
                  decoration: BoxDecoration(
                    color: Get.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20).rt,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront_rounded,
                          size: 14.st, color: Get.primaryColor),
                      6.horizontalGap,
                      AppText(
                        price.categoryDisplay.isNotEmpty
                            ? price.categoryDisplay
                            : 'market_category_other'.tr(context),
                        style: Get.bodySmall.copyWith(
                          color: Get.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.update_rounded,
                  size: 14.st,
                  color: Get.disabledColor.withValues(alpha: 0.7),
                ),
                4.horizontalGap,
                AppText(
                  '${'updated_on'.tr(context)} $updatedText',
                  style: Get.bodySmall.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            12.verticalGap,
            AppText(
              price.name,
              style: Get.bodyLarge.px16.w700.copyWith(
                color:
                    Get.bodyLarge.color ?? (Get.isDark ? Colors.white : Colors.black87),
              ),
            ),
            12.verticalGap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  formattedPrice,
                  style: Get.bodyLarge.px26.w800.copyWith(
                    color: Get.primaryColor,
                  ),
                ),
                6.horizontalGap,
                AppText(
                  '/${price.unit}',
                  style: Get.bodyMedium.px14.w600.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toStringAsFixed(0);
    }
    return price.toStringAsFixed(2);
  }
}

