import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/widgets/app_text.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Dummy cart items
  List<Map<String, dynamic>> cartItems = [
    {
      'id': '1',
      'name': 'Fresh Tomatoes',
      'nameNe': 'ताजा गोलभेडा',
      'price': 80.0,
      'image': '🍅',
      'quantity': 2,
      'unit': 'kg',
      'bgColor': Color(0xFFFFD4D4),
    },
    {
      'id': '2',
      'name': 'Organic Potatoes',
      'nameNe': 'जैविक आलु',
      'price': 60.0,
      'image': '🥔',
      'quantity': 1,
      'unit': 'kg',
      'bgColor': Color(0xFFEEDDCC),
    },
    {
      'id': '3',
      'name': 'Premium Wheat',
      'nameNe': 'प्रिमियम गहुँ',
      'price': 20.50,
      'image': '🌾',
      'quantity': 5,
      'unit': 'kg',
      'bgColor': Color(0xFFD4E7D4),
    },
  ];

  double get subtotal {
    return cartItems.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      final newQuantity = cartItems[index]['quantity'] + change;
      if (newQuantity > 0) {
        cartItems[index]['quantity'] = newQuantity;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
    Get.snackbar('Item removed from cart');
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
          style: Get.bodyLarge.px22.w700.copyWith(color: Get.disabledColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.disabledColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      bottomNavigationBar: cartItems.isEmpty ? null : _buildCheckoutBar(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32).rt,
            decoration: BoxDecoration(
              color: Get.cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 80.st,
              color: Get.disabledColor.withValues(alpha: 0.3),
            ),
          ),
          24.verticalGap,
          AppText(
            'empty_cart'.tr(context),
            style: Get.bodyLarge.px20.w700.copyWith(
              color: Get.disabledColor,
            ),
          ),
          12.verticalGap,
          AppText(
            'start_shopping'.tr(context),
            style: Get.bodyMedium.px14.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16).rt,
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        return _buildCartItem(cartItems[index], index);
      },
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.rt),
      padding: const EdgeInsets.all(14).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
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
              color: item['bgColor'],
              borderRadius: BorderRadius.circular(12).rt,
            ),
            child: Center(
              child: Text(
                item['image'],
                style: TextStyle(fontSize: 32.st),
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
                  item['name'],
                  style: Get.bodyMedium.px15.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                6.verticalGap,
                Row(
                  children: [
                    AppText(
                      'Rs. ${item['price'].toStringAsFixed(2)}',
                      style: Get.bodyMedium.px14.w700.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    AppText(
                      ' /${item['unit']}',
                      style: Get.bodySmall.px11.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                8.verticalGap,
                // Quantity Controls
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _updateQuantity(index, -1),
                      child: Container(
                        padding: const EdgeInsets.all(6).rt,
                        decoration: BoxDecoration(
                          color: Get.disabledColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6).rt,
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 16.st,
                          color: Get.disabledColor,
                        ),
                      ),
                    ),
                    16.horizontalGap,
                    AppText(
                      '${item['quantity']}',
                      style: Get.bodyMedium.px14.w700.copyWith(
                        color: Get.disabledColor,
                      ),
                    ),
                    16.horizontalGap,
                    GestureDetector(
                      onTap: () => _updateQuantity(index, 1),
                      child: Container(
                        padding: const EdgeInsets.all(6).rt,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6).rt,
                        ),
                        child: Icon(
                          Icons.add,
                          size: 16.st,
                          color: AppColors.primary,
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
              GestureDetector(
                onTap: () => _removeItem(index),
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
                'Rs. ${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                style: Get.bodyMedium.px15.w800.copyWith(
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
                  'subtotal'.tr(context),
                  style: Get.bodyMedium.px15.w600.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.7),
                  ),
                ),
                AppText(
                  'Rs. ${subtotal.toStringAsFixed(2)}',
                  style: Get.bodyLarge.px18.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
              ],
            ),
            16.verticalGap,
            GestureDetector(
              onTap: () {
                // TODO: Navigate to checkout page
                Get.snackbar('Checkout coming soon!');
              },
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

