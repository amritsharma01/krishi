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
import 'package:krishi/features/resources/dynamic_market_prices_page.dart';

class MarketPricesSection extends ConsumerWidget {
  const MarketPricesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          ],
        ),
        6.verticalGap,
        GestureDetector(
          onTap: () => Get.to(const DynamicMarketPricesPage()),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16).rt,
            decoration: BoxDecoration(
              color: Get.cardColor,
              borderRadius: BorderRadius.circular(16).rt,
              border: Border.all(
                color: Get.disabledColor.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.table_chart_rounded,
                  color: AppColors.primary,
                  size: 24.st,
                ),
                12.horizontalGap,
                AppText(
                  'view_market_prices'.tr(context),
                  style: Get.bodyMedium.px15.w600.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                8.horizontalGap,
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 18.st,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
