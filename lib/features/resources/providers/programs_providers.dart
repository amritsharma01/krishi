import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/models/resources.dart';

// Programs providers
final programsListProvider = StateProvider<List<Program>>(
  (ref) => [],
);

final isLoadingProgramsProvider = StateProvider<bool>((ref) => true);

final isLoadingMoreProgramsProvider = StateProvider<bool>((ref) => false);

final hasMoreProgramsProvider = StateProvider<bool>((ref) => true);

final currentProgramsPageProvider = StateProvider<int>((ref) => 1);

final programsSearchQueryProvider = StateProvider<String>((ref) => '');

