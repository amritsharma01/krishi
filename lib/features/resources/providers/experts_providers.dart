import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/models/resources.dart';

// Experts providers
final expertsListProvider = StateProvider<List<Expert>>(
  (ref) => [],
);

final isLoadingExpertsProvider = StateProvider<bool>((ref) => true);

