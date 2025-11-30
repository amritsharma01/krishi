import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/models/order.dart';

class OrderDetailState {
  final Order? order;
  final OrderItemSeller? orderItem;
  final bool isLoading;
  final String? error;
  final bool isProcessing;

  const OrderDetailState({
    this.order,
    this.orderItem,
    this.isLoading = true,
    this.error,
    this.isProcessing = false,
  });

  OrderDetailState copyWith({
    Order? order,
    OrderItemSeller? orderItem,
    bool? isLoading,
    String? error,
    bool? isProcessing,
  }) {
    return OrderDetailState(
      order: order ?? this.order,
      orderItem: orderItem ?? this.orderItem,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class OrderDetailNotifier extends StateNotifier<OrderDetailState> {
  final Ref ref;
  final int? orderId;
  final int? itemId;
  final bool isSeller;

  OrderDetailNotifier(
    this.ref, {
    required this.orderId,
    required this.itemId,
    required this.isSeller,
  }) : super(const OrderDetailState());

  Future<void> loadOrderDetails() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      
      if (itemId != null && isSeller) {
        final result = await apiService.getOrderItemDetail(itemId!);
        if (mounted) {
          state = state.copyWith(orderItem: result, isLoading: false);
        }
      } else if (orderId != null) {
        final result = await apiService.getOrder(orderId!);
        if (mounted) {
          state = state.copyWith(order: result, isLoading: false);
        }
      } else {
        if (mounted) {
          state = state.copyWith(
            error: 'Invalid order or item ID',
            isLoading: false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: e.toString(), isLoading: false);
      }
    }
  }

  Future<bool> deleteOrder() async {
    if (state.order == null || !mounted) return false;

    state = state.copyWith(isProcessing: true);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.deleteOrder(state.order!.id);
      return true;
    } catch (e) {
      return false;
    } finally {
      if (mounted) {
        state = state.copyWith(isProcessing: false);
      }
    }
  }
}

final orderDetailProvider = StateNotifierProvider.family<
    OrderDetailNotifier,
    OrderDetailState,
    ({int? orderId, int? itemId, bool isSeller})>(
  (ref, params) {
    return OrderDetailNotifier(
      ref,
      orderId: params.orderId,
      itemId: params.itemId,
      isSeller: params.isSeller,
    );
  },
);
