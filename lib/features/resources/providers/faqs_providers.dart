import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/models/resources.dart';

// FAQs providers
final faqsListProvider = StateProvider<List<FAQ>>(
  (ref) => [],
);

final isLoadingFAQsProvider = StateProvider<bool>((ref) => true);
final isLoadingMoreFAQsProvider = StateProvider<bool>((ref) => false);
final faqsCurrentPageProvider = StateProvider<int>((ref) => 1);
final faqsHasMoreProvider = StateProvider<bool>((ref) => true);

final faqsErrorProvider = StateProvider<String?>((ref) => null);

final expandedFAQIndexProvider = StateProvider<int?>((ref) => null);

