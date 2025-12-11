import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/models/resources.dart';

// Dynamic market prices providers
final dynamicMarketPricesDataProvider =
    StateProvider<DynamicMarketPricesData?>((ref) => null);

final isLoadingDynamicMarketPricesProvider =
    StateProvider<bool>((ref) => false);

final dynamicMarketPricesErrorProvider =
    StateProvider<String?>((ref) => null);

final currentDynamicMarketPricesPageProvider =
    StateProvider<int>((ref) => 1);

final hasMoreDynamicMarketPricesProvider =
    StateProvider<bool>((ref) => true);

final dynamicMarketPricesNextPageProvider =
    StateProvider<String?>((ref) => null);

