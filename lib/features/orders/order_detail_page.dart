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

  Future<void> _handleOrderAction(
    Future<Order> Function() action,
    String successMessage,
    String errorMessage,
  ) async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      final updatedOrder = await action();
      if (!mounted) return;
      setState(() {
        order = updatedOrder;
        isProcessing = false;
      });
      Get.snackbar(successMessage, color: Colors.green);
      // Notify parent to refresh
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isProcessing = false;
      });
      Get.snackbar(errorMessage, color: Colors.red);
    }
  }

  Future<void> _startDelivery() async {
    final apiService = ref.read(krishiApiServiceProvider);
    final orderId = orderItem?.orderId ?? widget.orderId;
    if (orderId == null) return;
    await _handleOrderAction(
      () => apiService.startDelivery(orderId),
      'order_marked_in_transit'.tr(context),
      'order_transit_failed'.tr(context),
    );
  }

  Future<void> _deliverOrder() async {
    final apiService = ref.read(krishiApiServiceProvider);
    final orderId = orderItem?.orderId ?? widget.orderId;
    if (orderId == null) return;
    await _handleOrderAction(
      () => apiService.deliverOrder(orderId),
      'order_delivered'.tr(context),
      'order_deliver_failed'.tr(context),
    );
  }

  Future<void> _completeOrder() async {
    final apiService = ref.read(krishiApiServiceProvider);
    final orderId = orderItem?.orderId ?? widget.orderId;
    if (orderId == null) return;
    await _handleOrderAction(
      () => apiService.completeOrder(orderId),
      'order_completed'.tr(context),
      'order_complete_failed'.tr(context),
    );
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final textColor =
            theme.textTheme.titleMedium?.color ??
            (theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black87);
        final secondaryTextColor =
            theme.textTheme.bodyMedium?.color ??
            (theme.brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54);

        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20).rt,
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8).rt,
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16).rt,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12).rt,
          title: Text(
            'cancel_order'.tr(dialogContext),
            style: theme.textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'cancel_order_confirm'.tr(dialogContext),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: secondaryTextColor,
              height: 1.5,
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(foregroundColor: theme.disabledColor),
              child: Text('no'.tr(dialogContext)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ).rt,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12).rt,
                ),
              ),
              child: Text('yes'.tr(dialogContext)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final apiService = ref.read(krishiApiServiceProvider);
    final orderId = orderItem?.orderId ?? widget.orderId;
    if (orderId == null) return;
    await _handleOrderAction(
      () => apiService.cancelOrder(orderId),
      'order_cancelled'.tr(context),
      'order_cancel_failed'.tr(context),
    );
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
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
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
    // For sales orders, use orderItem; for purchases, use order
    if (orderItem != null) {
      final status = orderItem!.orderStatus.toLowerCase();
      final List<Widget> buttons = [];

      // Seller actions for order items
      if (status == 'approved' || status == 'in_transit') {
        buttons.add(
          _buildActionButton(
            'mark_in_transit'.tr(context),
            Icons.local_shipping_outlined,
            Colors.blue,
            _startDelivery,
          ),
        );
      }
      if (status == 'in_transit' || status == 'approved') {
        buttons.add(
          _buildActionButton(
            'mark_delivered'.tr(context),
            Icons.done_all,
            Colors.purple,
            _deliverOrder,
          ),
        );
      }
      if (status == 'approved' || status == 'in_transit') {
        buttons.add(
          _buildActionButton(
            'cancel_order'.tr(context),
            Icons.cancel_outlined,
            Colors.red,
            _cancelOrder,
            isOutlined: true,
          ),
        );
      }

      if (buttons.isEmpty) return const SizedBox();

      return Column(
        children: buttons
            .map(
              (button) => Padding(
                padding: const EdgeInsets.only(bottom: 12).rt,
                child: button,
              ),
            )
            .toList(),
      );
    }

    if (order == null) return const SizedBox();

    final status = order!.status.toLowerCase();
    final List<Widget> buttons = [];

    if (widget.isSeller) {
      // Seller actions - Sellers can only act on APPROVED orders
      if (status == 'approved' || status == 'in_transit') {
        buttons.add(
          _buildActionButton(
            'mark_in_transit'.tr(context),
            Icons.local_shipping_outlined,
            Colors.blue,
            _startDelivery,
          ),
        );
      }
      if (status == 'in_transit' || status == 'approved') {
        buttons.add(
          _buildActionButton(
            'mark_delivered'.tr(context),
            Icons.done_all,
            Colors.purple,
            _deliverOrder,
          ),
        );
      }
      if (status == 'approved' || status == 'in_transit') {
        buttons.add(
          _buildActionButton(
            'cancel_order'.tr(context),
            Icons.cancel_outlined,
            Colors.red,
            _cancelOrder,
            isOutlined: true,
          ),
        );
      }
    } else {
      // Buyer actions
      if (status == 'delivered') {
        buttons.add(
          _buildActionButton(
            'mark_as_complete'.tr(context),
            Icons.check_circle,
            Colors.green,
            _completeOrder,
          ),
        );
      }
      if (status == 'pending') {
        buttons.add(
          _buildActionButton(
            'cancel_order'.tr(context),
            Icons.cancel_outlined,
            Colors.red,
            _cancelOrder,
            isOutlined: true,
          ),
        );
      }
    }

    if (buttons.isEmpty) return const SizedBox();

    return Column(
      children: buttons
          .map(
            (button) => Padding(
              padding: const EdgeInsets.only(bottom: 12).rt,
              child: button,
            ),
          )
          .toList(),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: isProcessing ? null : onPressed,
              icon: Icon(icon, size: 18.st),
              label: AppText(label),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14).rt,
                side: BorderSide(color: color, width: 2),
                foregroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12).rt,
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: isProcessing ? null : onPressed,
              icon: isProcessing
                  ? SizedBox(
                      width: 18.st,
                      height: 18.st,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(icon, size: 18.st),
              label: AppText(
                isProcessing ? 'processing'.tr(context) : label,
                style: Get.bodyMedium.px14.w600.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14).rt,
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12).rt,
                ),
              ),
            ),
    );
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
