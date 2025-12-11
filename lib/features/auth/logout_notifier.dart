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
import 'package:krishi/features/account/providers/user_profile_providers.dart';
import 'package:krishi/features/notifications/providers/notifications_providers.dart';
import 'package:krishi/features/marketplace/providers/marketplace_providers.dart';
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

  /// Invalidates all user-related providers to clear cached data
  void _invalidateAllUserData() {
    // FIRST: Invalidate core providers to clear auth tokens
    ref.invalidate(krishiApiServiceProvider);
    ref.invalidate(authServiceProvider);

    // User profile providers
    ref.invalidate(userProfileProvider);
    ref.invalidate(isUpdatingProfileProvider);
    ref.invalidate(selectedProfileImageProvider);

    // Notification providers
    ref.invalidate(unreadNotificationsProvider);
    ref.invalidate(notificationsListProvider);
    ref.invalidate(isLoadingNotificationsProvider);
    ref.invalidate(isLoadingMoreProvider);
    ref.invalidate(hasMoreNotificationsProvider);
    ref.invalidate(currentPageProvider);
    ref.invalidate(isDeletingAllProvider);
    ref.invalidate(pendingSwipeDeletesProvider);
    ref.invalidate(markedAllOnOpenProvider);

    // Marketplace providers
    ref.invalidate(isMarketplaceBuyTabProvider);
    ref.invalidate(buyProductsProvider);
    ref.invalidate(userListingsProvider);
    ref.invalidate(isLoadingBuyProductsProvider);
    ref.invalidate(isLoadingUserListingsProvider);
    ref.invalidate(selectedCategoryIdProvider);
    ref.invalidate(sellStatusFilterProvider);
    ref.invalidate(buyCurrentPageProvider);
    ref.invalidate(buyHasMoreProvider);
    ref.invalidate(isLoadingMoreBuyProductsProvider);
    ref.invalidate(sellCurrentPageProvider);
    ref.invalidate(sellHasMoreProvider);
    ref.invalidate(isLoadingMoreUserListingsProvider);

    // Cart providers
    ref.invalidate(cartProvider);
    ref.invalidate(updatingItemIdsProvider);
    ref.invalidate(deletingItemIdsProvider);

    // Checkout providers
    ref.invalidate(checkoutStateProvider);
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

      // Clear all cached user data AFTER signing out
      _invalidateAllUserData();

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
