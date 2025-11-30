import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderDetailUIState {
  final String? loadingPublicListingsId;

  const OrderDetailUIState({
    this.loadingPublicListingsId,
  });

  OrderDetailUIState copyWith({
    String? Function()? loadingPublicListingsId,
  }) {
    return OrderDetailUIState(
      loadingPublicListingsId: loadingPublicListingsId != null
          ? loadingPublicListingsId()
          : this.loadingPublicListingsId,
    );
  }
}

class OrderDetailUINotifier extends StateNotifier<OrderDetailUIState> {
  OrderDetailUINotifier() : super(const OrderDetailUIState());

  void setLoadingPublicListingsId(String? id) {
    state = state.copyWith(loadingPublicListingsId: () => id);
  }
}

final orderDetailUIProvider = StateNotifierProvider.family
    .autoDispose<OrderDetailUINotifier, OrderDetailUIState, ({int? orderId, int? itemId})>(
  (ref, params) => OrderDetailUINotifier(),
);
