import 'package:flutter/material.dart';

class NotificationHelpers {
  static Color getTypeColor(String type) {
    switch (type) {
      case 'order':
      case 'order_status':
        return Colors.orange;
      case 'product':
      case 'inventory':
        return Colors.green;
      case 'review':
      case 'comment':
        return Colors.blue;
      case 'system':
      case 'announcement':
        return Colors.purple;
      default:
        return Colors.blueGrey;
    }
  }

  static IconData getTypeIcon(String type) {
    switch (type) {
      case 'order':
      case 'order_status':
        return Icons.receipt_long_rounded;
      case 'product':
      case 'inventory':
        return Icons.storefront_rounded;
      case 'review':
      case 'comment':
        return Icons.rate_review_rounded;
      case 'system':
      case 'announcement':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }
}
