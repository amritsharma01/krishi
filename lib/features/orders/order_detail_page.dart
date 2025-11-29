import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/error_state.dart';
import 'package:krishi/features/seller/seller_public_listings_page.dart';
import 'package:krishi/models/order.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  final int? orderId;
  final int? itemId; // For sales orders (OrderItemSeller)
  final bool isSeller;

  const OrderDetailPage({
    super.key,
    this.orderId,
    this.itemId,
    required this.isSeller,
  });

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  final _dateFormat = DateFormat('MMM d, yyyy • h:mm a');
  Order? order;
  OrderItemSeller? orderItem;
  bool isLoading = true;
  String? error;
  bool isProcessing = false;
  String? _loadingPublicListingsId;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      if (widget.itemId != null && widget.isSeller) {
        // Load order item details for seller
        final result = await apiService.getOrderItemDetail(widget.itemId!);
        if (mounted) {
          setState(() {
            orderItem = result;
            isLoading = false;
          });
        }
      } else if (widget.orderId != null) {
        // Load full order details for buyer
        final result = await apiService.getOrder(widget.orderId!);
        if (mounted) {
          setState(() {
            order = result;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            error = 'Invalid order or item ID';
            isLoading = false;
          });
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'order_details'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.disabledColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrderDetails,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : error != null
            ? Padding(
                padding: const EdgeInsets.all(16).rt,
                child: ErrorState(
                  title: 'problem_fetching_data'.tr(context),
                  subtitle: error,
                  onRetry: _loadOrderDetails,
                ),
              )
            : (order == null && orderItem == null)
            ? Center(child: AppText('order_not_found'.tr(context)))
            : orderItem != null
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16).rt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSalesStatusCard(),
                    16.verticalGap,
                    _buildSalesProductCard(),
                    16.verticalGap,
                    _buildSalesOrderInfoCard(),
                    16.verticalGap,
                    _buildActionButtons(),
                    16.verticalGap,
                    _buildContactAdminInfo(),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16).rt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    16.verticalGap,
                    _buildProductCard(),
                    16.verticalGap,
                    _buildOrderInfoCard(),
                    16.verticalGap,

                    if (widget.isSeller) ...[
                      _buildBuyerInfoCard(),
                      16.verticalGap,
                    ],
                    _buildActionButtons(),
                    16.verticalGap,
                    _buildContactAdminInfo(),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _openPublicListings(String? krId, String titleKey) async {
    if (krId == null || krId.isEmpty) {
      Get.snackbar('seller_id_unavailable'.tr(context), color: Colors.red);
      return;
    }
    setState(() => _loadingPublicListingsId = krId);
    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final profile = await apiService.getSellerPublicProfile(krId);
      if (!mounted) return;
      if (profile.sellerProducts.isEmpty) {
        Get.snackbar(
          'seller_no_listings'.tr(context),
          color: Colors.orange.shade700,
        );
        return;
      }
      Get.to(
        SellerPublicListingsPage(
          userKrId: krId,
          initialListings: profile.sellerProducts,
          titleKey: titleKey,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('error_loading_seller'.tr(context), color: Colors.red);
    } finally {
      if (mounted) {
        setState(() => _loadingPublicListingsId = null);
      }
    }
  }

  Widget _buildStatusCard() {
    final status = order!.status.toLowerCase();
    final displayStatus =
        (order!.statusDisplay != null &&
            order!.statusDisplay!.trim().isNotEmpty)
        ? order!.statusDisplay!
        : _capitalize(order!.status);
    final (Color bgColor, Color textColor, Color borderColor) = _statusColors(
      status,
    );

    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12).rt,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(_statusIcon(status), color: textColor, size: 24.st),
          ),
          16.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'order_status'.tr(context),
                  style: Get.bodySmall.px12.w500.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.6),
                  ),
                ),
                4.verticalGap,
                AppText(
                  displayStatus,
                  style: Get.bodyLarge.px18.w700.copyWith(color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'order_items'.tr(context),
            style: Get.bodyMedium.px16.w700.copyWith(color: Get.disabledColor),
          ),
          12.verticalGap,
          if (order!.items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.rt),
              child: Center(
                child: AppText(
                  'order_awaiting_approval'.tr(context),
                  style: Get.bodySmall.px13.w500.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...order!.items.map((item) => _buildOrderItem(item)),
          if (order!.items.isNotEmpty) 16.verticalGap,
          Divider(color: Get.disabledColor.withValues(alpha: 0.1)),
          12.verticalGap,
          _buildPriceRow('subtotal'.tr(context), order!.subtotalAsDouble),
          if (order!.approvedByAdmin && order!.hasDeliveryCharges) ...[
            8.verticalGap,
            _buildPriceRow(
              'delivery_charges'.tr(context),
              order!.deliveryChargesAsDouble,
            ),
          ],
          if (!order!.approvedByAdmin) ...[
            8.verticalGap,
            AppText(
              'awaiting_admin_approval'.tr(context),
              style: Get.bodySmall.px12.w500.copyWith(
                color: Colors.orange.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          12.verticalGap,
          Divider(
            color: Get.disabledColor.withValues(alpha: 0.2),
            thickness: 1.5,
          ),
          8.verticalGap,
          _buildPriceRow(
            'total'.tr(context),
            order!.totalAmountAsDouble,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    final productDetails = item.productDetails;
    final imageUrl = productDetails?.image ?? '';
    final hasImage = imageUrl.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.rt),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8).rt,
            child: hasImage
                ? Image.network(
                    imageUrl,
                    width: 60.st,
                    height: 60.st,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60.st,
                      height: 60.st,
                      color: Get.disabledColor.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.broken_image,
                        color: Get.disabledColor,
                        size: 20.st,
                      ),
                    ),
                  )
                : Container(
                    width: 60.st,
                    height: 60.st,
                    color: Get.disabledColor.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.shopping_bag,
                      color: Get.disabledColor,
                      size: 20.st,
                    ),
                  ),
          ),
          12.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  item.productName,
                  style: Get.bodyMedium.px14.w600.copyWith(
                    color: Get.disabledColor,
                  ),
                  maxLines: 2,
                ),
                4.verticalGap,
                AppText(
                  '${item.quantity} x NPR ${item.unitPriceAsDouble.toStringAsFixed(2)}',
                  style: Get.bodySmall.px12.w500.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          AppText(
            'NPR ${item.totalPriceAsDouble.toStringAsFixed(2)}',
            style: Get.bodyMedium.px14.w700.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          style: isBold
              ? Get.bodyMedium.px15.w700.copyWith(color: Get.disabledColor)
              : Get.bodySmall.px13.w500.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.7),
                ),
        ),
        AppText(
          'NPR ${amount.toStringAsFixed(2)}',
          style: isBold
              ? Get.bodyMedium.px16.w700.copyWith(color: AppColors.primary)
              : Get.bodySmall.px13.w600.copyWith(color: Get.disabledColor),
        ),
      ],
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'order_information'.tr(context),
            style: Get.bodyMedium.px16.w700.copyWith(color: Get.disabledColor),
          ),
          12.verticalGap,
          _buildInfoRow('order_id'.tr(context), '#${order!.id}'),
          8.verticalGap,
          _buildInfoRow(
            'order_date'.tr(context),
            _dateFormat.format(order!.createdAt.toLocal()),
          ),
          8.verticalGap,
          _buildInfoRow(
            'total_amount'.tr(context),
            'NPR ${order!.totalAmountAsDouble.toStringAsFixed(2)}',
            isBold: true,
          ),
          if (order!.adminNotes != null && order!.adminNotes!.isNotEmpty) ...[
            12.verticalGap,
            Divider(color: Get.disabledColor.withValues(alpha: 0.1)),
            12.verticalGap,
            AppText(
              'admin_notes'.tr(context),
              style: Get.bodyMedium.px14.w700.copyWith(
                color: Get.disabledColor,
              ),
            ),
            8.verticalGap,
            Container(
              padding: const EdgeInsets.all(12).rt,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8).rt,
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: AppText(
                order!.adminNotes!,
                style: Get.bodySmall.px13.w500.copyWith(
                  color: Get.disabledColor,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBuyerInfoCard() {
    final buyerKrId = order!.buyerKrId;
    return InkWell(
      onTap: () => _openPublicListings(buyerKrId, 'buyer_public_listings'),
      borderRadius: BorderRadius.circular(16).rt,
      child: Container(
        padding: const EdgeInsets.all(16).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(16).rt,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText(
                    'buyer_information'.tr(context),
                    style: Get.bodyMedium.px16.w700.copyWith(
                      color: Get.disabledColor,
                    ),
                  ),
                ),
                if (_loadingPublicListingsId == buyerKrId)
                  SizedBox(
                    width: 16.st,
                    height: 16.st,
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14.st,
                    color: Get.disabledColor.withValues(alpha: 0.3),
                  ),
              ],
            ),
            12.verticalGap,
            _buildInfoRow(
              'buyer_id_label'.tr(context),
              buyerKrId ?? 'seller_id_unavailable'.tr(context),
            ),
            8.verticalGap,
            AppText(
              'buyer_contact_hidden'.tr(context),
              style: Get.bodySmall.px12.w500.copyWith(
                color: Get.disabledColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactAdminInfo() {
    return Container(
      padding: const EdgeInsets.all(12).rt,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18.st, color: Colors.blue.shade700),
          8.horizontalGap,
          Expanded(
            child: AppText(
              'order_edit_cancel_info'.tr(context),
              style: Get.bodySmall.px12.w500.copyWith(
                color: Colors.blue.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120.st,
          child: AppText(
            label,
            style: Get.bodySmall.px13.w500.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: AppText(
            value,
            style: isBold
                ? Get.bodyMedium.px14.w700.copyWith(color: AppColors.primary)
                : Get.bodySmall.px13.w500.copyWith(color: Get.disabledColor),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    // Show delete button only for buyers with pending orders
    if (widget.isSeller || order == null) {
      return const SizedBox();
    }

    final isPending = order!.status.toLowerCase() == 'pending';
    if (!isPending) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(color: Colors.red.withValues(alpha: 0.2), width: 1),
      ),
      child: TextButton.icon(
        onPressed: isProcessing ? null : _deleteOrder,
        icon: isProcessing
            ? SizedBox(
                width: 16.st,
                height: 16.st,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.red.shade700,
                  ),
                ),
              )
            : Icon(
                Icons.delete_outline,
                color: Colors.red.shade700,
                size: 20.st,
              ),
        label: AppText(
          'delete_order'.tr(context),
          style: Get.bodyMedium.px14.w600.copyWith(color: Colors.red.shade700),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16).rt,
        ),
      ),
    );
  }

  Future<void> _deleteOrder() async {
    if (order == null || !mounted) return;

    // Get a valid context - use Get.context as fallback if widget is not mounted
    final dialogContext = mounted ? context : Get.context;

    // Show confirmation dialog
    final confirmed = await showAdaptiveDialog<bool>(
      context: dialogContext,
      barrierDismissible: true,
      builder: (builderContext) => AlertDialog.adaptive(
        backgroundColor: Get.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16).rt,
        ),
        title: Text(
          'delete_order'.tr(builderContext),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        content: Text(
          'delete_order_confirm'.tr(builderContext),
          style: Get.bodyMedium.px14.w500.copyWith(
            color: Get.disabledColor.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(builderContext).pop(false),
            child: Text(
              'no'.tr(builderContext),
              style: Get.bodyMedium.px14.w500.copyWith(
                color: Get.disabledColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(builderContext).pop(true),
            child: Text(
              'yes'.tr(builderContext),
              style: Get.bodyMedium.px14.w600.copyWith(
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      isProcessing = true;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.deleteOrder(order!.id);
      if (mounted) {
        Get.snackbar('order_deleted'.tr(context), color: Colors.green);
        Navigator.of(context).pop(true); // Return true to indicate deletion
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('pending') ||
            errorMessage.contains('status')) {
          Get.snackbar(
            'order_delete_pending_only'.tr(context),
            color: Colors.orange.shade700,
          );
        } else {
          Get.snackbar('order_delete_failed'.tr(context), color: Colors.red);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  (Color, Color, Color) _statusColors(String status) {
    switch (status) {
      case 'completed':
        return (
          Colors.green.withValues(alpha: 0.15),
          Colors.green.shade800,
          Colors.green.withValues(alpha: 0.3),
        );
      case 'approved':
        return (
          Colors.teal.withValues(alpha: 0.15),
          Colors.teal.shade800,
          Colors.teal.withValues(alpha: 0.3),
        );
      case 'rejected':
        return (
          Colors.red.withValues(alpha: 0.15),
          Colors.red.shade800,
          Colors.red.withValues(alpha: 0.3),
        );
      case 'accepted':
      case 'in_transit':
        return (
          Colors.blue.withValues(alpha: 0.15),
          Colors.blue.shade800,
          Colors.blue.withValues(alpha: 0.3),
        );
      case 'delivered':
        return (
          Colors.purple.withValues(alpha: 0.15),
          Colors.purple.shade800,
          Colors.purple.withValues(alpha: 0.3),
        );
      case 'cancelled':
        return (
          Colors.red.withValues(alpha: 0.15),
          Colors.red.shade800,
          Colors.red.withValues(alpha: 0.3),
        );
      case 'pending':
      default:
        return (
          Colors.orange.withValues(alpha: 0.15),
          Colors.orange.shade800,
          Colors.orange.withValues(alpha: 0.3),
        );
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'approved':
        return Icons.verified;
      case 'rejected':
        return Icons.block;
      case 'accepted':
        return Icons.thumb_up;
      case 'in_transit':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.schedule;
    }
  }

  String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

  // Sales order item UI methods
  Widget _buildSalesStatusCard() {
    final status = orderItem!.orderStatus.toLowerCase();
    final displayStatus = orderItem!.statusDisplay;
    final (Color bgColor, Color textColor, Color borderColor) = _statusColors(
      status,
    );

    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12).rt,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(_statusIcon(status), color: textColor, size: 24.st),
          ),
          16.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'order_status'.tr(context),
                  style: Get.bodySmall.px12.w500.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.6),
                  ),
                ),
                4.verticalGap,
                AppText(
                  displayStatus,
                  style: Get.bodyLarge.px18.w700.copyWith(color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesProductCard() {
    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'product_information'.tr(context),
            style: Get.bodyMedium.px16.w700.copyWith(color: Get.disabledColor),
          ),
          12.verticalGap,
          _buildInfoRow('product_name'.tr(context), orderItem!.productName),
          8.verticalGap,
          _buildInfoRow(
            'base_price'.tr(context),
            'Rs. ${orderItem!.basePriceAsDouble.toStringAsFixed(2)}',
          ),
          8.verticalGap,
          _buildInfoRow('quantity'.tr(context), '${orderItem!.quantity}'),
          12.verticalGap,
          Divider(
            color: Get.disabledColor.withValues(alpha: 0.2),
            thickness: 1.5,
          ),
          8.verticalGap,
          _buildInfoRow(
            'total'.tr(context),
            'Rs. ${orderItem!.totalPriceAsDouble.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSalesOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'order_information'.tr(context),
            style: Get.bodyMedium.px16.w700.copyWith(color: Get.disabledColor),
          ),
          12.verticalGap,
          _buildInfoRow('order_id'.tr(context), '#${orderItem!.orderId}'),
          8.verticalGap,
          _buildInfoRow(
            'order_date'.tr(context),
            _dateFormat.format(orderItem!.orderDate.toLocal()),
          ),
        ],
      ),
    );
  }
}
