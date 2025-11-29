import 'dart:async';

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
import 'package:krishi/core/services/cache_service.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/empty_state.dart';
import 'package:krishi/features/components/error_state.dart';
import 'package:krishi/features/orders/order_detail_page.dart';
import 'package:krishi/models/order.dart';

class OrdersListPage extends ConsumerStatefulWidget {
  final bool showSales;

  const OrdersListPage.sales({super.key}) : showSales = true;
  const OrdersListPage.purchases({super.key}) : showSales = false;

  @override
  ConsumerState<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends ConsumerState<OrdersListPage> {
  final _dateFormat = DateFormat('MMM d, yyyy • h:mm a');
  // For purchases: List<Order>
  // For sales: List<OrderItemSeller>
  List<dynamic> orders = [];
  List<dynamic> filteredOrders = [];
  bool isLoading = true;
  String? error;
  String selectedFilter = 'all';
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadOrders();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _filterOrders() {
    if (selectedFilter == 'all') {
      filteredOrders = orders;
    } else {
      filteredOrders = orders.where((item) {
        if (widget.showSales) {
          final orderItem = item as OrderItemSeller;
          return orderItem.orderStatus.toLowerCase() == selectedFilter;
        } else {
          final order = item as Order;
          return order.status.toLowerCase() == selectedFilter;
        }
      }).toList();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) return;
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreOrders();
    }
  }

