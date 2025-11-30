import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/features/navigation/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:krishi/features/account/providers/user_profile_providers.dart';
import 'package:krishi/features/notifications/providers/notifications_providers.dart';
import 'package:krishi/features/marketplace/providers/marketplace_providers.dart';

class LoginState {
  final bool isLoading;

  const LoginState({this.isLoading = false});

  LoginState copyWith({bool? isLoading}) {
    return LoginState(isLoading: isLoading ?? this.isLoading);
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  final Ref ref;

  LoginNotifier(this.ref) : super(const LoginState());

  /// Invalidates all user-related providers to ensure fresh data
  void _invalidateAllUserData() {
    // IMPORTANT: Invalidate API service FIRST to ensure fresh auth token
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
    
    // Marketplace providers - reset state providers
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
    
    // Note: categoriesProvider and unitsProvider are autoDispose and don't need
    // invalidation as they'll refetch automatically when accessed
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    if (state.isLoading) return; // Prevent double-tap
    if (!context.mounted) return;

    state = state.copyWith(isLoading: true);

    try {
      final authService = ref.read(authServiceProvider);

      // Check if authService is null or not ready

      final success = await authService.signInWithGoogle();

      // Reset loading state BEFORE navigation
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }

      if (!context.mounted) return;

      if (success) {
        // Invalidate ONLY AFTER successful sign-in to fetch new user's data
        _invalidateAllUserData();

        // Small delay to ensure providers are refreshed
        await Future.delayed(const Duration(milliseconds: 200));

        // Show success message first
        Get.snackbar('signin_success'.tr(context), color: AppColors.primary);

        // Then navigate (this unmounts the widget)
        Get.offAll(const MainNavigation());
      } else {
        // User cancelled or authentication failed
        Get.snackbar('google_signin_cancelled'.tr(context));
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
      if (context.mounted) {
        Get.snackbar('${'google_signin_failed'.tr(context)}: ${e.toString()}');
      }
    }
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref);
});
