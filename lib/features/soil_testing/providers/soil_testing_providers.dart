import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/models/resources.dart';

// Soil testing providers
final soilTestsListProvider = StateProvider<List<SoilTest>>(
  (ref) => [],
);

final isLoadingSoilTestsProvider = StateProvider<bool>((ref) => true);

final isLoadingMoreSoilTestsProvider = StateProvider<bool>((ref) => false);

final hasMoreSoilTestsProvider = StateProvider<bool>((ref) => true);

final currentSoilTestsPageProvider = StateProvider<int>((ref) => 1);

final soilTestsSearchQueryProvider = StateProvider<String>((ref) => '');

