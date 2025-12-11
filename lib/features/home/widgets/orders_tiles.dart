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
import 'package:krishi/features/orders/orders_list_page.dart';

class OrdersTiles extends ConsumerWidget {
  const OrdersTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Row(
      children: [
        Expanded(
          child: _OrderCard(
            title: 'received_orders',
            subtitle: 'orders_as_seller',
            count: homeState.ordersCounts.salesCount,
            icon: Icons.inventory_2_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
            ),
            onTap: () => Get.to(const OrdersListPage.sales()),
            isLoading: homeState.isLoadingOrders,
          ),
        ),
        6.horizontalGap,
        Expanded(
          child: _OrderCard(
            title: 'placed_orders',
            subtitle: 'orders_as_buyer',
            count: homeState.ordersCounts.purchasesCount,
            icon: Icons.shopping_bag_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            ),
            onTap: () => Get.to(const OrdersListPage.purchases()),
            isLoading: homeState.isLoadingOrders,
          ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool isLoading;

  const _OrderCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.gradient,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: !isLoading ? onTap : null,
        borderRadius: BorderRadius.circular(20).rt,
        splashColor: AppColors.primary.withValues(alpha: 0.12),
        highlightColor: AppColors.primary.withValues(alpha: 0.08),
        child: Container(
          constraints: BoxConstraints(minHeight: 90.ht),
          padding: const EdgeInsets.all(16).rt,
          decoration: BoxDecoration(
            color: Get.cardColor,
            borderRadius: BorderRadius.circular(20).rt,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6).rt,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(14).rt,
                    ),
                    child: Icon(icon, color: AppColors.white, size: 24.st),
                  ),
                  15.horizontalGap,
                  Flexible(
                    child: isLoading
                        ? SizedBox(
                            width: 24.st,
                            height: 24.st,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: AppText(
                              '$count',
                              style: Get.bodyLarge.px22.w800.copyWith(
                                color: Get.disabledColor,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              10.verticalGap,
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title.tr(context),
                      style: Get.bodyMedium.px12.w700.copyWith(
                        color: Get.disabledColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    2.verticalGap,
                    AppText(
                      subtitle.tr(context),
                      style: Get.bodySmall.px10.w500.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
