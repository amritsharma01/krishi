import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/features/navigation/main_navigation.dart';
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
    if (!context.mounted) return;

    state = state.copyWith(isLoading: true);

    try {
      final authService = ref.read(authServiceProvider);
      final success = await authService.signInWithGoogle();

      if (!context.mounted) return;

      if (success) {
        // Authentication successful, navigate to home
        Get.offAll(const MainNavigation());

        // Show success message
        Get.snackbar('signin_success'.tr(context), color: AppColors.primary);
      } else {
        // User cancelled or authentication failed
        Get.snackbar('google_signin_cancelled'.tr(context));
      }
    } catch (e) {
      if (context.mounted) {
        Get.snackbar('${'google_signin_failed'.tr(context)}: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref);
});
