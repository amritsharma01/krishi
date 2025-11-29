import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/cart/checkout_page.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/empty_state.dart';
import 'package:krishi/features/components/error_state.dart';
import 'package:krishi/models/cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  Cart? cart;
  bool isLoading = true;
  String? error;
  final Set<int> _updatingItemIds = {};
  final Set<int> _deletingItemIds = {};

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart({bool silently = false}) async {
    if (!silently) {
      setState(() {
        isLoading = true;
        error = null;
      });
    }

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final cartData = await apiService.getCart();
      if (mounted) {
        setState(() {
          cart = cartData;
          error = null;
          if (!silently) {
            isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          if (!silently) {
            isLoading = false;
          }
        });
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

  Cart _copyCartWithItems(List<CartItem> items) {
    final total = items.fold<double>(
      0,
      (sum, current) => sum + current.subtotalAsDouble,
    );

    return Cart(
      id: cart!.id,
      user: cart!.user,
      items: items,
      totalAmount: total.toStringAsFixed(2),
      createdAt: cart!.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity <= 0 || _updatingItemIds.contains(item.id)) return;
    if (cart == null) return;

    final updatedItems = cart!.items.map((cartItem) {
      if (cartItem.id == item.id) {
        return _copyCartItemWithQuantity(cartItem, newQuantity);
      }
      return cartItem;
    }).toList();

    setState(() {
      _updatingItemIds.add(item.id);
      cart = _copyCartWithItems(updatedItems);
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.updateCartItem(itemId: item.id, quantity: newQuantity);
      await _loadCart(silently: true);
    } catch (e) {
      Get.snackbar(
        'error_updating_quantity'.tr(Get.context),
        color: Colors.red,
      );
      await _loadCart(silently: true);
    } finally {
      if (mounted) {
        setState(() {
          _updatingItemIds.remove(item.id);
        });
      }
    }
  }

  Future<void> _removeItem(int itemId) async {
    if (_deletingItemIds.contains(itemId)) return;

    setState(() {
      _deletingItemIds.add(itemId);
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.removeCartItem(itemId);
      await _loadCart();
      if (mounted) {
        Get.snackbar('item_removed'.tr(Get.context), color: Colors.green);
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('error_removing_item'.tr(Get.context), color: Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _deletingItemIds.remove(itemId);
        });
      }
    }
  }

  void _navigateToCheckout() {
    if (cart == null || cart!.items.isEmpty) return;
    Get.to(CheckoutPage(cart: cart!)).then((_) {
      // Reload cart after returning from checkout
      _loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        title: AppText(
          'my_cart'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.disabledColor),
          onPressed: () => Get.pop(),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: cart != null && cart!.items.isNotEmpty
          ? _buildCheckoutBar()
          : null,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (error != null) {
      return ErrorState(
        subtitle: 'error_loading_cart_subtitle'.tr(context),
        onRetry: _loadCart,
      );
    }

    if (cart == null || cart!.items.isEmpty) {
      return EmptyState(
        title: 'empty_cart'.tr(context),
        subtitle: 'start_shopping'.tr(context),
        icon: Icons.shopping_cart_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadCart(silently: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 6).rt,
        itemCount: cart!.items.length,
        itemBuilder: (context, index) {
          return _buildCartItem(cart!.items[index]);
        },
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    final product = item.productDetails;
    if (product == null) return const SizedBox.shrink();
    final isUpdating = _updatingItemIds.contains(item.id);
    final isDeleting = _deletingItemIds.contains(item.id);

    return Container(
      margin: EdgeInsets.only(bottom: 5.rt),
      padding: const EdgeInsets.all(8).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(
          color: Get.disabledColor.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 70.rt,
            height: 70.rt,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12).rt,
            ),
            child: product.image != null && product.image!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12).rt,
                    child: Builder(
                      builder: (context) {
                        final imageUrl = Get.imageUrl(product.image);

                        if (imageUrl.isEmpty) {
                          return Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.primary.withValues(alpha: 0.3),
                              size: 32.st,
                            ),
                          );
                        }
                        return Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppColors.primary.withValues(alpha: 0.3),
                                size: 32.st,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 20.st,
                                height: 20.st,
                                child: CircularProgressIndicator.adaptive(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppColors.primary.withValues(alpha: 0.3),
                      size: 32.st,
                    ),
                  ),
          ),
          16.horizontalGap,
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  product.name,
                  style: Get.bodyMedium.px14.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                  maxLines: 1,
                ),

                Row(
                  children: [
                    AppText(
                      'Rs. ${item.unitPrice}',
                      style: Get.bodyMedium.px08.w700.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    AppText(
                      ' /${product.unitName}',
                      style: Get.bodySmall.px08.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                4.verticalGap,
                Row(
                  children: [
                    GestureDetector(
                      onTap: isUpdating
                          ? null
                          : () => _updateQuantity(item, item.quantity - 1),
                      child: Opacity(
                        opacity: isUpdating ? 0.5 : 1,
                        child: Container(
                          padding: const EdgeInsets.all(6).rt,
                          decoration: BoxDecoration(
                            color: Get.disabledColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6).rt,
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 10.st,
                            color: Get.disabledColor,
                          ),
                        ),
                      ),
                    ),
                    10.horizontalGap,
                    isUpdating
                        ? SizedBox(
                            width: 10.st,
                            height: 10.st,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          )
                        : AppText(
                            '${item.quantity}',
                            style: Get.bodyMedium.px10.w700.copyWith(
                              color: Get.disabledColor,
                            ),
                          ),
                    10.horizontalGap,
                    GestureDetector(
                      onTap: isUpdating
                          ? null
                          : () => _updateQuantity(item, item.quantity + 1),
                      child: Opacity(
                        opacity: isUpdating ? 0.5 : 1,
                        child: Container(
                          padding: const EdgeInsets.all(6).rt,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6).rt,
                          ),
                          child: Icon(
                            Icons.add,
                            size: 10.st,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Total and Delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isDeleting
                  ? Container(
                      padding: const EdgeInsets.all(6).rt,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6).rt,
                      ),
                      child: SizedBox(
                        width: 18.st,
                        height: 18.st,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () => _removeItem(item.id),
                      child: Container(
                        padding: const EdgeInsets.all(6).rt,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6).rt,
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18.st,
                          color: Colors.red,
                        ),
                      ),
                    ),
              8.verticalGap,
              AppText(
                'Rs. ${item.subtotal}',
                style: Get.bodyMedium.px13.w800.copyWith(
                  color: Get.disabledColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  'total'.tr(context),
                  style: Get.bodyMedium.px15.w600.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.7),
                  ),
                ),
                AppText(
                  'Rs. ${cart?.totalAmount ?? '0.00'}',
                  style: Get.bodyLarge.px18.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
              ],
            ),
            16.verticalGap,
            GestureDetector(
              onTap: _navigateToCheckout,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14).rt,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12).rt,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: AppText(
                    'checkout'.tr(context),
                    style: Get.bodyMedium.px16.w700.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
