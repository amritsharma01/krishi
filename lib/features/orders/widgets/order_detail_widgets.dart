import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/order.dart';

class OrderStatusCard extends StatelessWidget {
  final String status;
  final String displayStatus;

  const OrderStatusCard({
    super.key,
    required this.status,
    required this.displayStatus,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bgColor, Color textColor, Color borderColor) =
        _getStatusColors(status.toLowerCase());

    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12).rt,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(_getStatusIcon(status.toLowerCase()),
                color: textColor, size: 24.st),
          ),
          16.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'order_status'.tr(context),
                  style: Get.bodySmall.px12.w500.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.6),
                  ),
                ),
                4.verticalGap,
                AppText(
                  displayStatus,
                  style: Get.bodyLarge.px18.w700.copyWith(color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color) _getStatusColors(String status) {
    switch (status) {
      case 'completed':
        return (
          Colors.green.withValues(alpha: 0.15),
          Colors.green.shade800,
          Colors.green.withValues(alpha: 0.3),
        );
      case 'approved':
        return (
          Colors.teal.withValues(alpha: 0.15),
          Colors.teal.shade800,
          Colors.teal.withValues(alpha: 0.3),
        );
      case 'rejected':
        return (
          Colors.red.withValues(alpha: 0.15),
          Colors.red.shade800,
          Colors.red.withValues(alpha: 0.3),
        );
      case 'accepted':
      case 'in_transit':
        return (
          Colors.blue.withValues(alpha: 0.15),
          Colors.blue.shade800,
          Colors.blue.withValues(alpha: 0.3),
        );
      case 'delivered':
        return (
          Colors.purple.withValues(alpha: 0.15),
          Colors.purple.shade800,
          Colors.purple.withValues(alpha: 0.3),
        );
      case 'cancelled':
        return (
          Colors.red.withValues(alpha: 0.15),
          Colors.red.shade800,
          Colors.red.withValues(alpha: 0.3),
        );
      case 'pending':
      default:
        return (
          Colors.orange.withValues(alpha: 0.15),
          Colors.orange.shade800,
          Colors.orange.withValues(alpha: 0.3),
        );
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'approved':
        return Icons.verified;
      case 'rejected':
        return Icons.block;
      case 'accepted':
        return Icons.thumb_up;
      case 'in_transit':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.schedule;
    }
  }
}

class OrderProductCard extends StatelessWidget {
  final Order order;

  const OrderProductCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'order_items'.tr(context),
            style: Get.bodyMedium.px16.w700.copyWith(color: Get.disabledColor),
          ),
          12.verticalGap,
          if (order.items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.rt),
              child: Center(
                child: AppText(
                  'order_awaiting_approval'.tr(context),
                  style: Get.bodySmall.px13.w500.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...order.items.map((item) => OrderItemRow(item: item)),
          if (order.items.isNotEmpty) 16.verticalGap,
          Divider(color: Get.disabledColor.withValues(alpha: 0.1)),
          12.verticalGap,
          PriceRow(label: 'subtotal'.tr(context), amount: order.subtotalAsDouble),
          if (order.approvedByAdmin && order.hasDeliveryCharges) ...[
            8.verticalGap,
            PriceRow(
              label: 'delivery_charges'.tr(context),
              amount: order.deliveryChargesAsDouble,
            ),
          ],
          if (!order.approvedByAdmin) ...[
            8.verticalGap,
            AppText(
              'awaiting_admin_approval'.tr(context),
              style: Get.bodySmall.px12.w500.copyWith(
                color: Colors.orange.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          12.verticalGap,
          Divider(
            color: Get.disabledColor.withValues(alpha: 0.2),
            thickness: 1.5,
          ),
          8.verticalGap,
          PriceRow(
            label: 'total'.tr(context),
            amount: order.totalAmountAsDouble,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class OrderItemRow extends StatelessWidget {
  final OrderItem item;

  const OrderItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final productDetails = item.productDetails;
    final imageUrl = productDetails?.image ?? '';
    final hasImage = imageUrl.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.rt),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8).rt,
            child: hasImage
                ? Image.network(
                    imageUrl,
                    width: 60.st,
                    height: 60.st,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
          12.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  item.productName,
                  style: Get.bodyMedium.px14.w600.copyWith(
                    color: Get.disabledColor,
                  ),
                  maxLines: 2,
                ),
                4.verticalGap,
                AppText(
                  '${item.quantity} x NPR ${item.unitPriceAsDouble.toStringAsFixed(2)}',
                  style: Get.bodySmall.px12.w500.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          AppText(
            'NPR ${item.totalPriceAsDouble.toStringAsFixed(2)}',
            style: Get.bodyMedium.px14.w700.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60.st,
      height: 60.st,
      color: Get.disabledColor.withValues(alpha: 0.1),
      child: Icon(
        Icons.shopping_bag,
        color: Get.disabledColor,
        size: 20.st,
      ),
    );
  }
}

class PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;

  const PriceRow({
    super.key,
    required this.label,
    required this.amount,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          style: isBold
              ? Get.bodyMedium.px15.w700.copyWith(color: Get.disabledColor)
              : Get.bodySmall.px13.w500.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.7),
                ),
        ),
        AppText(
          'NPR ${amount.toStringAsFixed(2)}',
          style: isBold
              ? Get.bodyMedium.px16.w700.copyWith(color: AppColors.primary)
              : Get.bodySmall.px13.w600.copyWith(color: Get.disabledColor),
        ),
      ],
    );
  }
}

class OrderInfoCard extends StatelessWidget {
  final Order order;

