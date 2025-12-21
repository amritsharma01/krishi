import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/cart/checkout_page.dart';
import 'package:krishi/features/cart/providers/cart_providers.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/empty_state.dart';
import 'package:krishi/features/components/error_state.dart';
import 'package:krishi/models/cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartPage extends ConsumerStatefulWidget {
  final bool showAppBar;

  const CartPage({super.key, this.showAppBar = false});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    final updatingIds = ref.read(updatingItemIdsProvider);
    if (updatingIds.contains(item.id)) return;

    ref.read(updatingItemIdsProvider.notifier).state = {
      ...updatingIds,
      item.id,
    };

    try {
      final cartNotifier = ref.read(cartProvider.notifier);
      await cartNotifier.updateQuantity(item, newQuantity);
    } catch (e) {
      Get.snackbar(
        'error_updating_quantity'.tr(Get.context),
        color: Colors.red,
      );
    } finally {
      final currentIds = ref.read(updatingItemIdsProvider);
      final updatedIds = {...currentIds}..remove(item.id);
      ref.read(updatingItemIdsProvider.notifier).state = updatedIds;
    }
  }

  Future<void> _removeItem(int itemId) async {
    final deletingIds = ref.read(deletingItemIdsProvider);
    if (deletingIds.contains(itemId)) return;

    ref.read(deletingItemIdsProvider.notifier).state = {...deletingIds, itemId};

    try {
      final cartNotifier = ref.read(cartProvider.notifier);
      await cartNotifier.removeItem(itemId);
      if (mounted) {
        Get.snackbar('item_removed'.tr(Get.context), color: Colors.green);
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('error_removing_item'.tr(Get.context), color: Colors.red);
      }
    } finally {
      final currentIds = ref.read(deletingItemIdsProvider);
      final updatedIds = {...currentIds}..remove(itemId);
      ref.read(deletingItemIdsProvider.notifier).state = updatedIds;
    }
  }

  void _navigateToCheckout(Cart cart) async {
    if (cart.items.isEmpty) return;
    final result = await Get.to(CheckoutPage(cart: cart));
    
    // Reload cart after returning from checkout
    if (mounted) {
      // AWAIT cart reload to prevent black screen during navigation
      // This ensures cart state is updated before popping the page
      await ref.read(cartProvider.notifier).loadCart();
      
      // Only pop if cart page was pushed (has AppBar)
      // If embedded in marketplace tab, don't pop to avoid black screen
      if (result == true && mounted && widget.showAppBar) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: widget.showAppBar
          ? AppBar(
              automaticallyImplyLeading: true,
              backgroundColor: Get.scaffoldBackgroundColor,
              elevation: 0,
              title: AppText(
                'my_cart'.tr(context),
                style: Get.bodyLarge.px18.w700.copyWith(
                  color: Get.disabledColor,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Get.disabledColor),
                onPressed: () => Get.pop(),
              ),
            )
          : null,
      body: cartAsync.when(
        data: (cart) => _buildBody(cart),
        loading: () => Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (error, stack) => ErrorState(
          subtitle: 'error_loading_cart_subtitle'.tr(context),
          onRetry: () => ref.read(cartProvider.notifier).loadCart(),
        ),
      ),
      bottomNavigationBar: cartAsync.maybeWhen(
        data: (cart) => cart != null && cart.items.isNotEmpty
            ? _buildCheckoutBar(cart)
            : null,
        orElse: () => null,
      ),
    );
  }

  Widget _buildBody(Cart? cart) {
    if (cart == null || cart.items.isEmpty) {
      return EmptyState(
        title: 'empty_cart'.tr(context),
        subtitle: 'start_shopping'.tr(context),
        icon: Icons.shopping_cart_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(cartProvider.notifier).loadCart(silently: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 6).rt,
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          return _buildCartItem(cart.items[index]);
        },
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    final product = item.productDetails;
    if (product == null) return const SizedBox.shrink();
    final updatingIds = ref.watch(updatingItemIdsProvider);
    final deletingIds = ref.watch(deletingItemIdsProvider);
    final isUpdating = updatingIds.contains(item.id);
    final isDeleting = deletingIds.contains(item.id);

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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: AppText(
                    product.name,
                    style: Get.bodyMedium.px14.w700.copyWith(
                      color: Get.disabledColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                4.verticalGap,
                Row(
                  children: [
                    Flexible(
                      child: AppText(
                        'Rs. ${item.unitPrice}',
                        style: Get.bodyMedium.px08.w700.copyWith(
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: AppText(
                        ' /${product.unitName}',
                        style: Get.bodySmall.px08.copyWith(
                          color: Get.disabledColor.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                4.verticalGap,
                Row(
                  mainAxisSize: MainAxisSize.min,
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
                    8.horizontalGap,
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
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AppText(
                              '${item.quantity}',
                              style: Get.bodyMedium.px10.w700.copyWith(
                                color: Get.disabledColor,
                              ),
                            ),
                          ),
                    8.horizontalGap,
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
          8.horizontalGap,
          // Total and Delete
          Column(
            mainAxisSize: MainAxisSize.min,
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
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: AppText(
                  'Rs. ${item.subtotal}',
                  style: Get.bodyMedium.px13.w800.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(Cart cart) {
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
                Flexible(
                  child: AppText(
                    'total'.tr(context),
                    style: Get.bodyMedium.px15.w600.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                8.horizontalGap,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: AppText(
                    'Rs. ${cart.totalAmount}',
                    style: Get.bodyLarge.px18.w700.copyWith(
                      color: Get.disabledColor,
                    ),
                  ),
                ),
              ],
            ),
            16.verticalGap,
            GestureDetector(
              onTap: () => _navigateToCheckout(cart),
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
