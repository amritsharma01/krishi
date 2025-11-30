import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/empty_state.dart';
import 'package:krishi/features/notifications/providers/notifications_providers.dart';
import 'package:krishi/features/notifications/widgets/delete_all_dialog.dart';
import 'package:krishi/features/notifications/widgets/notification_card.dart';
import 'package:krishi/features/notifications/widgets/notification_details_sheet.dart';
import 'package:krishi/features/notifications/widgets/notification_swipe_background.dart';
import 'package:krishi/models/app_notification.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications(markReadOnOpen: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !mounted) return;

    final isLoadingMore = ref.read(isLoadingMoreProvider);
    final hasMore = ref.read(hasMoreNotificationsProvider);
    final isLoading = ref.read(isLoadingNotificationsProvider);

    if (isLoadingMore || !hasMore || isLoading) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications({
    bool refresh = false,
    bool markReadOnOpen = false,
  }) async {
    if (!mounted) return;
    
    if (refresh) {
      if (markReadOnOpen) {
        ref.read(markedAllOnOpenProvider.notifier).state = false;
      }
      ref.read(currentPageProvider.notifier).state = 1;
      ref.read(hasMoreNotificationsProvider.notifier).state = true;
      ref.read(isLoadingNotificationsProvider.notifier).state = true;
      ref.read(isLoadingMoreProvider.notifier).state = false;
    } else {
      final currentPage = ref.read(currentPageProvider);
      if (currentPage == 1) {
        // First load
        ref.read(isLoadingNotificationsProvider.notifier).state = true;
      } else {
        // Loading more
        final isLoadingMore = ref.read(isLoadingMoreProvider);
        if (isLoadingMore) return;
        ref.read(isLoadingMoreProvider.notifier).state = true;
      }
    }

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(currentPageProvider);
      
      debugPrint('Loading notifications page: $currentPage');
      final response = await apiService.getNotifications(page: currentPage);

      if (!mounted) return;

      final notifications = ref.read(notificationsListProvider);
      if (currentPage == 1) {
        ref.read(notificationsListProvider.notifier).state = response.results;
      } else {
        ref.read(notificationsListProvider.notifier).state = [
          ...notifications,
          ...response.results,
        ];
      }
      
      ref.read(hasMoreNotificationsProvider.notifier).state = response.next != null;
      ref.read(currentPageProvider.notifier).state = currentPage + 1;
      ref.read(isLoadingNotificationsProvider.notifier).state = false;
      ref.read(isLoadingMoreProvider.notifier).state = false;

      if (markReadOnOpen) {
        await _markAllNotificationsOnOpen();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) {
        ref.read(isLoadingNotificationsProvider.notifier).state = false;
        ref.read(isLoadingMoreProvider.notifier).state = false;
        
        // Only show error if it's the initial load or a refresh
        final currentPage = ref.read(currentPageProvider);
        if (currentPage == 1 || refresh) {
          Get.snackbar('failed_to_load_notifications'.tr(context), color: Colors.red);
        }
      }
    }
  }

  Future<void> _markAllNotificationsOnOpen() async {
    if (!mounted) return;
    
    final markedAll = ref.read(markedAllOnOpenProvider);
    if (markedAll) return;

    ref.read(markedAllOnOpenProvider.notifier).state = true;

    try {
      await ref.read(krishiApiServiceProvider).markAllNotificationsAsRead();
      if (!mounted) return;

      final notifications = ref.read(notificationsListProvider);
      final updatedNotifications = notifications.map((n) {
        return n.copyWith(isRead: true, readAt: DateTime.now());
      }).toList();

      ref.read(notificationsListProvider.notifier).state = updatedNotifications;
      ref.read(unreadNotificationsProvider.notifier).resetToZero();
    } catch (e) {
      if (mounted) {
        ref.read(markedAllOnOpenProvider.notifier).state = false;
        Get.snackbar('failed_to_mark_notification'.tr(context));
      }
    }
  }

  Future<bool> _deleteNotification(
    AppNotification notification, {
    bool alreadyRemoved = false,
    int? fallbackIndex,
    bool showFeedback = true,
  }) async {
    if (!mounted) return false;
    
    final wasUnread = !notification.isRead;
    final unreadNotifier = ref.read(unreadNotificationsProvider.notifier);

    try {
      await ref.read(krishiApiServiceProvider).deleteNotification(notification.id);

      if (!mounted) return true;

      if (!alreadyRemoved) {
        final notifications = ref.read(notificationsListProvider);
        ref.read(notificationsListProvider.notifier).state =
            notifications.where((n) => n.id != notification.id).toList();
      }

      if (wasUnread) unreadNotifier.decrement();
      if (showFeedback && mounted) Get.snackbar('notification_deleted'.tr(context));
      return true;
    } on DioException catch (_) {
      return await _handleDeletionFallback(
        notification,
        wasUnread,
        alreadyRemoved,
        fallbackIndex,
        showFeedback,
      );
    } catch (_) {
      return await _handleDeletionFallback(
        notification,
        wasUnread,
        alreadyRemoved,
        fallbackIndex,
        showFeedback,
      );
    }
  }

  Future<bool> _handleDeletionFallback(
    AppNotification notification,
    bool wasUnread,
    bool alreadyRemoved,
    int? fallbackIndex,
    bool showFeedback,
  ) async {
    if (!mounted) return false;
    
    await _loadNotifications(refresh: true);
    if (!mounted) return false;
    
    final notifications = ref.read(notificationsListProvider);
    final stillExists = notifications.any((n) => n.id == notification.id);

    if (!stillExists) {
      if (wasUnread) {
        ref.read(unreadNotificationsProvider.notifier).decrement();
      }
      if (showFeedback && mounted) {
        Get.snackbar('notification_deleted'.tr(context));
      }
      return true;
    }

    if (alreadyRemoved && fallbackIndex != null && mounted) {
      final currentNotifications = ref.read(notificationsListProvider);
      final safeIndex = fallbackIndex.clamp(0, currentNotifications.length);
      final updated = List<AppNotification>.from(currentNotifications);
      updated.insert(safeIndex, notification);
      ref.read(notificationsListProvider.notifier).state = updated;
    }

    if (mounted) {
      Get.snackbar('failed_to_delete_notification'.tr(context));
    }
    return false;
  }

  Future<void> _deleteAllNotifications() async {
    if (!mounted) return;
    
    final notifications = ref.read(notificationsListProvider);
    final isDeletingAll = ref.read(isDeletingAllProvider);

    if (notifications.isEmpty || isDeletingAll) return;

    final confirmed = await DeleteAllNotificationsDialog.show(context);

    if (confirmed != true || !mounted) return;

    ref.read(isDeletingAllProvider.notifier).state = true;

    try {
      await ref.read(krishiApiServiceProvider).deleteAllReadNotifications();
      
      if (mounted) {
        // Force a complete refresh from page 1
        ref.read(currentPageProvider.notifier).state = 1;
        ref.read(hasMoreNotificationsProvider.notifier).state = true;
        ref.read(markedAllOnOpenProvider.notifier).state = false;
        
        await _loadNotifications(refresh: true);
        
        ref.read(isDeletingAllProvider.notifier).state = false;
        ref.read(unreadNotificationsProvider.notifier).resetToZero();
        Get.snackbar('notifications_cleared'.tr(context), color: Colors.green);
      }
    } catch (e) {
      debugPrint('Delete all notifications error: $e');
      
      if (mounted) {
        ref.read(isDeletingAllProvider.notifier).state = false;
        
        // Try to refresh to see actual state
        ref.read(currentPageProvider.notifier).state = 1;
        ref.read(hasMoreNotificationsProvider.notifier).state = true;
        await _loadNotifications(refresh: true);
        
        final updatedNotifications = ref.read(notificationsListProvider);
        if (updatedNotifications.isEmpty) {
          ref.read(unreadNotificationsProvider.notifier).resetToZero();
          Get.snackbar('notifications_cleared'.tr(context), color: Colors.green);
        } else {
          Get.snackbar('failed_to_delete_notification'.tr(context), color: Colors.red);
        }
      }
    }
  }

  void _handleSwipeDelete(AppNotification notification, int index) {
    if (!mounted) return;
    
    final pendingDeletes = ref.read(pendingSwipeDeletesProvider);
    if (pendingDeletes.contains(notification.id)) return;

    final notifications = ref.read(notificationsListProvider);
    final removedIndex = index.clamp(0, notifications.length - 1);

    ref.read(pendingSwipeDeletesProvider.notifier).state = {
      ...pendingDeletes,
      notification.id,
    };

    final updated = List<AppNotification>.from(notifications);
    updated.removeAt(index);
    ref.read(notificationsListProvider.notifier).state = updated;

    _deleteNotification(
      notification,
      alreadyRemoved: true,
      fallbackIndex: removedIndex,
      showFeedback: false,
    ).then((success) {
      if (!mounted) return;
      final current = ref.read(pendingSwipeDeletesProvider);
      ref.read(pendingSwipeDeletesProvider.notifier).state =
          current.where((id) => id != notification.id).toSet();
      if (success && mounted) {
        Get.snackbar('notification_deleted'.tr(context));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingNotificationsProvider);
    final notifications = ref.watch(notificationsListProvider);
    final isDeletingAll = ref.watch(isDeletingAllProvider);
    final hasNotifications = notifications.isNotEmpty;

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
              onPressed: isDeletingAll ? null : _deleteAllNotifications,
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : hasNotifications
          ? _buildNotificationsList()
          : EmptyState(
              title: 'no_notifications'.tr(context),
              subtitle: 'no_notifications_subtitle'.tr(context),
              icon: Icons.notifications_active_outlined,
            ),
    );
  }

  Widget _buildNotificationsList() {
    final notifications = ref.watch(notificationsListProvider);
    final isLoadingMore = ref.watch(isLoadingMoreProvider);

    return RefreshIndicator(
      onRefresh: () => _loadNotifications(refresh: true, markReadOnOpen: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: 24.ht),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: notifications.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == notifications.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.ht),
              child: Center(
                child: SizedBox(
                  height: 24.st,
                  width: 24.st,
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Get.primaryColor),
                  ),
                ),
              ),
            );
          }
          final notification = notifications[index];
          return Dismissible(
            key: ValueKey(notification.id),
            direction: DismissDirection.endToStart,
            background: const NotificationSwipeBackground(),
            onDismissed: (_) => _handleSwipeDelete(notification, index),
            child: NotificationCard(
              notification: notification,
              onTap: () => NotificationDetailsSheet.show(context, notification),
            ),
          );
        },
      ),
    );
  }
}
