import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/utils/app_icons.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/notifications/notifications_page.dart';
import 'package:krishi/features/notifications/providers/notifications_providers.dart';

import 'appicon.dart';

class NotificationIcon extends ConsumerWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadState = ref.watch(unreadNotificationsProvider);

    return unreadState.when(
      data: (count) => _buildIcon(context, ref, count),
      loading: () => _buildIcon(context, ref, null, isLoading: true),
      error: (_, __) => _buildIcon(context, ref, 0),
    );
  }

  Widget _buildIcon(
    BuildContext context,
    WidgetRef ref,
    int? count, {
    bool isLoading = false,
  }) {
    final unreadCount = count ?? 0;
    final hasUnread = unreadCount > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppIcon(
          AppIcons.notification,
          key: Get.key('${Get.brightness}_${unreadCount}_$isLoading'),
          size: 20,
          onTap: () => _openNotifications(context, ref),
          color: Get.disabledColor.o5,
        ),
        Positioned(
          top: -4.rt,
          right: -4.rt,
          child: isLoading
              ? SizedBox(
                  height: 16.st,
                  width: 16.st,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Get.primaryColor,
                  ),
                )
              : hasUnread
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: unreadCount > 9 ? 5.wt : 4.wt,
                        vertical: 2.ht,
                      ),
                      decoration: BoxDecoration(
                        color: Get.primaryColor,
                        borderRadius: BorderRadius.circular(12.rt),
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: Get.bodyMedium.px10.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Future<void> _openNotifications(BuildContext context, WidgetRef ref) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsPage(),
      ),
    );
    await ref.read(unreadNotificationsProvider.notifier).refresh();
  }
}
