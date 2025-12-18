import 'package:flutter/material.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/orders/providers/orders_list_provider.dart';
import 'package:krishi/models/order.dart';

class OrderFilterChips extends StatelessWidget {
  final OrdersListState state;
  final bool showSales;
  final Function(String) onFilterSelected;

  const OrderFilterChips({
    super.key,
    required this.state,
    required this.showSales,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'all', 'label': 'all'.tr(context)},
      {'key': 'pending', 'label': 'awaiting_admin_approval'.tr(context)},
      {'key': 'approved', 'label': 'approved'.tr(context)},
      {'key': 'rejected', 'label': 'rejected'.tr(context)},
      {'key': 'in_transit', 'label': 'in_transit'.tr(context)},
      {'key': 'delivered', 'label': 'delivered'.tr(context)},
      {'key': 'completed', 'label': 'completed'.tr(context)},
      {'key': 'cancelled', 'label': 'cancelled'.tr(context)},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4).rt,
      child: Row(
        children: filters
            .map(
              (filter) => Padding(
                padding: EdgeInsets.only(right: 4.rt),
                child: _FilterPill(
                  filter: filter,
                  isSelected: state.selectedFilter == filter['key'],
                  count: _getFilterCount(filter['key']!),
                  onTap: () => onFilterSelected(filter['key']!),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  int _getFilterCount(String filterKey) {
    if (filterKey == 'all') return state.orders.length;

    return state.orders.where((item) {
      if (showSales) {
        final orderItem = item as OrderItemSeller;
        return orderItem.orderStatus.toLowerCase() == filterKey;
      } else {
        final order = item as Order;
        return order.status.toLowerCase() == filterKey;
      }
    }).length;
  }
}

class _FilterPill extends StatelessWidget {
  final Map<String, String> filter;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const _FilterPill({
    required this.filter,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20).rt,
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8).rt,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Get.cardColor,
            borderRadius: BorderRadius.circular(20).rt,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: AppText(
            '${filter['label']} ($count)',
            style: Get.bodySmall.px12.w600.copyWith(
              color: isSelected ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
