import 'package:dio/dio.dart';
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
import 'package:krishi/features/components/form_field.dart';
import 'package:krishi/models/cart.dart';
import 'package:krishi/models/user_profile.dart';
import 'package:krishi/features/cart/providers/checkout_providers.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final Cart cart;

  const CheckoutPage({super.key, required this.cart});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _hasPrefilled = false;

  void _showFieldValidationError(String message) {
    if (mounted) {
      Get.snackbar(message, color: Colors.red);
    }
  }

  bool _validateAddressAndPhone() {
    if (!mounted) return false;
    
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      _showFieldValidationError(
        '${'address'.tr(context)} ${'required_field'.tr(context)}',
      );
      return false;
    }
    if (address.length < 10) {
      _showFieldValidationError('address_min_length'.tr(context));
      return false;
    }

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showFieldValidationError(
        '${'phone_number'.tr(context)} ${'required_field'.tr(context)}',
      );
      return false;
    }
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      _showFieldValidationError('phone_length_error'.tr(context));
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    // Prefill will be handled by watching the provider
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _applyUserProfile(User user) {
    if (!mounted) return;

    final profile = user.profile;

    if (_nameController.text.isEmpty) {
      final fullName = profile?.fullName;
      final name = fullName?.trim();
      if (name != null && name.isNotEmpty) {
        _nameController.text = name;
      } else if (user.displayName.isNotEmpty) {
        _nameController.text = user.displayName;
      }
    }

    if (_addressController.text.isEmpty) {
      final address = profile?.address?.trim();
      if (address != null && address.isNotEmpty) {
        _addressController.text = address;
      }
    }

    if (_phoneController.text.isEmpty) {
      final phone = profile?.phoneNumber?.trim();
      if (phone != null && phone.isNotEmpty) {
        _phoneController.text = phone;
      }
    }
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) {
      _validateAddressAndPhone();
      return;
    }

    if (!_validateAddressAndPhone()) {
      return;
    }

    final checkoutNotifier = ref.read(checkoutStateProvider.notifier);

    try {
      await checkoutNotifier.processCheckout(
        buyerName: _nameController.text.trim(),
        buyerAddress: _addressController.text.trim(),
        buyerPhoneNumber: _phoneController.text.trim(),
        messageToSeller: _messageController.text.trim().isNotEmpty
            ? _messageController.text.trim()
            : null,
      );

      if (!mounted) return;

      // Clear form
      _nameController.clear();
      _addressController.clear();
      _phoneController.clear();
      _messageController.clear();

      // Show success message and navigate back
      if (mounted) {
        Get.snackbar('checkout_success'.tr(context), color: Colors.green);
        
        // Pop checkout page and return success status
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        // Extract backend error message
        String errorMessage = 'checkout_error'.tr(context);
        
        if (e is DioException) {
          final errorData = e.response?.data;
          if (errorData is Map<String, dynamic>) {
            // Backend returns error message in 'error' key
            final backendMessage = errorData['error'];
            if (backendMessage != null) {
              errorMessage = backendMessage.toString();
            }
          } else if (errorData is String) {
            errorMessage = errorData;
          }
        }
        
        Get.snackbar(errorMessage, color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutStateProvider);
    final isProcessing = checkoutState.isLoading;
    final userProfileAsync = ref.watch(checkoutUserProfileProvider);

    // Prefill form when user profile is available (only once)
    if (!_hasPrefilled) {
      userProfileAsync.whenData((user) {
        if (user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasPrefilled) {
              _applyUserProfile(user);
              _hasPrefilled = true;
            }
          });
        }
      });
    }

    // Listen to user profile changes for updates
    ref.listen<AsyncValue<User?>>(checkoutUserProfileProvider, (
      previous,
      next,
    ) {
      next.whenData((user) {
        if (user != null && mounted) {
          _applyUserProfile(user);
        }
      });
    });

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        title: AppText(
          'checkout'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.disabledColor),
          onPressed: () => Get.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5).rt,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Section
              _buildOrderSummary(),
              8.verticalGap,

              // Delivery Information Section
              _buildDeliveryInfoSection(),
              8.verticalGap,

              // Contact Information Section
              _buildContactInfoSection(),
              8.verticalGap,

              // Message to Seller Section
              _buildMessageToSellerSection(),
              8.verticalGap,

              // Total Amount
              _buildTotalAmount(),
              8.verticalGap,

              // Confirm Button
              _buildConfirmButton(isProcessing),
              8.verticalGap,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(15).rt,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          5.verticalGap,
          AppText(
            'order_summary'.tr(context),
            style: Get.bodyLarge.px16.w700.copyWith(color: Get.disabledColor),
          ),
          10.verticalGap,
          ...widget.cart.items.map((item) => _buildOrderItem(item)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    final product = item.productDetails;
    if (product == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 6.rt),
      padding: const EdgeInsets.all(8).rt,
      decoration: BoxDecoration(
        color: Get.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12).rt,
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60.rt,
            height: 60.rt,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10).rt,
            ),
            child: product.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10).rt,
                    child: Image.network(
                      Get.imageUrl(product.image),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.primary.withValues(alpha: 0.3),
                            size: 28.st,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 18.st,
                            height: 18.st,
                            child: CircularProgressIndicator.adaptive(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
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
                      size: 28.st,
                    ),
                  ),
          ),
          12.horizontalGap,
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  product.name,
                  style: Get.bodyMedium.px12.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                  maxLines: 2,
                ),
                4.verticalGap,
                AppText(
                  '${item.quantity} x Rs. ${item.unitPrice}',
                  style: Get.bodySmall.px10.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          AppText(
            'Rs. ${item.subtotal}',
            style: Get.bodyMedium.px14.w700.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'delivery_information'.tr(context),
          style: Get.bodyLarge.px16.w700.copyWith(color: Get.disabledColor),
        ),
        8.verticalGap,
        AppText(
          'full_name'.tr(context),
          style: Get.bodyMedium.px14.w600.copyWith(color: Get.disabledColor),
        ),
        6.verticalGap,
        AppTextFormField(
          controller: _nameController,
          hintText: 'enter_full_name'.tr(context),
          textInputType: TextInputType.name,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'required_field'.tr(context);
            }
            return null;
          },
        ),
        6.verticalGap,
        AppText(
          'address'.tr(context),
          style: Get.bodyMedium.px14.w600.copyWith(color: Get.disabledColor),
        ),
        6.verticalGap,
        AppTextFormField(
          controller: _addressController,
          hintText: 'enter_address'.tr(context),
          maxLine: 3,
          textInputType: TextInputType.streetAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'required_field'.tr(context);
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'contact_information'.tr(context),
          style: Get.bodyLarge.px16.w700.copyWith(color: Get.disabledColor),
        ),
        8.verticalGap,
        AppText(
          'phone_number'.tr(context),
          style: Get.bodyMedium.px14.w600.copyWith(color: Get.disabledColor),
        ),
        6.verticalGap,
        AppTextFormField(
          controller: _phoneController,
          hintText: 'enter_phone_number'.tr(context),
          textInputType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'required_field'.tr(context);
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMessageToSellerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'message_to_seller'.tr(context),
          style: Get.bodyLarge.px16.w700.copyWith(color: Get.disabledColor),
        ),
        2.verticalGap,
        AppText(
          'message_to_seller_hint'.tr(context),
          style: Get.bodySmall.px12.copyWith(
            color: Get.disabledColor.withValues(alpha: 0.6),
          ),
        ),
        8.verticalGap,
        AppTextFormField(
          controller: _messageController,
          hintText: 'enter_message_to_seller'.tr(context),
          maxLine: 4,
          textInputType: TextInputType.multiline,
        ),
      ],
    );
  }

  Widget _buildTotalAmount() {
    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            'total_amount'.tr(context),
            style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
          ),
          AppText(
            'Rs. ${widget.cart.totalAmount}',
            style: Get.bodyLarge.px20.w800.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(bool isProcessing) {
    return GestureDetector(
      onTap: isProcessing ? null : _processCheckout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16).rt,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isProcessing
                ? [
                    AppColors.primary.withValues(alpha: 0.5),
                    AppColors.primary.withValues(alpha: 0.4),
                  ]
                : [
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
          child: isProcessing
              ? SizedBox(
                  width: 24.st,
                  height: 24.st,
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    strokeWidth: 2.5,
                  ),
                )
              : AppText(
                  'confirm_order'.tr(context),
                  style: Get.bodyMedium.px16.w700.copyWith(
                    color: AppColors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
