import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/error_state.dart';
import 'package:krishi/features/seller/seller_public_listings_page.dart';
import 'package:krishi/features/orders/providers/order_detail_provider.dart';
import 'package:krishi/features/orders/providers/order_detail_ui_provider.dart';
import 'package:krishi/features/orders/widgets/purchase_order_view.dart';
import 'package:krishi/features/orders/widgets/sales_order_view.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  final int? orderId;
  final int? itemId;
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(orderDetailProvider((
            orderId: widget.orderId,
            itemId: widget.itemId,
            isSeller: widget.isSeller,
          )).notifier)
          .loadOrderDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDetailProvider((
      orderId: widget.orderId,
      itemId: widget.itemId,
      isSeller: widget.isSeller,
    )));
    final uiState = ref.watch(orderDetailUIProvider((
      orderId: widget.orderId,
      itemId: widget.itemId,
    )));

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
        onRefresh: () => ref
            .read(orderDetailProvider((
              orderId: widget.orderId,
              itemId: widget.itemId,
              isSeller: widget.isSeller,
            )).notifier)
            .loadOrderDetails(),
        child: _buildBody(state, uiState),
      ),
    );
  }

  Widget _buildBody(OrderDetailState state, OrderDetailUIState uiState) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.all(16).rt,
        child: ErrorState(
          title: 'problem_fetching_data'.tr(context),
          subtitle: state.error,
          onRetry: () => ref
              .read(orderDetailProvider((
                orderId: widget.orderId,
                itemId: widget.itemId,
                isSeller: widget.isSeller,
              )).notifier)
              .loadOrderDetails(),
        ),
      );
    }

    if (state.order == null && state.orderItem == null) {
      return Center(child: AppText('order_not_found'.tr(context)));
    }

    return state.orderItem != null
        ? SalesOrderView(orderItem: state.orderItem!)
        : PurchaseOrderView(
            order: state.order!,
            isSeller: widget.isSeller,
            isProcessing: state.isProcessing,
            loadingPublicListingsId: uiState.loadingPublicListingsId,
            onDeleteOrder: _deleteOrder,
            onOpenPublicListings: _openPublicListings,
          );
  }

  Future<void> _openPublicListings(String? krId, String titleKey) async {
    if (krId == null || krId.isEmpty) {
      Get.snackbar('seller_id_unavailable'.tr(context), color: Colors.red);
      return;
    }
    
    // Store notifier reference before async gap
    final uiNotifier = ref.read(orderDetailUIProvider((
      orderId: widget.orderId,
      itemId: widget.itemId,
    )).notifier);
    
    uiNotifier.setLoadingPublicListingsId(krId);
    
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
      // Use stored notifier reference
      uiNotifier.setLoadingPublicListingsId(null);
    }
  }

  Future<void> _deleteOrder() async {
    final dialogContext = mounted ? context : Get.context;

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

    final success = await ref
        .read(orderDetailProvider((
          orderId: widget.orderId,
          itemId: widget.itemId,
          isSeller: widget.isSeller,
        )).notifier)
        .deleteOrder();

    if (!mounted) return;

    if (success) {
      Get.snackbar('order_deleted'.tr(context), color: Colors.green);
      Navigator.of(context).pop(true);
    } else {
      Get.snackbar('order_delete_failed'.tr(context), color: Colors.red);
    }
  }

}
