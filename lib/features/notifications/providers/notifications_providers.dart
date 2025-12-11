import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/services/api_services/krishi_api_service.dart';
import 'package:krishi/models/app_notification.dart';

// Unread count provider (existing - keep as is)
final unreadNotificationsProvider =
    StateNotifierProvider<UnreadNotificationsNotifier, AsyncValue<int>>((ref) {
      final apiService = ref.read(krishiApiServiceProvider);
      return UnreadNotificationsNotifier(apiService);
    });

class UnreadNotificationsNotifier extends StateNotifier<AsyncValue<int>> {
  UnreadNotificationsNotifier(this._apiService)
    : super(const AsyncValue.loading()) {
    refresh();
  }

  final KrishiApiService _apiService;

  Future<void> refresh() async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    try {
      final count = await _apiService.getUnreadNotificationsCount();
      if (mounted) {
        state = AsyncValue.data(count);
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  void decrement({int value = 1}) {
    if (!mounted) return;
    state.whenData((count) {
      if (mounted) {
        final nextCount = count - value;
        state = AsyncValue.data(nextCount < 0 ? 0 : nextCount);
      }
    });
  }

  void resetToZero() {
    if (!mounted) return;
    state = const AsyncValue.data(0);
  }

  void setCount(int count) {
    if (!mounted) return;
    state = AsyncValue.data(count);
  }
}

// New providers for notifications page
final notificationsListProvider = StateProvider<List<AppNotification>>(
  (ref) => [],
);
final isLoadingNotificationsProvider = StateProvider<bool>((ref) => true);
final isLoadingMoreProvider = StateProvider<bool>((ref) => false);
final hasMoreNotificationsProvider = StateProvider<bool>((ref) => true);
final currentPageProvider = StateProvider<int>((ref) => 1);
final isDeletingAllProvider = StateProvider<bool>((ref) => false);
final pendingSwipeDeletesProvider = StateProvider<Set<int>>((ref) => {});
final markedAllOnOpenProvider = StateProvider<bool>((ref) => false);
