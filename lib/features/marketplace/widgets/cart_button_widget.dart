import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/marketplace/providers/marketplace_providers.dart';

class AddToCartBottomBar extends ConsumerWidget {
  final int productId;
  final VoidCallback onAddToCart;
  final VoidCallback onCheckout;

  const AddToCartBottomBar({
    super.key,
    required this.productId,
    required this.onAddToCart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adding = ref.watch(isAddingToCartProvider(productId));
    final inCart = ref.watch(isInCartProvider(productId));
    
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.rt, 12.ht, 16.rt, 16.ht),
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.vertical(top: const Radius.circular(20)).rt,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _AddToCartButton(
                adding: adding,
                inCart: inCart,
                onPressed: adding ? null : onAddToCart,
              ),
            ),
            12.horizontalGap,
            Expanded(
              child: _CheckoutButton(
                adding: adding,
                onPressed: adding ? null : onCheckout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final bool adding;
  final bool inCart;
  final VoidCallback? onPressed;

  const _AddToCartButton({
    required this.adding,
    required this.inCart,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: inCart ? Colors.green.shade500 : AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16.rt),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12).rt,
        ),
        elevation: inCart ? 2 : 3,
        shadowColor: (inCart ? Colors.green : AppColors.primary).withValues(alpha: 0.3),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: adding
            ? SizedBox(
                key: const ValueKey('loading'),
                height: 20.st,
                width: 20.st,
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.5,
                ),
              )
            : inCart
            ? Row(
                key: const ValueKey('added'),
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 20.st),
                  8.horizontalGap,
                  AppText(
                    'added_to_cart'.tr(context),
                    style: Get.bodyMedium.px15.w600.copyWith(color: Colors.white),
                  ),
                ],
              )
            : Row(
                key: const ValueKey('add'),
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 20.st),
                  8.horizontalGap,
                  AppText(
                    'add_to_cart'.tr(context),
                    style: Get.bodyMedium.px15.w600.copyWith(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  final bool adding;
  final VoidCallback? onPressed;

  const _CheckoutButton({
    required this.adding,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary.withValues(alpha: 0.9),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16.rt),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12).rt,
        ),
        elevation: 3,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
      ),
      child: adding
          ? SizedBox(
              height: 20.st,
              width: 20.st,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment, size: 20.st),
                8.horizontalGap,
                AppText(
                  'checkout'.tr(context),
                  style: Get.bodyMedium.px15.w600.copyWith(color: Colors.white),
                ),
              ],
            ),
    );
  }
}
