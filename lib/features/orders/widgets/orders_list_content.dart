import 'package:flutter/material.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/features/components/empty_state.dart';
import 'package:krishi/features/components/error_state.dart';
import 'package:krishi/features/orders/providers/orders_list_provider.dart';
import 'package:krishi/features/orders/widgets/order_card.dart';
import 'package:krishi/models/order.dart';

class OrdersListContent extends StatelessWidget {
  final OrdersListState state;
  final bool showSales;
  final ScrollController scrollController;
  final VoidCallback onRetry;
  final Function(int id, {bool isItemId}) onNavigateToDetail;

  const OrdersListContent({
    super.key,
    required this.state,
    required this.showSales,
    required this.scrollController,
    required this.onRetry,
    required this.onNavigateToDetail,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          80.verticalGap,
          Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      );
    }

    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.all(16).rt,
        child: ErrorState(
          title: 'problem_fetching_data'.tr(context),
          subtitle: state.error,
          onRetry: onRetry,
        ),
      );
    }

    if (state.filteredOrders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16).rt,
        child: EmptyState(
          title: showSales
              ? 'no_sales'.tr(context)
              : 'no_purchases'.tr(context),
          subtitle: showSales
              ? 'no_sales_message'.tr(context)
              : 'no_purchases_message'.tr(context),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(6).rt,
      itemBuilder: (_, index) {
        if (index >= state.filteredOrders.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6).rt,
            child: Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        final item = state.filteredOrders[index];
        return showSales
            ? SalesOrderCard(
                orderItem: item as OrderItemSeller,
                onTap: () => onNavigateToDetail(item.id, isItemId: true),
              )
            : OrderCard(
                order: item as Order,
                onTap: () => onNavigateToDetail(item.id, isItemId: false),
              );
      },
      separatorBuilder: (_, __) => 4.verticalGap,
      itemCount: state.filteredOrders.length + (state.isLoadingMore ? 1 : 0),
    );
  }
}
