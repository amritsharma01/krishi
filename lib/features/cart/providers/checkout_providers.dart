import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/services/cache_service.dart';
import 'package:krishi/models/user_profile.dart';

/// Checkout state provider
final checkoutStateProvider =
    StateNotifierProvider<CheckoutNotifier, AsyncValue<void>>((ref) {
      return CheckoutNotifier(ref);
    });

class CheckoutNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  CheckoutNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> processCheckout({
    required String buyerName,
    required String buyerAddress,
    required String buyerPhoneNumber,
    String? messageToSeller,
  }) async {
    state = const AsyncValue.loading();
    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.checkout(
        buyerName: buyerName,
        buyerAddress: buyerAddress,
        buyerPhoneNumber: buyerPhoneNumber,
        messageToSeller: messageToSeller,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// User profile for checkout (prefills form)
final checkoutUserProfileProvider = FutureProvider.autoDispose<User?>((
  ref,
) async {
  final cacheService = ref.read(cacheServiceProvider);
  final apiService = ref.read(krishiApiServiceProvider);

  try {
    // Try cached profile first
    final cachedProfile = await cacheService.getUserProfileCache();
    if (cachedProfile != null) {
      final user = User.fromJson(cachedProfile);
      // Update cache in background
      try {
        final freshUser = await apiService.getCurrentUser();
        await cacheService.saveUserProfileCache(freshUser.toJson());
        return freshUser;
      } catch (_) {
        // Return cached if fresh fetch fails
        return user;
      }
    }

    // Fetch fresh if no cache
    final freshUser = await apiService.getCurrentUser();
    await cacheService.saveUserProfileCache(freshUser.toJson());
    return freshUser;
  } catch (_) {
    // Return null if profile fetch fails; form remains editable
    return null;
  }
});