  Future<void> _loadOrders({bool refresh = false}) async {
    _currentPage = 1;
    _hasMore = true;

    final cacheService = ref.read(cacheServiceProvider);
    final apiService = ref.read(krishiApiServiceProvider);

    // Try to load from cache first (only for initial load, not refresh)
    if (!refresh) {
      final cachedOrders = widget.showSales
          ? await cacheService.getMySalesCache()
          : await cacheService.getMyPurchasesCache();

      if (cachedOrders != null && cachedOrders.isNotEmpty) {
        final ordersList = widget.showSales
            ? cachedOrders
                  .map((json) => OrderItemSeller.fromJson(json))
                  .toList()
            : cachedOrders.map((json) => Order.fromJson(json)).toList();
        if (mounted) {
          setState(() {
            orders = ordersList;
            _filterOrders();
            isLoading =
                false; // Show cached data immediately, no loading spinner
            error = null;
          });
        }
      } else {
        // No cache available, show loading state
        if (mounted) {
          setState(() {
            isLoading = true;
            error = null;
            orders = [];
            filteredOrders = [];
          });
        }
      }
    } else {
      // Refresh - clear error but keep showing current data
      if (mounted) {
        setState(() {
          error = null;
        });
      }
    }

    try {
      // Fetch fresh data from API (always fetch, but don't block UI if cache exists)
      final result = widget.showSales
          ? await apiService.getMySalesPaginated(page: _currentPage)
          : await apiService.getMyPurchasesPaginated(page: _currentPage);

      // Save to cache (only first page)
      if (_currentPage == 1) {
        final ordersJson = widget.showSales
            ? (result.results as List<OrderItemSeller>)
                  .map((o) => o.toJson())
                  .toList()
            : (result.results as List<Order>).map((o) => o.toJson()).toList();
        if (widget.showSales) {
          await cacheService.saveMySalesCache(ordersJson);
        } else {
          await cacheService.saveMyPurchasesCache(ordersJson);
        }
      }

      // Update UI with fresh data
      if (mounted) {
        setState(() {
          orders = result.results;
          _filterOrders();
          isLoading = false;
          _hasMore = result.next != null;
          _currentPage = _hasMore ? _currentPage + 1 : _currentPage;
        });
      }
    } catch (e) {
      // If we have cached data and API fails, keep showing cached data
      if (!refresh && orders.isNotEmpty) {
        if (mounted) {
          setState(() {
            isLoading = false;
            // Don't set error if we have cached data to show
          });
        }
      } else {
        if (mounted) {
          setState(() {
            error = e.toString();
            isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _loadMoreOrders() async {
    if (_isLoadingMore || !_hasMore || isLoading) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final result = widget.showSales
          ? await apiService.getMySalesPaginated(page: _currentPage)
          : await apiService.getMyPurchasesPaginated(page: _currentPage);

      if (!mounted) return;
      setState(() {
        orders = [...orders, ...result.results];
        _filterOrders();
        _hasMore = result.next != null;
        if (_hasMore) {
          _currentPage += 1;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
      Get.snackbar('problem_fetching_data'.tr(context), color: Colors.red);
    }
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'all'.tr(context)},
      {'key': 'pending', 'label': 'awaiting_admin_approval'.tr(context)},
      {'key': 'approved', 'label': 'approved'.tr(context)},
      {'key': 'rejected', 'label': 'rejected'.tr(context)},
      {'key': 'in_transit', 'label': 'in_transit'.tr(context)},
      {'key': 'delivered', 'label': 'delivered'.tr(context)},
      {'key': 'completed', 'label': 'completed'.tr(context)},
      {'key': 'cancelled', 'label': 'cancelled'.tr(context)},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).rt,
      child: Row(
        children: filters
            .map(
              (filter) => Padding(
                padding: EdgeInsets.only(right: 8.rt),
                child: _buildFilterPill(filter),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildFilterPill(Map<String, String> filter) {
    final isSelected = selectedFilter == filter['key'];
    final count = filter['key'] == 'all'
        ? orders.length
        : orders.where((item) {
            if (widget.showSales) {
              final orderItem = item as OrderItemSeller;
              return orderItem.orderStatus.toLowerCase() == filter['key'];
            } else {
              final order = item as Order;
              return order.status.toLowerCase() == filter['key'];
            }
          }).length;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter['key']!;
          _filterOrders();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8).rt,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Get.cardColor,
          borderRadius: BorderRadius.circular(20).rt,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Get.disabledColor.withValues(alpha: 0.2),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: AppText(
          '${filter['label']} ($count)',
          style: Get.bodySmall.px12.w600.copyWith(
            color: isSelected ? Colors.white : Get.disabledColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          _buildFilterChips(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadOrders(refresh: true),
              child: isLoading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        80.verticalGap,
                        Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    )
                  : error != null
                  ? Padding(
                      padding: const EdgeInsets.all(16).rt,
                      child: ErrorState(
                        title: 'problem_fetching_data'.tr(context),
                        subtitle: error,
                        onRetry: () => _loadOrders(),
                      ),
                    )
                  : filteredOrders.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16).rt,
                      child: EmptyState(
                        title: widget.showSales
                            ? 'no_sales'.tr(context)
                            : 'no_purchases'.tr(context),
                        subtitle: widget.showSales
                            ? 'no_sales_message'.tr(context)
                            : 'no_purchases_message'.tr(context),
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16).rt,
                      itemBuilder: (_, index) {
                        if (index >= filteredOrders.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ).rt,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }
                        final item = filteredOrders[index];
                        return widget.showSales
                            ? _buildSalesOrderCard(item as OrderItemSeller)
                            : _buildPurchaseOrderCard(item as Order);
                      },
                      separatorBuilder: (_, __) => 12.verticalGap,
                      itemCount:
                          filteredOrders.length + (_isLoadingMore ? 1 : 0),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseOrderCard(Order order) {
    final status = order.status.toLowerCase();
    final isCompleted = status == 'completed';
    final displayStatus =
        (order.statusDisplay != null && order.statusDisplay!.trim().isNotEmpty)
        ? order.statusDisplay!
        : _capitalize(order.status);
    final (Color bgColor, Color textColor, Color borderColor) = _statusColors(
      status,
    );
    return InkWell(
      onTap: () => _navigateToOrderDetail(order.id),
      borderRadius: BorderRadius.circular(16).rt,
      child: Container(
        padding: const EdgeInsets.all(16).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(20).rt,
          border: Border.all(
            color: isCompleted
                ? bgColor
                : Get.disabledColor.withValues(alpha: 0.08),
            width: 1,
          ),
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
            // Order ID
            AppText(
              'order_id'.tr(context) + ' #${order.id}',
              style: Get.bodyMedium.px16.w700.copyWith(
                color: Get.disabledColor,
              ),
            ),
            8.verticalGap,
            // Order date
            AppText(
              _dateFormat.format(order.createdAt.toLocal()),
              style: Get.bodySmall.px13.w500.copyWith(
                color: Get.disabledColor.withValues(alpha: 0.6),
              ),
            ),
            12.verticalGap,
            // Status, Items count, and Amount chips
            Wrap(
              spacing: 8.rt,
              runSpacing: 8.rt,
              children: [
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ).rt,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12).rt,
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: AppText(
                    displayStatus,
                    style: Get.bodySmall.px12.w700.copyWith(color: textColor),
                  ),
                ),
                // Items count chip
                _buildInfoChip(
                  icon: Icons.shopping_basket,
                  label: '${order.itemsCount} ${'items_count'.tr(context)}',
                ),
                // Amount chip
                _buildInfoChip(
                  label: 'Rs. ${order.totalAmountAsDouble.toStringAsFixed(2)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({IconData? icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 16.st,
              color: Get.disabledColor.withValues(alpha: 0.7),
            ),
          if (icon != null) 6.horizontalGap,
          AppText(
            label,
            style: Get.bodySmall.px12.w600.copyWith(color: Get.disabledColor),
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
        _loadOrders();
      }
    });
  }

  Widget _buildSalesOrderCard(OrderItemSeller orderItem) {
    final status = orderItem.orderStatus.toLowerCase();
    final isCompleted = status == 'completed';
    final displayStatus = orderItem.statusDisplay;
    final (Color bgColor, Color textColor, Color borderColor) = _statusColors(
      status,
    );
    return InkWell(
      onTap: () => _navigateToOrderDetail(orderItem.id, isItemId: true),
      borderRadius: BorderRadius.circular(16).rt,
      child: Container(
        padding: const EdgeInsets.all(16).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(20).rt,
          border: Border.all(
            color: isCompleted
                ? bgColor
                : Get.disabledColor.withValues(alpha: 0.08),
            width: 1,
          ),
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
            // Order ID
            AppText(
              orderItem.productName,
              style: Get.bodyMedium.px16.w700.copyWith(
                color: Get.disabledColor,
              ),
            ),
            6.verticalGap,
            // Order date
            AppText(
              _dateFormat.format(orderItem.orderDate.toLocal()),
              style: Get.bodySmall.px13.w500.copyWith(
                color: Get.disabledColor.withValues(alpha: 0.6),
              ),
            ),
            12.verticalGap,
            // Status, Product name, Base price, Quantity chips
            Wrap(
              spacing: 8.rt,
              runSpacing: 8.rt,
              children: [
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ).rt,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12).rt,
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: AppText(
                    displayStatus,
                    style: Get.bodySmall.px12.w700.copyWith(color: textColor),
                  ),
                ),
                // Product name chip
                _buildInfoChip(
                  icon: Icons.shopping_bag,

             label:'${'order_id'.tr(context)} #${orderItem.orderId}',
               
                ),
                // Base price chip
                _buildInfoChip(
                  label:
                      'Rs. ${(orderItem.basePriceAsDouble*orderItem.quantity).toStringAsFixed(2)}',
                ),
                // Quantity chip
                _buildInfoChip(
                  icon: Icons.production_quantity_limits,
                  label: 'Qty: ${orderItem.quantity}',
                ),
              ],
            ),
          ],
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

  String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}
