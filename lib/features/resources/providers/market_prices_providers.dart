import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/models/resources.dart';

// Market prices providers
final marketPricesListProvider = StateProvider<List<MarketPrice>>(
  (ref) => [],
);

final isLoadingMarketPricesProvider = StateProvider<bool>((ref) => true);

final isLoadingMoreMarketPricesProvider = StateProvider<bool>((ref) => false);

final hasMoreMarketPricesProvider = StateProvider<bool>((ref) => true);

final currentMarketPricesPageProvider = StateProvider<int>((ref) => 1);

final marketPricesSearchQueryProvider = StateProvider<String>((ref) => '');

final selectedMarketPriceCategoryProvider = StateProvider<String>((ref) => 'all');

final marketPricesCategoriesProvider = StateProvider<Map<String, String>>(
  (ref) => {},
);

