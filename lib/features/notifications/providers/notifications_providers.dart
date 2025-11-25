import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/services/api_services/krishi_api_service.dart';

final unreadNotificationsProvider = StateNotifierProvider<
    UnreadNotificationsNotifier, AsyncValue<int>>((ref) {
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
    state = const AsyncValue.loading();
    try {
      final count = await _apiService.getUnreadNotificationsCount();
      state = AsyncValue.data(count);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void decrement({int value = 1}) {
    state.whenData((count) {
      final nextCount = count - value;
      state = AsyncValue.data(nextCount < 0 ? 0 : nextCount);
    });
  }

  void resetToZero() {
    state = const AsyncValue.data(0);
  }

  void setCount(int count) {
    state = AsyncValue.data(count);
  }
}

