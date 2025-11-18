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
import 'package:krishi/features/seller/seller_profile_page.dart';
import 'package:krishi/models/order.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  final int orderId;
  final bool isSeller;

  const OrderDetailPage({
    super.key,
    required this.orderId,
    required this.isSeller,
  });

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  final _dateFormat = DateFormat('MMM d, yyyy • h:mm a');
  Order? order;
  bool isLoading = true;
  String? error;
  bool isProcessing = false;

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
      final result = await apiService.getOrder(widget.orderId);
      if (mounted) {
        setState(() {
          order = result;
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

  Future<void> _acceptOrder() async {
    final apiService = ref.read(krishiApiServiceProvider);
    await _handleOrderAction(
      () => apiService.acceptOrder(widget.orderId),
      'order_accepted'.tr(context),
      'order_accept_failed'.tr(context),
    );
  }

  Future<void> _markInTransit() async {
    final apiService = ref.read(krishiApiServiceProvider);
    await _handleOrderAction(
      () => apiService.markOrderInTransit(widget.orderId),
      'order_marked_in_transit'.tr(context),
      'order_transit_failed'.tr(context),
    );
  }

  Future<void> _deliverOrder() async {
    final apiService = ref.read(krishiApiServiceProvider);
    await _handleOrderAction(
      () => apiService.deliverOrder(widget.orderId),
      'order_delivered'.tr(context),
      'order_deliver_failed'.tr(context),
    );
  }

  Future<void> _completeOrder() async {
    final apiService = ref.read(krishiApiServiceProvider);
    await _handleOrderAction(
      () => apiService.completeOrder(widget.orderId),
      'order_completed'.tr(context),
      'order_complete_failed'.tr(context),
    );
  }

  Future<void> _cancelOrder() async {
    // Show confirmation dialog first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText('cancel_order'.tr(context)),
        content: AppText('cancel_order_confirm'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText('no'.tr(context)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: AppText('yes'.tr(context), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final apiService = ref.read(krishiApiServiceProvider);
    await _handleOrderAction(
      () => apiService.cancelOrder(widget.orderId),
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
            ? Center(
                child: CircularProgressIndicator(color: AppColors.primary),
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
                : order == null
                    ? Center(child: AppText('order_not_found'.tr(context)))
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
                            if (widget.isSeller) _buildBuyerInfoCard(),
                            if (widget.isSeller) 16.verticalGap,
                            if (!widget.isSeller) _buildSellerInfoCard(),
                            if (!widget.isSeller) 16.verticalGap,
                            _buildActionButtons(),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = order!.status.toLowerCase();
    final displayStatus = (order!.statusDisplay != null &&
            order!.statusDisplay!.trim().isNotEmpty)
        ? order!.statusDisplay!
        : _capitalize(order!.status);
    final (Color bgColor, Color textColor, Color borderColor) = _statusColors(status);

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
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusIcon(status),
              color: textColor,
              size: 24.st,
            ),
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
    final productDetails = order!.productDetails;
    final imageUrl = productDetails?.image ?? '';
    final hasImage = imageUrl.isNotEmpty;
    
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12).rt,
            child: hasImage
                ? Image.network(
                    imageUrl,
                    width: 80.st,
                    height: 80.st,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80.st,
                        height: 80.st,
                        color: Get.disabledColor.withValues(alpha: 0.1),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      width: 80.st,
                      height: 80.st,
                      color: Get.disabledColor.withValues(alpha: 0.1),
                      child: Icon(Icons.broken_image, color: Get.disabledColor),
                    ),
                  )
                : Container(
                    width: 80.st,
                    height: 80.st,
                    color: Get.disabledColor.withValues(alpha: 0.1),
                    child: Icon(Icons.shopping_bag, color: Get.disabledColor),
                  ),
          ),
          16.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  order!.productName,
                  style: Get.bodyLarge.px16.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                  maxLines: 2,
                ),
                8.verticalGap,
                Row(
                  children: [
                    Icon(Icons.shopping_cart, size: 14.st, color: Get.disabledColor.withValues(alpha: 0.6)),
                    4.horizontalGap,
                    AppText(
                      '${'quantity'.tr(context)}: ${order!.quantity}',
                      style: Get.bodySmall.px12.w500.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                4.verticalGap,
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 14.st, color: Get.disabledColor.withValues(alpha: 0.6)),
                    AppText(
                      '${'unit_price'.tr(context)}: NPR ${order!.unitPriceAsDouble.toStringAsFixed(2)}',
                      style: Get.bodySmall.px12.w500.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
          _buildInfoRow('order_date'.tr(context), _dateFormat.format(order!.createdAt.toLocal())),
          8.verticalGap,
          _buildInfoRow('total_amount'.tr(context), 'NPR ${order!.totalAmountAsDouble.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildBuyerInfoCard() {
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
            'buyer_information'.tr(context),
            style: Get.bodyMedium.px16.w700.copyWith(color: Get.disabledColor),
          ),
          12.verticalGap,
          _buildInfoRow('name'.tr(context), order!.buyerName),
          8.verticalGap,
          _buildInfoRow('phone'.tr(context), order!.buyerPhoneNumber),
          8.verticalGap,
          _buildInfoRow('email'.tr(context), order!.buyerEmail),
          8.verticalGap,
          _buildInfoRow('address'.tr(context), order!.buyerAddress),
          16.verticalGap,
          Row(
            children: [
              Expanded(
                child: _buildContactButton(
                  label: 'call_buyer'.tr(context),
                  icon: Icons.phone,
                  color: Colors.green,
                  onTap: () => _makePhoneCall(order!.buyerPhoneNumber),
                ),
              ),
              12.horizontalGap,
              Expanded(
                child: _buildContactButton(
                  label: 'whatsapp'.tr(context),
                  icon: Icons.chat,
                  color: Color(0xFF25D366),
                  onTap: () => _openWhatsApp(order!.buyerPhoneNumber),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfoCard() {
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
          Row(
            children: [
              Expanded(
                child: AppText(
                  'seller_information'.tr(context),
                  style: Get.bodyMedium.px16.w700.copyWith(color: Get.disabledColor),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SellerProfilePage(
                        sellerId: order!.seller,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8).rt,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6).rt,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8).rt,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        'view_profile'.tr(context),
                        style: Get.bodySmall.px12.w600.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      4.horizontalGap,
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12.st,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          12.verticalGap,
          _buildInfoRow('email'.tr(context), order!.sellerEmail),
          if (order!.sellerPhoneNumber != null && order!.sellerPhoneNumber!.isNotEmpty) ...[
            8.verticalGap,
            _buildInfoRow('phone'.tr(context), order!.sellerPhoneNumber!),
          ],
          16.verticalGap,
          Row(
            children: [
              if (order!.sellerPhoneNumber != null && order!.sellerPhoneNumber!.isNotEmpty) ...[
                Expanded(
                  child: _buildContactButton(
                    label: 'call_seller'.tr(context),
                    icon: Icons.phone,
                    color: Colors.green,
                    onTap: () => _makePhoneCall(order!.sellerPhoneNumber!),
                  ),
                ),
                12.horizontalGap,
                Expanded(
                  child: _buildContactButton(
                    label: 'whatsapp'.tr(context),
                    icon: Icons.chat,
                    color: Color(0xFF25D366),
                    onTap: () => _openWhatsApp(order!.sellerPhoneNumber!),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18.st),
      label: AppText(
        label,
        style: Get.bodySmall.px12.w600,
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10).rt,
        side: BorderSide(color: color, width: 1.5),
        foregroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10).rt,
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        Get.snackbar('call_failed'.tr(context), color: Colors.red);
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    try {
      // Remove any spaces or special characters
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Add country code if not present (Nepal country code is +977)
      if (!cleanNumber.startsWith('+') && !cleanNumber.startsWith('977')) {
        cleanNumber = '977$cleanNumber';
      }
      
      final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');
      
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          Get.snackbar('whatsapp_failed'.tr(context), color: Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('whatsapp_failed'.tr(context), color: Colors.red);
      }
    }
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
    if (order == null) return const SizedBox();

    final status = order!.status.toLowerCase();
    final List<Widget> buttons = [];

    if (widget.isSeller) {
      // Seller actions - Allow status reversal
      if (status == 'pending') {
        buttons.add(_buildActionButton(
          'accept_order'.tr(context),
          Icons.check_circle_outline,
          Colors.green,
          _acceptOrder,
        ));
      }
      if (status == 'accepted') {
        buttons.add(_buildActionButton(
          'mark_in_transit'.tr(context),
          Icons.local_shipping_outlined,
          Colors.blue,
          _markInTransit,
        ));
      }
      if (status == 'in_transit') {
        buttons.add(_buildActionButton(
          'mark_delivered'.tr(context),
          Icons.done_all,
          Colors.purple,
          _deliverOrder,
        ));
      }
      if (status == 'delivered') {
        buttons.add(_buildActionButton(
          'mark_in_transit'.tr(context),
          Icons.local_shipping_outlined,
          Colors.orange,
          _markInTransit,
          isOutlined: true,
        ));
      }
      if (status == 'in_transit') {
        buttons.add(_buildActionButton(
          'mark_accepted'.tr(context),
          Icons.thumb_up_outlined,
          Colors.orange,
          _acceptOrder,
          isOutlined: true,
        ));
      }
      if (status == 'accepted') {
        buttons.add(_buildActionButton(
          'mark_pending'.tr(context),
          Icons.schedule_outlined,
          Colors.orange,
          () async {
            // Since there's no API endpoint to revert to pending, we show a message
            Get.snackbar('cannot_revert_pending'.tr(context), color: Colors.orange);
          },
          isOutlined: true,
        ));
      }
      if (status == 'pending' || status == 'accepted' || status == 'in_transit') {
        buttons.add(_buildActionButton(
          'cancel_order'.tr(context),
          Icons.cancel_outlined,
          Colors.red,
          _cancelOrder,
          isOutlined: true,
        ));
      }
    } else {
      // Buyer actions
      if (status == 'delivered') {
        buttons.add(_buildActionButton(
          'mark_as_complete'.tr(context),
          Icons.check_circle,
          Colors.green,
          _completeOrder,
        ));
      }
      if (status == 'pending') {
        buttons.add(_buildActionButton(
          'cancel_order'.tr(context),
          Icons.cancel_outlined,
          Colors.red,
          _cancelOrder,
          isOutlined: true,
        ));
      }
    }

    if (buttons.isEmpty) return const SizedBox();

    return Column(
      children: buttons.map((button) => Padding(
        padding: const EdgeInsets.only(bottom: 12).rt,
        child: button,
      )).toList(),
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
          Colors.green.withValues(alpha: 0.3)
        );
      case 'accepted':
      case 'in_transit':
        return (
          Colors.blue.withValues(alpha: 0.15),
          Colors.blue.shade800,
          Colors.blue.withValues(alpha: 0.3)
        );
      case 'delivered':
        return (
          Colors.purple.withValues(alpha: 0.15),
          Colors.purple.shade800,
          Colors.purple.withValues(alpha: 0.3)
        );
      case 'cancelled':
        return (
          Colors.red.withValues(alpha: 0.15),
          Colors.red.shade800,
          Colors.red.withValues(alpha: 0.3)
        );
      case 'pending':
      default:
        return (
          Colors.orange.withValues(alpha: 0.15),
          Colors.orange.shade800,
          Colors.orange.withValues(alpha: 0.3)
        );
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
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
}

