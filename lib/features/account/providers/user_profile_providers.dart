import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/models/user_profile.dart';

// User profile state provider
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<User>>((ref) {
      return UserProfileNotifier(ref);
    });

class UserProfileNotifier extends StateNotifier<AsyncValue<User>> {
  final Ref ref;
  int _retryCount = 0;
  static const int _maxRetries = 5; // Increased retries for better reliability

  UserProfileNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile({bool isRetry = false}) async {
    if (!mounted) return;

    // Only set loading state if not retrying (to avoid flickering)
    if (!isRetry) {
      state = const AsyncValue.loading();
    }

    try {
      // Add a delay to ensure API service is ready with new tokens
      // This is especially important when logging in with a new account
      // Increase delay on retries to give more time for API service to be ready
      final delay = isRetry
          ? Duration(milliseconds: 300 * _retryCount)
          : const Duration(milliseconds: 200);
      await Future.delayed(delay);

      if (!mounted) return;

      final apiService = ref.read(krishiApiServiceProvider);

      // Fetch fresh data
      final user = await apiService.getCurrentUser();
      if (mounted) {
        state = AsyncValue.data(user);
        _retryCount = 0; // Reset retry count on success
      }
    } catch (e, stack) {
      if (mounted) {
        // Auto-retry on error (useful when logging in with new account)
        if (_retryCount < _maxRetries) {
          _retryCount++;
          // Retry after a delay, with exponential backoff
          await Future.delayed(Duration(milliseconds: 300 * _retryCount));
          if (mounted) {
            await loadProfile(isRetry: true);
            return;
          }
        }
        state = AsyncValue.error(e, stack);
        _retryCount = 0; // Reset retry count
      }
    }
  }

  Future<void> refresh() async {
    _retryCount = 0; // Reset retry count on manual refresh
    await loadProfile();
  }
}

// Profile update state provider
final isUpdatingProfileProvider = StateProvider<bool>((ref) => false);

// Selected image provider
final selectedProfileImageProvider = StateProvider<File?>((ref) => null);
