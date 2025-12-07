import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/home/home_notifier.dart';
import 'package:krishi/features/resources/market_prices_page.dart';
import 'package:krishi/models/resources.dart';

class MarketPricesSection extends ConsumerWidget {
  const MarketPricesSection({super.key});

  String _formatMarketPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toStringAsFixed(0);
    }
    return price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: AppText(
                'market_prices'.tr(context),
                style: Get.bodyLarge.px14.w600.copyWith(
                  color: Get.disabledColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            8.horizontalGap,
            GestureDetector(
              onTap: () => Get.to(const MarketPricesPage()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ).rt,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20).rt,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      'view_all'.tr(context),
                      style: Get.bodyMedium.px10.w600.copyWith(
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.horizontalGap,
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 14.st,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        6.verticalGap,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16).rt,
          decoration: BoxDecoration(
            color: Get.cardColor,
            borderRadius: BorderRadius.circular(16).rt,
            border: Border.all(color: Get.disabledColor.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: homeState.isLoadingMarketPrices
              ? const Center(child: CircularProgressIndicator.adaptive())
              : homeState.marketPricesError != null
              ? _MarketPricesError()
              : homeState.marketPrices.isEmpty
              ? _MarketPricesEmpty()
              : Column(
                  children: [
                    for (int i = 0; i < homeState.marketPrices.length; i++) ...[
                      _MarketPriceRow(
                        price: homeState.marketPrices[i],
                        formatPrice: _formatMarketPrice,
                      ),
                      if (i != homeState.marketPrices.length - 1)
                        Divider(
                          color: Get.disabledColor.withValues(alpha: 0.1),
                          height: 20,
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _MarketPriceRow extends StatelessWidget {
  final MarketPrice price;
  final String Function(double) formatPrice;

  const _MarketPriceRow({required this.price, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    final formattedPrice = formatPrice(price.price);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10).rt,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12).rt,
          ),
          child: Icon(
            Icons.shopping_cart_rounded,
            color: AppColors.primary,
            size: 20.st,
          ),
        ),
        12.horizontalGap,
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: AppText(
                  price.name,
                  style: Get.bodyMedium.px15.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              4.verticalGap,
              Row(
                children: [
                  Icon(
                    Icons.category_rounded,
                    size: 12.st,
                    color: Get.disabledColor.withValues(alpha: 0.7),
                  ),
                  4.horizontalGap,
                  Flexible(
                    child: AppText(
                      price.categoryDisplay.isNotEmpty
                          ? price.categoryDisplay
                          : 'market_category_other'.tr(context),
                      style: Get.bodySmall.px11.w500.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        8.horizontalGap,
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: AppText(
                  formattedPrice,
                  style: Get.bodyMedium.px15.w800.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              2.verticalGap,
              Flexible(
                child: AppText(
                  '/${price.unit}',
                  style: Get.bodySmall.px11.w500.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MarketPricesError extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AppText(
          'market_prices_error'.tr(context),
          style: Get.bodyMedium.px12.copyWith(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        6.verticalGap,
        ElevatedButton(
          onPressed: () => ref.read(homeProvider.notifier).loadMarketPrices(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12).rt,
            ),
          ),
          child: AppText(
            'retry'.tr(context),
            style: Get.bodyMedium.px10.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _MarketPricesEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.bar_chart_rounded,
          color: Get.disabledColor.withValues(alpha: 0.6),
          size: 30.st,
        ),
        8.verticalGap,
        AppText(
          'no_market_prices'.tr(context),
          style: Get.bodyMedium.px12.w600.copyWith(color: Get.disabledColor),
          textAlign: TextAlign.center,
        ),

        AppText(
          'market_prices_empty_state_subtitle'.tr(context),
          style: Get.bodySmall.px10.copyWith(
            color: Get.disabledColor.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
