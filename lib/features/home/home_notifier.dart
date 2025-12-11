import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/models/product.dart';
import 'package:krishi/models/user_profile.dart';
import 'package:krishi/models/resources.dart';

class OrdersCounts {
  final int salesCount;
  final int purchasesCount;

  const OrdersCounts({
    required this.salesCount,
    required this.purchasesCount,
  });
}

class HomeState {
  final List<Product> trendingProducts;
  final OrdersCounts ordersCounts;
  final List<MarketPrice> marketPrices;
  final User? currentUser;
  final bool isLoadingProducts;
  final bool isLoadingOrders;
  final bool isLoadingMarketPrices;
  final String? productsError;
  final String? ordersError;
  final String? marketPricesError;

  const HomeState({
    this.trendingProducts = const [],
    this.ordersCounts = const OrdersCounts(salesCount: 0, purchasesCount: 0),
    this.marketPrices = const [],
    this.currentUser,
    this.isLoadingProducts = true,
    this.isLoadingOrders = true,
    this.isLoadingMarketPrices = true,
    this.productsError,
    this.ordersError,
    this.marketPricesError,
  });

  HomeState copyWith({
    List<Product>? trendingProducts,
    OrdersCounts? ordersCounts,
    List<MarketPrice>? marketPrices,
    User? currentUser,
    bool? isLoadingProducts,
    bool? isLoadingOrders,
    bool? isLoadingMarketPrices,
    String? productsError,
    String? ordersError,
    String? marketPricesError,
  }) {
    return HomeState(
      trendingProducts: trendingProducts ?? this.trendingProducts,
      ordersCounts: ordersCounts ?? this.ordersCounts,
      marketPrices: marketPrices ?? this.marketPrices,
      currentUser: currentUser ?? this.currentUser,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      isLoadingOrders: isLoadingOrders ?? this.isLoadingOrders,
      isLoadingMarketPrices: isLoadingMarketPrices ?? this.isLoadingMarketPrices,
      productsError: productsError,
      ordersError: ordersError,
      marketPricesError: marketPricesError,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final Ref ref;

  HomeNotifier(this.ref) : super(const HomeState());

  Future<void> loadAll() async {
    await Future.wait([
      _loadProfile(),
      loadTrendingProducts(),
      loadOrdersCounts(),
      loadMarketPrices(),
    ]);
  }

  Future<void> _loadProfile() async {
    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final user = await apiService.getCurrentUser();
      if (mounted) {
        state = state.copyWith(currentUser: user);
      }
    } catch (_) {
      // ignore profile fetch errors silently
    }
  }

  Future<void> loadOrdersCounts() async {
    state = state.copyWith(isLoadingOrders: true, ordersError: null);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final counts = await apiService.getOrdersCounts();

      if (mounted) {
        state = state.copyWith(
          ordersCounts: OrdersCounts(
            salesCount: counts.salesCount,
            purchasesCount: counts.purchasesCount,
          ),
          isLoadingOrders: false,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          ordersError: e.toString(),
          isLoadingOrders: false,
        );
      }
    }
  }

  Future<void> loadTrendingProducts() async {
    state = state.copyWith(isLoadingProducts: true, productsError: null);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getProducts(page: 1);
      final filtered = response.results
          .where((product) => product.isAvailable)
          .toList();
      
      if (mounted) {
        state = state.copyWith(
          trendingProducts: filtered.take(5).toList(),
          isLoadingProducts: false,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          productsError: e.toString(),
          isLoadingProducts: false,
        );
      }
    }
  }

  Future<void> loadMarketPrices() async {
    state = state.copyWith(isLoadingMarketPrices: true, marketPricesError: null);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getMarketPrices(
        page: 1,
        ordering: '-updated_at',
      );
      
      if (mounted) {
        state = state.copyWith(
          marketPrices: response.results.take(4).toList(),
          isLoadingMarketPrices: false,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          marketPricesError: e.toString(),
          isLoadingMarketPrices: false,
        );
      }
    }
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref);
});
