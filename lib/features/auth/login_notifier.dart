import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/core/services/storage_services/hive_keys.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/features/auth/logout_notifier.dart';
import 'package:krishi/features/navigation/main_navigation.dart';
import 'package:krishi/features/account/providers/user_profile_providers.dart';
import 'package:krishi/features/cart/providers/cart_providers.dart';
import 'package:krishi/features/cart/providers/checkout_providers.dart';
import 'package:flutter/material.dart';

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

  Future<void> signInWithGoogle(BuildContext context) async {
    if (state.isLoading) return; // Prevent double-tap
    if (!context.mounted) return;

    state = state.copyWith(isLoading: true);

    try {
      final authService = ref.read(authServiceProvider);
      final success = await authService.signInWithGoogle();

      if (mounted) {
        state = state.copyWith(isLoading: false);
      }

      if (!context.mounted) return;

      if (success) {
        // Reset logout provider state to ensure it's not stuck in loading state
        // This prevents the logout button from showing as loading when navigating to account page
        try {
          ref.read(logoutProvider.notifier).state = const LogoutState(
            isLoading: false,
          );
        } catch (e) {
          debugPrint('Error resetting logout state: $e');
        }

        // Invalidate persistent providers to ensure fresh data for the new account
        // Persistent StateNotifierProviders cache state and won't reload automatically
        ref.invalidate(userProfileProvider); // Persistent StateNotifierProvider
        ref.invalidate(cartProvider); // Persistent StateNotifierProvider
        ref.invalidate(checkoutStateProvider); // Persistent StateNotifierProvider
        
        // Invalidate StateProviders (these are lightweight, but ensures clean state)
        ref.invalidate(isUpdatingProfileProvider);
        ref.invalidate(selectedProfileImageProvider);
        
        // Auto-dispose providers will reload naturally when watched, but invalidating ensures immediate fresh data
        ref.invalidate(checkoutUserProfileProvider);

        // Ensure tab index is set to 0 (homepage) on login
        final storage = ref.read(storageServiceProvider);
        await storage.set(StorageKeys.currentTabIndex, 0);

        Get.snackbar('signin_success'.tr(context), color: AppColors.primary);
        Get.offAll(const MainNavigation());
      } else {
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
