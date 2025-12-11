import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/models/cart.dart';

/// Cart state provider
final cartProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<Cart?>>((ref) {
  return CartNotifier(ref);
});

class CartNotifier extends StateNotifier<AsyncValue<Cart?>> {
  final Ref ref;

  CartNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadCart();
  }

  Future<void> loadCart({bool silently = false}) async {
    if (!silently && mounted) {
      state = const AsyncValue.loading();
    }

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final cartData = await apiService.getCart();
      if (mounted) {
        state = AsyncValue.data(cartData);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  CartItem _copyCartItemWithQuantity(CartItem source, int quantity) {
    final subtotal = (source.unitPriceAsDouble * quantity).toStringAsFixed(2);
    return CartItem(
      id: source.id,
      product: source.product,
      productDetails: source.productDetails,
      quantity: quantity,
      unitPrice: source.unitPrice,
      subtotal: subtotal,
      createdAt: source.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Cart _copyCartWithItems(Cart cart, List<CartItem> items) {
    final total = items.fold<double>(
      0,
      (sum, current) => sum + current.subtotalAsDouble,
    );

    return Cart(
      id: cart.id,
      user: cart.user,
      items: items,
      totalAmount: total.toStringAsFixed(2),
      createdAt: cart.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity <= 0) return;

    final currentCart = state.valueOrNull;
    if (currentCart == null) return;

    // Optimistically update UI
    final updatedItems = currentCart.items.map((cartItem) {
      if (cartItem.id == item.id) {
        return _copyCartItemWithQuantity(cartItem, newQuantity);
      }
      return cartItem;
    }).toList();

    final optimisticCart = _copyCartWithItems(currentCart, updatedItems);
    state = AsyncValue.data(optimisticCart);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.updateCartItem(itemId: item.id, quantity: newQuantity);
      // Reload cart to get fresh data
      await loadCart(silently: true);
    } catch (e, stack) {
      // Revert on error
      if (mounted) {
        state = AsyncValue.error(e, stack);
        // Reload to get correct state
        await loadCart(silently: true);
      }
      rethrow;
    }
  }

  Future<void> removeItem(int itemId) async {
    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.removeCartItem(itemId);
      await loadCart();
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }

  /// Add item to cart and refresh
  Future<void> addItem(int productId, int quantity) async {
    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.addToCart(productId: productId, quantity: quantity);
      await loadCart();
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }
}

/// Provider that checks if a product is in the cart
final isProductInCartProvider = Provider.autoDispose.family<bool, int>((ref, productId) {
  final cartAsync = ref.watch(cartProvider);
  return cartAsync.maybeWhen(
    data: (cart) {
      if (cart == null) return false;
      return cart.items.any((item) => item.product == productId);
    },
    orElse: () => false,
  );
});

/// Updating item IDs provider
final updatingItemIdsProvider =
    StateProvider.autoDispose<Set<int>>((ref) => <int>{});

/// Deleting item IDs provider
final deletingItemIdsProvider =
    StateProvider.autoDispose<Set<int>>((ref) => <int>{});

