import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/notifications/widgets/notification_helpers.dart';
import 'package:krishi/models/app_notification.dart';

class NotificationDetailsSheet extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetailsSheet({super.key, required this.notification});

  static void show(BuildContext context, AppNotification notification) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Get.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.rt)),
      ),
      builder: (context) => NotificationDetailsSheet(notification: notification),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = NotificationHelpers.getTypeColor(notification.notificationType);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.wt, vertical: 10.ht),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.wt, vertical: 6.ht),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20).rt,
                ),
                child: AppText(
                  notification.notificationTypeDisplay,
                  style: Get.bodySmall.px12.w600.copyWith(color: typeColor),
                ),
              ),
              const Spacer(),
              AppText(
                DateFormat('MMM d, yyyy • h:mm a').format(notification.createdAt),
                style: Get.bodySmall.px10.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          16.verticalGap,
          AppText(notification.title, style: Get.bodyLarge.px14.w700),
          6.verticalGap,
          AppText(
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            notification.message,
            style: Get.bodyMedium.px12.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          20.verticalGap,
        ],
      ),
    );
  }
}
