import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/models/order.dart';

class OrdersListState {
  final List<dynamic> orders;
  final List<dynamic> filteredOrders;
  final bool isLoading;
  final String? error;
  final String selectedFilter;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const OrdersListState({
    this.orders = const [],
    this.filteredOrders = const [],
    this.isLoading = true,
    this.error,
    this.selectedFilter = 'all',
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  OrdersListState copyWith({
    List<dynamic>? orders,
    List<dynamic>? filteredOrders,
    bool? isLoading,
    String? error,
    String? selectedFilter,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return OrdersListState(
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class OrdersListNotifier extends StateNotifier<OrdersListState> {
  final Ref ref;
  final bool showSales;

  OrdersListNotifier(this.ref, {required this.showSales})
      : super(const OrdersListState());

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
    _filterOrders();
  }

  void _filterOrders() {
    if (state.selectedFilter == 'all') {
      state = state.copyWith(filteredOrders: state.orders);
    } else {
      final filtered = state.orders.where((item) {
        if (showSales) {
          final orderItem = item as OrderItemSeller;
          return orderItem.orderStatus.toLowerCase() == state.selectedFilter;
        } else {
          final order = item as Order;
          return order.status.toLowerCase() == state.selectedFilter;
        }
      }).toList();
      state = state.copyWith(filteredOrders: filtered);
    }
  }

  Future<void> loadOrders({bool refresh = false}) async {
    if (!refresh && state.orders.isNotEmpty) {
      _filterOrders();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      currentPage: 1,
      hasMore: true,
    );

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final result = showSales
          ? await apiService.getMySalesPaginated(page: 1)
          : await apiService.getMyPurchasesPaginated(page: 1);

      if (mounted) {
        state = state.copyWith(
          orders: result.results,
          isLoading: false,
          hasMore: result.next != null,
          currentPage: 2,
        );
        _filterOrders();
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: e.toString(), isLoading: false);
      }
    }
  }

  Future<void> loadMoreOrders() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final result = showSales
          ? await apiService.getMySalesPaginated(page: state.currentPage)
          : await apiService.getMyPurchasesPaginated(page: state.currentPage);

      if (mounted) {
        state = state.copyWith(
          orders: [...state.orders, ...result.results],
          hasMore: result.next != null,
          currentPage: result.next != null ? state.currentPage + 1 : state.currentPage,
          isLoadingMore: false,
        );
        _filterOrders();
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoadingMore: false);
      }
    }
  }
}

final ordersListProvider = StateNotifierProvider.family<
    OrdersListNotifier,
    OrdersListState,
    bool>(
  (ref, showSales) {
    return OrdersListNotifier(ref, showSales: showSales);
  },
);
