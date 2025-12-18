import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/core/services/cache_service.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/services/storage_services/hive_keys.dart';
import 'package:krishi/features/auth/login_page.dart';
import 'package:krishi/features/cart/providers/cart_providers.dart';
import 'package:krishi/features/cart/providers/checkout_providers.dart';

class LogoutState {
  final bool isLoading;

  const LogoutState({this.isLoading = false});

  LogoutState copyWith({bool? isLoading}) {
    return LogoutState(isLoading: isLoading ?? this.isLoading);
  }
}

class LogoutNotifier extends StateNotifier<LogoutState> {
  final Ref ref;

  LogoutNotifier(this.ref) : super(const LogoutState());

  /// Invalidates auth service and persistent user-specific data providers
  /// Only persistent providers (StateNotifierProvider without autoDispose) need invalidation
  /// Auto-dispose providers will naturally reload when watched again
  void _invalidateAuthState() {
    ref.invalidate(authServiceProvider);
    // Invalidate persistent providers that cache state in memory
    // These won't automatically reload when tokens change
    ref.invalidate(cartProvider); // Persistent StateNotifierProvider
    ref.invalidate(checkoutStateProvider); // Persistent StateNotifierProvider
    // Note: checkoutUserProfileProvider is auto-dispose, so it will reload naturally
    // But invalidating it ensures immediate fresh data
    ref.invalidate(checkoutUserProfileProvider);
  }

  Future<void> signOut(BuildContext context) async {
    if (state.isLoading) return;
    if (!context.mounted) return;

    state = state.copyWith(isLoading: true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.logout();

      // Clear saved tab index to reset to homepage on next login
      final storage = ref.read(storageServiceProvider);
      await storage.set(StorageKeys.currentTabIndex, 0);

      // Clear cached user profile data
      try {
        final cacheService = ref.read(cacheServiceProvider);
        await cacheService.clearUserProfileCache();
      } catch (e) {
        debugPrint('Error clearing profile cache: $e');
      }

      // Invalidate auth service to ensure state refresh
      // Other providers will naturally fail/return empty when there's no token
      _invalidateAuthState();

      if (!context.mounted) return;

      // Reset loading state BEFORE navigation to prevent state from persisting
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }

      // Show success message
      Get.snackbar('signout_success'.tr(context), color: AppColors.primary);

      // Navigate to login page using post-frame callback
      // This ensures navigation happens after Core widget has finished rebuilding
      // This prevents the double navigation issue (login page showing, popping, then showing again)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Get.offAll(const LoginPage());
        }
      });
    } catch (e) {
      debugPrint('Sign-Out Error: $e');
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
      if (context.mounted) {
        final errorMessage = e is TimeoutException
            ? 'Logout timed out. Please try again.'
            : '${'signout_failed'.tr(context)}: ${e.toString()}';
        Get.snackbar(errorMessage, color: Colors.red);
      }
    }
  }
}

final logoutProvider = StateNotifierProvider<LogoutNotifier, LogoutState>((
  ref,
) {
  return LogoutNotifier(ref);
});
