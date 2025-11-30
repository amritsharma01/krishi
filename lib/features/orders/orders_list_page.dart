import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/orders/order_detail_page.dart';
import 'package:krishi/features/orders/providers/orders_list_provider.dart';
import 'package:krishi/features/orders/widgets/filter_chips.dart';
import 'package:krishi/features/orders/widgets/orders_list_content.dart';
class OrdersListPage extends ConsumerStatefulWidget {
  final bool showSales;

  const OrdersListPage.sales({super.key}) : showSales = true;
  const OrdersListPage.purchases({super.key}) : showSales = false;

  @override
  ConsumerState<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends ConsumerState<OrdersListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersListProvider(widget.showSales).notifier).loadOrders();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(ordersListProvider(widget.showSales));
    if (!_scrollController.hasClients || state.isLoadingMore || !state.hasMore) {
      return;
    }

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(ordersListProvider(widget.showSales).notifier).loadMoreOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersListProvider(widget.showSales));
    final title = widget.showSales
        ? 'received_orders'.tr(context)
        : 'placed_orders'.tr(context);

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          title,
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.disabledColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          OrderFilterChips(
            state: state,
            showSales: widget.showSales,
            onFilterSelected: (filter) => ref
                .read(ordersListProvider(widget.showSales).notifier)
                .setFilter(filter),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(ordersListProvider(widget.showSales).notifier)
                  .loadOrders(refresh: true),
              child: OrdersListContent(
                state: state,
                showSales: widget.showSales,
                scrollController: _scrollController,
                onRetry: () => ref
                    .read(ordersListProvider(widget.showSales).notifier)
                    .loadOrders(),
                onNavigateToDetail: _navigateToOrderDetail,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToOrderDetail(int id, {bool isItemId = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailPage(
          orderId: isItemId ? null : id,
          itemId: isItemId ? id : null,
          isSeller: widget.showSales,
        ),
      ),
    ).then((result) {
      if (result == true && mounted) {
        ref.read(ordersListProvider(widget.showSales).notifier).loadOrders(refresh: true);
      }
    });
  }
}
