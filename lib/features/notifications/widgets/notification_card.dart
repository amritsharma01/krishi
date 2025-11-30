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

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = NotificationHelpers.getTypeColor(notification.notificationType);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.wt, vertical: 5.ht),
      child: Container(
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(20).rt,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(50).rt,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(10.rt),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 30.st,
                  width: 30.st,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14).rt,
                  ),
                  child: Icon(
                    NotificationHelpers.getTypeIcon(notification.notificationType),
                    color: typeColor,
                  ),
                ),
                14.horizontalGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        notification.title,
                        style: Get.bodyLarge.px12.w600.copyWith(
                          color: Get.disabledColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      2.verticalGap,
                      AppText(
                        notification.message,
                        style: Get.bodyMedium.px10.copyWith(
                          color: Get.disabledColor.withValues(alpha: 0.8),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                8.horizontalGap,
                AppText(
                  DateFormat('MMM d').format(notification.createdAt),
                  style: Get.bodySmall.copyWith(
                    fontSize: 10.st,
                    color: Get.disabledColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
