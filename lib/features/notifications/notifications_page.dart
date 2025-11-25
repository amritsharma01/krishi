import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/notifications/providers/notifications_providers.dart';
import 'package:krishi/models/app_notification.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final List<AppNotification> _notifications = [];
  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _markedAllOnOpen = false;
  bool _isDeletingAll = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadNotifications(markReadOnOpen: true);
  }

  Future<void> _loadNotifications({
    bool refresh = false,
    bool markReadOnOpen = false,
  }) async {
    if (refresh && markReadOnOpen) {
      _markedAllOnOpen = false;
    }
    if (_loadingMore && !refresh) return;
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
      });
    } else if (!_initialLoading) {
      setState(() {
        _loadingMore = true;
      });
    }

    try {
      final response = await ref
          .read(krishiApiServiceProvider)
          .getNotifications(page: _currentPage);

      setState(() {
        if (_currentPage == 1) {
          _notifications
            ..clear()
            ..addAll(response.results);
        } else {
          _notifications.addAll(response.results);
        }
        _hasMore = response.next != null;
        _currentPage += 1;
        _initialLoading = false;
        _loadingMore = false;
      });

      if (markReadOnOpen && !_markedAllOnOpen) {
        await _markAllNotificationsOnOpen();
      }
    } catch (e) {
      setState(() {
        _initialLoading = false;
        _loadingMore = false;
      });
      if (mounted) {
        Get.snackbar('failed_to_load_notifications'.tr(context));
      }
    }
  }

  Future<void> _markAllNotificationsOnOpen() async {
    if (_markedAllOnOpen) return;
    _markedAllOnOpen = true;

    try {
      await ref.read(krishiApiServiceProvider).markAllNotificationsAsRead();
      if (!mounted) return;
      setState(() {
        for (var i = 0; i < _notifications.length; i++) {
          _notifications[i] =
              _notifications[i].copyWith(isRead: true, readAt: DateTime.now());
        }
      });
      ref.read(unreadNotificationsProvider.notifier).resetToZero();
    } catch (e) {
      _markedAllOnOpen = false;
      if (mounted) {
        Get.snackbar('failed_to_mark_notification'.tr(context));
      }
    }
  }

  Future<bool> _deleteNotification(AppNotification notification) async {
    final wasUnread = !notification.isRead;
    final unreadNotifier = ref.read(unreadNotificationsProvider.notifier);

    try {
      await ref
          .read(krishiApiServiceProvider)
          .deleteNotification(notification.id);

      if (!mounted) return true;
      setState(() {
        _notifications.removeWhere((n) => n.id == notification.id);
      });
      if (wasUnread) {
        unreadNotifier.decrement();
      }
      Get.snackbar('notification_deleted'.tr(context));
      return true;
    } on DioException catch (_) {
      final refreshed = await _refreshAfterDeletionFallback(notification.id);
      if (refreshed) {
        if (wasUnread) {
          unreadNotifier.decrement();
        }
        Get.snackbar('notification_deleted'.tr(context));
        return true;
      }
      if (mounted) {
        Get.snackbar('failed_to_delete_notification'.tr(context));
      }
      return false;
    } catch (_) {
      final refreshed = await _refreshAfterDeletionFallback(notification.id);
      if (refreshed) {
        if (wasUnread) {
          unreadNotifier.decrement();
        }
        Get.snackbar('notification_deleted'.tr(context));
        return true;
      }
      if (mounted) {
        Get.snackbar('failed_to_delete_notification'.tr(context));
      }
      return false;
    }
  }

  Future<bool> _refreshAfterDeletionFallback(int notificationId) async {
    await _loadNotifications(refresh: true);
    return !_notifications.any((n) => n.id == notificationId);
  }

  Future<void> _deleteAllNotifications() async {
    if (_notifications.isEmpty || _isDeletingAll) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_all_notifications'.tr(context)),
        content: Text('delete_all_notifications_warning'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr(context)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('delete'.tr(context)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeletingAll = true);
    try {
      await ref.read(krishiApiServiceProvider).deleteAllReadNotifications();
      if (!mounted) return;
      setState(() {
        _notifications.clear();
        _isDeletingAll = false;
      });
      ref.read(unreadNotificationsProvider.notifier).resetToZero();
      Get.snackbar('notifications_cleared'.tr(context));
    } catch (e) {
      if (mounted) {
        setState(() => _isDeletingAll = false);
        Get.snackbar('failed_to_delete_notification'.tr(context));
      }
    }
  }

  void _showNotificationDetails(AppNotification notification) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Get.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.rt)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.wt, vertical: 24.ht),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.wt, vertical: 6.ht),
                    decoration: BoxDecoration(
                      color: _getTypeColor(notification.notificationType)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20).rt,
                    ),
                    child: AppText(
                      notification.notificationTypeDisplay,
                      style: Get.bodySmall.px12.w600.copyWith(
                        color: _getTypeColor(notification.notificationType),
                      ),
                    ),
                  ),
                  const Spacer(),
                  AppText(
                    DateFormat('MMM d, yyyy • h:mm a')
                        .format(notification.createdAt),
                    style: Get.bodySmall.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              16.verticalGap,
              AppText(
                notification.title,
                style: Get.bodyLarge.px18.w700,
              ),
              12.verticalGap,
              AppText(
                notification.message,
                style: Get.bodyMedium.px14.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              20.verticalGap,
            ],
          ),
        );
      },
    );
  }

  Color _getTypeColor(String type) {
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
        return Get.primaryColor;
    }
  }

  IconData _getTypeIcon(String type) {
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

  @override
  Widget build(BuildContext context) {
    final hasNotifications = _notifications.isNotEmpty;

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'notifications'.tr(context),
          style: Get.bodyLarge.px18.w600.copyWith(color: Colors.white),
        ),
        backgroundColor: Get.primaryColor,
        centerTitle: true,
        elevation: 0,
        actions: [
          if (hasNotifications)
            IconButton(
              tooltip: 'delete_all_notifications'.tr(context),
              onPressed: _isDeletingAll ? null : _deleteAllNotifications,
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
            ),
        ],
      ),
      body: _initialLoading
          ? const Center(child: CircularProgressIndicator())
          : hasNotifications
              ? _buildNotificationsList()
              : _buildEmptyState(),
    );
  }

  Widget _buildNotificationsList() {
    return RefreshIndicator(
      onRefresh: () => _loadNotifications(
        refresh: true,
        markReadOnOpen: true,
      ),
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 24.ht),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _notifications.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            return _buildLoadMoreButton();
          }
          final notification = _notifications[index];
          return Dismissible(
            key: ValueKey(notification.id),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.wt, vertical: 8.ht),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20).rt,
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 24.wt),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.shade400,
              ),
            ),
            confirmDismiss: (_) => _deleteNotification(notification),
            child: _buildNotificationCard(notification),
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    if (!_hasMore) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.wt, vertical: 8.ht),
      child: ElevatedButton(
        onPressed: _loadingMore ? null : () => _loadNotifications(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Get.primaryColor,
          minimumSize: const Size(double.infinity, 48),
        ),
        child: _loadingMore
            ? SizedBox(
                height: 18.st,
                width: 18.st,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : AppText(
                'load_more'.tr(context),
                style: Get.bodyMedium.copyWith(color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final typeColor = _getTypeColor(notification.notificationType);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.wt, vertical: 8.ht),
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
          borderRadius: BorderRadius.circular(20).rt,
          onTap: () => _showNotificationDetails(notification),
          child: Padding(
            padding: EdgeInsets.all(16.rt),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 42.st,
                      width: 42.st,
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14).rt,
                      ),
                      child: Icon(
                        _getTypeIcon(notification.notificationType),
                        color: typeColor,
                      ),
                    ),
                    12.horizontalGap,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            notification.title,
                            style: Get.bodyLarge.px15.w600.copyWith(
                              color: Get.disabledColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          6.verticalGap,
                          AppText(
                            notification.message,
                            style: Get.bodyMedium.copyWith(
                              color: Get.disabledColor.withValues(alpha: 0.8),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    8.horizontalGap,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppText(
                          DateFormat('MMM d').format(notification.createdAt),
                          style: Get.bodySmall.copyWith(
                            color: Get.disabledColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.wt),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.rt),
              decoration: BoxDecoration(
                color: Get.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                size: 48.st,
                color: Get.primaryColor,
              ),
            ),
            20.verticalGap,
            AppText(
              'no_notifications'.tr(context),
              style: Get.bodyLarge.px18.w600,
            ),
            8.verticalGap,
            AppText(
              'no_notifications_subtitle'.tr(context),
              style: Get.bodyMedium.copyWith(
                color: Get.disabledColor.withValues(alpha: 0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