  const OrderInfoCard({super.key, required this.order});

  static final _dateFormat = DateFormat('MMM d, yyyy • h:mm a');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'order_information'.tr(context),
            style: Get.bodyMedium.px16.w700.copyWith(color: Get.disabledColor),
          ),
          12.verticalGap,
          InfoRow(label: 'order_id'.tr(context), value: '#${order.id}'),
          8.verticalGap,
          InfoRow(
            label: 'order_date'.tr(context),
            value: _dateFormat.format(order.createdAt.toLocal()),
          ),
          8.verticalGap,
          InfoRow(
            label: 'total_amount'.tr(context),
            value: 'NPR ${order.totalAmountAsDouble.toStringAsFixed(2)}',
            isBold: true,
          ),
          if (order.adminNotes != null && order.adminNotes!.isNotEmpty) ...[
            12.verticalGap,
            Divider(color: Get.disabledColor.withValues(alpha: 0.1)),
            12.verticalGap,
            AppText(
              'admin_notes'.tr(context),
              style: Get.bodyMedium.px14.w700.copyWith(
                color: Get.disabledColor,
              ),
            ),
            8.verticalGap,
            Container(
              padding: const EdgeInsets.all(12).rt,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8).rt,
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: AppText(
                order.adminNotes!,
                style: Get.bodySmall.px13.w500.copyWith(
                  color: Get.disabledColor,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120.st,
          child: AppText(
            label,
            style: Get.bodySmall.px13.w500.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: AppText(
            value,
            style: isBold
                ? Get.bodyMedium.px14.w700.copyWith(color: AppColors.primary)
                : Get.bodySmall.px13.w500.copyWith(color: Get.disabledColor),
          ),
        ),
      ],
    );
  }
}

class BuyerInfoCard extends StatelessWidget {
  final String? buyerKrId;
  final bool isLoading;
  final VoidCallback onTap;

  const BuyerInfoCard({
    super.key,
    required this.buyerKrId,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16).rt,
      child: Container(
        padding: const EdgeInsets.all(16).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(16).rt,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText(
                    'buyer_information'.tr(context),
                    style: Get.bodyMedium.px16.w700.copyWith(
                      color: Get.disabledColor,
                    ),
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 16.st,
                    height: 16.st,
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14.st,
                    color: Get.disabledColor.withValues(alpha: 0.3),
                  ),
              ],
            ),
            12.verticalGap,
            InfoRow(
              label: 'buyer_id_label'.tr(context),
              value: buyerKrId ?? 'seller_id_unavailable'.tr(context),
            ),
            8.verticalGap,
            AppText(
              'buyer_contact_hidden'.tr(context),
              style: Get.bodySmall.px12.w500.copyWith(
                color: Get.disabledColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactAdminInfo extends StatelessWidget {
  const ContactAdminInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12).rt,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18.st, color: Colors.blue.shade700),
          8.horizontalGap,
          Expanded(
            child: AppText(
              'order_edit_cancel_info'.tr(context),
              style: Get.bodySmall.px12.w500.copyWith(
                color: Colors.blue.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeleteOrderButton extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onPressed;

  const DeleteOrderButton({
    super.key,
    required this.isProcessing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(color: Colors.red.withValues(alpha: 0.2), width: 1),
      ),
      child: TextButton.icon(
        onPressed: isProcessing ? null : onPressed,
        icon: isProcessing
            ? SizedBox(
                width: 16.st,
                height: 16.st,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.red.shade700,
                  ),
                ),
              )
            : Icon(
                Icons.delete_outline,
                color: Colors.red.shade700,
                size: 20.st,
              ),
        label: AppText(
          'delete_order'.tr(context),
          style: Get.bodyMedium.px14.w600.copyWith(color: Colors.red.shade700),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16).rt,
        ),
      ),
    );
  }
}

class SalesProductCard extends StatelessWidget {
  final OrderItemSeller orderItem;

  const SalesProductCard({super.key, required this.orderItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'product_information'.tr(context),
            style: Get.bodyMedium.px16.w700.copyWith(color: Get.disabledColor),
          ),
          12.verticalGap,
          InfoRow(label: 'product_name'.tr(context), value: orderItem.productName),
          8.verticalGap,
          InfoRow(
            label: 'base_price'.tr(context),
            value: 'Rs. ${orderItem.basePriceAsDouble.toStringAsFixed(2)}',
          ),
          8.verticalGap,
          InfoRow(label: 'quantity'.tr(context), value: '${orderItem.quantity}'),
          12.verticalGap,
          Divider(
            color: Get.disabledColor.withValues(alpha: 0.2),
            thickness: 1.5,
          ),
          8.verticalGap,
          InfoRow(
            label: 'total'.tr(context),
            value: 'Rs. ${orderItem.totalPriceAsDouble.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class SalesOrderInfoCard extends StatelessWidget {
  final OrderItemSeller orderItem;

  const SalesOrderInfoCard({super.key, required this.orderItem});

  static final _dateFormat = DateFormat('MMM d, yyyy • h:mm a');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'order_information'.tr(context),
            style: Get.bodyMedium.px16.w700.copyWith(color: Get.disabledColor),
          ),
          12.verticalGap,
          InfoRow(label: 'order_id'.tr(context), value: '#${orderItem.orderId}'),
          8.verticalGap,
          InfoRow(
            label: 'order_date'.tr(context),
            value: _dateFormat.format(orderItem.orderDate.toLocal()),
          ),
        ],
      ),
    );
  }
}
