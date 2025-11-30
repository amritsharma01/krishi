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

class StatusCard extends StatelessWidget {
  final String status;
  final String displayStatus;

  const StatusCard({
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

class OrderInfoCard extends StatelessWidget {
  final int orderId;
  final DateTime createdAt;
  final double totalAmount;
  final String? adminNotes;

  const OrderInfoCard({
    super.key,
    required this.orderId,
    required this.createdAt,
    required this.totalAmount,
    this.adminNotes,
  });

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
          InfoRow(label: 'order_id'.tr(context), value: '#$orderId'),
          8.verticalGap,
          InfoRow(
            label: 'order_date'.tr(context),
            value: _dateFormat.format(createdAt.toLocal()),
          ),
          8.verticalGap,
          InfoRow(
            label: 'total_amount'.tr(context),
            value: 'NPR ${totalAmount.toStringAsFixed(2)}',
            isBold: true,
          ),
          if (adminNotes != null && adminNotes!.isNotEmpty) ...[
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
                adminNotes!,
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