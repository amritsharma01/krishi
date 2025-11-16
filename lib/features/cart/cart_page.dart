import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/widgets/app_text.dart';
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

  // Checkout form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final cartData = await apiService.getCart();
      if (mounted) {
        setState(() {
          cart = cartData;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity <= 0) return;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.updateCartItem(itemId: item.id, quantity: newQuantity);
      _loadCart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_updating_quantity'.tr(context)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeItem(int itemId) async {
    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.removeCartItem(itemId);
      _loadCart();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('item_removed'.tr(context)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_removing_item'.tr(context)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Get.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: AppText(
          'checkout'.tr(context),
          style: Get.bodyLarge.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'full_name'.tr(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'address'.tr(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),

              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'phone_number'.tr(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText(
              'cancel'.tr(context),
              style: Get.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          TextButton(
            onPressed: _processCheckout,
            child: AppText(
              'confirm'.tr(context),
              style: Get.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processCheckout() async {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('fill_all_fields'.tr(context)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.checkout(
        buyerName: _nameController.text,
        buyerAddress: _addressController.text,
        buyerPhoneNumber: _phoneController.text,
      );

      if (mounted) {
        Navigator.pop(context); // Close dialog
        Navigator.pop(context); // Return to previous page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('checkout_success'.tr(context)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('checkout_error'.tr(context)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      body: _buildBody(),
      bottomNavigationBar: cart != null && cart!.items.isNotEmpty
          ? _buildCheckoutBar()
          : null,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64.st),
            16.verticalGap,
            AppText(
              'error_loading_cart'.tr(context),
              style: Get.bodyMedium.px14.copyWith(color: Colors.red),
            ),
            16.verticalGap,
            ElevatedButton(
              onPressed: _loadCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: AppText(
                'retry'.tr(context),
                style: Get.bodyMedium.px14.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (cart == null || cart!.items.isEmpty) {
      return _buildEmptyCart();
    }

    return RefreshIndicator(
      onRefresh: _loadCart,
      child: ListView.builder(
        padding: const EdgeInsets.all(16).rt,
        itemCount: cart!.items.length,
        itemBuilder: (context, index) {
          return _buildCartItem(cart!.items[index]);
        },
      ),
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
            style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
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

  Widget _buildCartItem(CartItem item) {
    final product = item.productDetails;
    if (product == null) return const SizedBox.shrink();

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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12).rt,
            ),
            child: product.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12).rt,
                    child: Image.network(
                      Get.baseUrl + product.image!,
                      fit: BoxFit.cover,
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
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
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
                  style: Get.bodyMedium.px15.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                  maxLines: 1,
                ),
                6.verticalGap,
                Row(
                  children: [
                    AppText(
                      'Rs. ${item.unitPrice}',
                      style: Get.bodyMedium.px14.w700.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    AppText(
                      ' /${product.unitName}',
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
                      onTap: () => _updateQuantity(item, item.quantity - 1),
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
                      '${item.quantity}',
                      style: Get.bodyMedium.px14.w700.copyWith(
                        color: Get.disabledColor,
                      ),
                    ),
                    16.horizontalGap,
                    GestureDetector(
                      onTap: () => _updateQuantity(item, item.quantity + 1),
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
              onTap: _showCheckoutDialog,
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
