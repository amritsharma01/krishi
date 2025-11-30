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

  UserProfileNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    try {
      final apiService = ref.read(krishiApiServiceProvider);

      // Fetch fresh data
      final user = await apiService.getCurrentUser();
      if (mounted) {
        state = AsyncValue.data(user);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<void> refresh() async {
    await loadProfile();
  }
}

// Profile update state provider
final isUpdatingProfileProvider = StateProvider<bool>((ref) => false);

// Selected image provider
final selectedProfileImageProvider = StateProvider<File?>((ref) => null);
