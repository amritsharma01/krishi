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
import 'package:krishi/features/seller/seller_public_listings_page.dart';
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
  List<Order> orders = [];
  List<Order> filteredOrders = [];
  bool isLoading = true;
  String? error;
  final Set<int> _completingOrders = {};
  String selectedFilter = 'all';
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _loadingPublicListingsId;

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
      filteredOrders = orders
          .where((order) => order.status.toLowerCase() == selectedFilter)
          .toList();
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
        final ordersList = cachedOrders
            .map((json) => Order.fromJson(json))
            .toList();
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
        final ordersJson = result.results.map((o) => o.toJson()).toList();
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

  Future<void> _completeOrder(Order order) async {
    if (_completingOrders.contains(order.id)) return;

    setState(() {
      _completingOrders.add(order.id);
    });

    try {
      final cacheService = ref.read(cacheServiceProvider);
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.completeOrder(order.id);

      // Clear cache to force refresh
      if (widget.showSales) {
        await cacheService.clearMySalesCache();
      } else {
        await cacheService.clearMyPurchasesCache();
      }

      if (!mounted) return;
      Get.snackbar('order_marked_complete'.tr(context), color: Colors.green);
      _completingOrders.remove(order.id);
      _loadOrders(refresh: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _completingOrders.remove(order.id);
      });
      Get.snackbar('order_complete_failed'.tr(context), color: Colors.red);
    }
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

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'all'.tr(context)},
      {'key': 'pending', 'label': 'pending'.tr(context)},
      {'key': 'accepted', 'label': 'accepted'.tr(context)},
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
        : orders.where((o) => o.status.toLowerCase() == filter['key']).length;

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
                        return _buildOrderCard(filteredOrders[index]);
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

  Widget _buildOrderCard(Order order) {
    final status = order.status.toLowerCase();
    final isCompleted = status == 'completed';
    final showCompleteButton = !widget.showSales && status == 'delivered';
    final isCompleting = _completingOrders.contains(order.id);
    final canEditContact = _canEditContactDetails(order);
    final displayStatus =
        (order.statusDisplay != null && order.statusDisplay!.trim().isNotEmpty)
        ? order.statusDisplay!
        : _capitalize(order.status);
    final (Color bgColor, Color textColor, Color borderColor) = _statusColors(
      status,
    );
    return InkWell(
      onTap: () => _navigateToOrderDetail(order),
      borderRadius: BorderRadius.circular(16).rt,
      child: Container(
        padding: const EdgeInsets.all(12).rt,
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
            Row(
              children: [
                Expanded(
                  child: AppText(
                    order.productName,
                    style: Get.bodyMedium.px16.w700.copyWith(
                      color: Get.disabledColor,
                    ),
                    maxLines: 1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
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
              ],
            ),
            3.verticalGap,
            AppText(
              _dateFormat.format(order.createdAt.toLocal()),
              style: Get.bodySmall.px12.w500.copyWith(
                color: Get.disabledColor.withValues(alpha: 0.6),
              ),
            ),
            12.verticalGap,
            Wrap(
              spacing: 8.rt,
              runSpacing: 6.rt,
              children: [
                _buildInfoChip(
                  label: 'Rs. ${order.totalAmountAsDouble.toStringAsFixed(2)}',
                ),
                _buildInfoChip(
                  icon: Icons.shopping_cart_rounded,
                  label: '${order.quantity} pcs',
                ),
                _buildInfoChip(
                  icon: Icons.badge_outlined,
                  label:
                      '${widget.showSales ? 'buyer_id_label'.tr(context) : 'seller_id_label'.tr(context)}: ${(widget.showSales ? order.buyerKrId : order.sellerKrId) ?? 'seller_id_unavailable'.tr(context)}',
                ),
              ],
            ),

            8.verticalGap,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.showSales || !canEditContact
                        ? () => _navigateToOrderDetail(order)
                        : () => _handleEditOrder(order),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12).rt,
                      side: BorderSide(
                        color: Get.disabledColor.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12).rt,
                      ),
                    ),
                    child: AppText(
                      (!widget.showSales && canEditContact)
                          ? 'edit_order'.tr(context)
                          : 'view_details'.tr(context),
                      style: Get.bodyMedium.px13.w600.copyWith(
                        color: (!widget.showSales && canEditContact)
                            ? AppColors.primary
                            : Get.disabledColor,
                      ),
                    ),
                  ),
                ),
                if (showCompleteButton) ...[
                  12.horizontalGap,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isCompleting
                          ? null
                          : () => _completeOrder(order),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12).rt,
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12).rt,
                        ),
                      ),
                      child: isCompleting
                          ? SizedBox(
                              height: 18.st,
                              width: 18.st,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : AppText(
                              'mark_as_complete'.tr(context),
                              style: Get.bodyMedium.px13.w700.copyWith(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
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

  bool _showQuickAction(Order order) {
    final status = order.status.toLowerCase();
    // Show view details button for all active orders
    return status != 'completed' && status != 'cancelled';
  }

  bool _canEditContactDetails(Order order) {
    if (widget.showSales) return false;
    final status = order.status.toLowerCase();
    return status == 'pending' ||
        status == 'accepted' ||
        status == 'in_transit';
  }

  Future<void> _handleEditOrder(Order order) async {
    final updatedOrder = await _showEditOrderSheet(order);
    if (updatedOrder != null && mounted) {
      setState(() {
        final index = orders.indexWhere((o) => o.id == updatedOrder.id);
        if (index != -1) {
          orders[index] = updatedOrder;
        }
        _filterOrders();
      });
      Get.snackbar('contact_update_success'.tr(context), color: Colors.green);
    }
  }

  Future<Order?> _showEditOrderSheet(Order order) {
    final nameController = TextEditingController(text: order.buyerName);
    final addressController = TextEditingController(text: order.buyerAddress);
    final phoneController = TextEditingController(text: order.buyerPhoneNumber);
    final formKey = GlobalKey<FormState>();

    return showModalBottomSheet<Order>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Get.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.rt)),
      ),
      builder: (context) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> submit() async {
              if (isSaving) return;
              if (!(formKey.currentState?.validate() ?? false)) return;
              setModalState(() => isSaving = true);
              try {
                final updatedOrder = await ref
                    .read(krishiApiServiceProvider)
                    .updateOrderContactDetails(
                      orderId: order.id,
                      buyerName: nameController.text.trim(),
                      buyerAddress: addressController.text.trim(),
                      buyerPhoneNumber: phoneController.text.trim(),
                    );
                if (context.mounted) {
                  Navigator.of(context).pop(updatedOrder);
                }
              } catch (e) {
                setModalState(() => isSaving = false);
                Get.snackbar('contact_update_failed'.tr(context));
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20.wt,
                right: 20.wt,
                top: 24.ht,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.ht,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Get.disabledColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    16.verticalGap,
                    AppText(
                      'update_contact_details'.tr(context),
                      style: Get.bodyLarge.px18.w700.copyWith(
                        color: Get.disabledColor,
                      ),
                    ),
                    16.verticalGap,
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'buyer_name_label'.tr(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12).rt,
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'required_field'.tr(context)
                          : null,
                    ),
                    12.verticalGap,
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'buyer_address_label'.tr(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12).rt,
                        ),
                      ),
                      minLines: 2,
                      maxLines: 4,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'required_field'.tr(context)
                          : null,
                    ),
                    12.verticalGap,
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'buyer_phone_label'.tr(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12).rt,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'required_field'.tr(context)
                          : null,
                    ),
                    20.verticalGap,
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 14.ht),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12).rt,
                          ),
                        ),
                        child: isSaving
                            ? SizedBox(
                                height: 18.st,
                                width: 18.st,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : AppText(
                                'save_changes'.tr(context),
                                style: Get.bodyMedium.px14.w600.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToOrderDetail(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OrderDetailPage(orderId: order.id, isSeller: widget.showSales),
      ),
    ).then((result) {
      if (result == true && mounted) {
        _loadOrders();
      }
    });
  }

  (Color, Color, Color) _statusColors(String status) {
    switch (status) {
      case 'completed':
        return (
          Colors.green.withValues(alpha: 0.15),
          Colors.green.shade800,
          Colors.green.withValues(alpha: 0.3),
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
