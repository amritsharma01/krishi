import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  static final _dateFormat = DateFormat('MMM d, yyyy • h:mm a');

  @override
  Widget build(BuildContext context) {
    final status = order.status.toLowerCase();
    final isCompleted = status == 'completed';
    final displayStatus =
        (order.statusDisplay != null && order.statusDisplay!.trim().isNotEmpty)
        ? order.statusDisplay!
        : _capitalize(order.status);
    final (Color bgColor, Color textColor, Color borderColor) =
        _getStatusColors(status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16).rt,
      child: Container(
        padding: const EdgeInsets.all(16).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(20).rt,
          border: Border.all(
            color: isCompleted
                ? bgColor
                : Get.disabledColor.withValues(alpha: 0.08),
            width: 1,
          ),
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
              '${'order_id'.tr(context)} #${order.id}',
              style: Get.bodyMedium.px16.w700.copyWith(
                color: Get.disabledColor,
              ),
            ),
            8.verticalGap,
            AppText(
              _dateFormat.format(order.createdAt.toLocal()),
              style: Get.bodySmall.px13.w500.copyWith(
                color: Get.disabledColor.withValues(alpha: 0.6),
              ),
            ),
            12.verticalGap,
            Wrap(
              spacing: 8.rt,
              runSpacing: 8.rt,
              children: [
                _StatusChip(
                  label: displayStatus,
                  bgColor: bgColor,
                  textColor: textColor,
                  borderColor: borderColor,
                ),
                _InfoChip(
                  icon: Icons.shopping_basket,
                  label: '${order.itemsCount} ${'items_count'.tr(context)}',
                ),
                _InfoChip(
                  label: 'Rs. ${order.totalAmountAsDouble.toStringAsFixed(2)}',
                ),
              ],
            ),
          ],
        ),
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

  String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}

class SalesOrderCard extends StatelessWidget {
  final OrderItemSeller orderItem;
  final VoidCallback onTap;

  const SalesOrderCard({
    super.key,
    required this.orderItem,
    required this.onTap,
  });

  static final _dateFormat = DateFormat('MMM d, yyyy • h:mm a');

  @override
  Widget build(BuildContext context) {
    final status = orderItem.orderStatus.toLowerCase();
    final isCompleted = status == 'completed';
    final displayStatus = orderItem.statusDisplay;
    final (Color bgColor, Color textColor, Color borderColor) =
        _getStatusColors(status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16).rt,
      child: Container(
        padding: const EdgeInsets.all(8).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(20).rt,
          border: Border.all(
            color: isCompleted
                ? bgColor
                : Get.disabledColor.withValues(alpha: 0.08),
            width: 1,
          ),
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
              orderItem.productName,
              style: Get.bodyMedium.px16.w700.copyWith(
                color: Get.disabledColor,
              ),
            ),
            6.verticalGap,
            AppText(
              _dateFormat.format(orderItem.orderDate.toLocal()),
              style: Get.bodySmall.px13.w500.copyWith(
                color: Get.disabledColor.withValues(alpha: 0.6),
              ),
            ),
            12.verticalGap,
            Wrap(
              spacing: 8.rt,
              runSpacing: 8.rt,
              children: [
                _StatusChip(
                  label: displayStatus,
                  bgColor: bgColor,
                  textColor: textColor,
                  borderColor: borderColor,
                ),
                _InfoChip(
                  icon: Icons.shopping_bag,
                  label: '${'order_id'.tr(context)} #${orderItem.orderId}',
                ),
                _InfoChip(
                  label:
                      'Rs. ${(orderItem.basePriceAsDouble * orderItem.quantity).toStringAsFixed(2)}',
                ),
                _InfoChip(
                  icon: Icons.production_quantity_limits,
                  label: 'Qty: ${orderItem.quantity}',
                ),
              ],
            ),
          ],
        ),
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
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;

  const _StatusChip({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6).rt,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: AppText(
        label,
        style: Get.bodySmall.px12.w700.copyWith(color: textColor),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData? icon;
  final String label;

  const _InfoChip({this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 16.st,
              color: Get.disabledColor.withValues(alpha: 0.7),
            ),
          if (icon != null) 6.horizontalGap,
          AppText(
            label,
            style: Get.bodySmall.px12.w600.copyWith(color: Get.disabledColor),
          ),
        ],
      ),
    );
  }
}
