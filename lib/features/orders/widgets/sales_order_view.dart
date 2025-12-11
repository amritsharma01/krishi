import 'package:flutter/material.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/features/orders/widgets/order_detail_widgets.dart';
import 'package:krishi/models/order.dart';

class SalesOrderView extends StatelessWidget {
  final OrderItemSeller orderItem;

  const SalesOrderView({
    super.key,
    required this.orderItem,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16).rt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderStatusCard(
            status: orderItem.orderStatus,
            displayStatus: orderItem.statusDisplay,
          ),
          16.verticalGap,
          SalesProductCard(orderItem: orderItem),
          16.verticalGap,
          SalesOrderInfoCard(orderItem: orderItem),
          16.verticalGap,
          const ContactAdminInfo(),
        ],
      ),
    );
  }
}
