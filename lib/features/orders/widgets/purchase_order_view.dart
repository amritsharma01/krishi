import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/features/orders/widgets/order_detail_widgets.dart';
import 'package:krishi/models/order.dart';

class PurchaseOrderView extends ConsumerWidget {
  final Order order;
  final bool isSeller;
  final bool isProcessing;
  final String? loadingPublicListingsId;
  final VoidCallback onDeleteOrder;
  final Function(String?, String) onOpenPublicListings;

  const PurchaseOrderView({
    super.key,
    required this.order,
    required this.isSeller,
    required this.isProcessing,
    required this.loadingPublicListingsId,
    required this.onDeleteOrder,
    required this.onOpenPublicListings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16).rt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderStatusCard(
            status: order.status,
            displayStatus: order.statusDisplay ?? _capitalize(order.status),
          ),
          16.verticalGap,
          OrderProductCard(order: order),
          16.verticalGap,
          OrderInfoCard(order: order),
          16.verticalGap,
          if (isSeller) ...[
            BuyerInfoCard(
              buyerKrId: order.buyerKrId,
              isLoading: loadingPublicListingsId == order.buyerKrId,
              onTap: () => onOpenPublicListings(
                order.buyerKrId,
                'buyer_public_listings',
              ),
            ),
            16.verticalGap,
          ],
          if (!isSeller && order.status.toLowerCase() == 'pending')
            DeleteOrderButton(
              isProcessing: isProcessing,
              onPressed: onDeleteOrder,
            ),
          if (!isSeller && order.status.toLowerCase() == 'pending')
            16.verticalGap,
          const ContactAdminInfo(),
        ],
      ),
    );
  }

  String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}
