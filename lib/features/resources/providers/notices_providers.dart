import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/models/resources.dart';

// Notices providers
final noticesListProvider = StateProvider<List<Notice>>(
  (ref) => [],
);

final isLoadingNoticesProvider = StateProvider<bool>((ref) => true);
final isLoadingMoreNoticesProvider = StateProvider<bool>((ref) => false);
final noticesCurrentPageProvider = StateProvider<int>((ref) => 1);
final noticesHasMoreProvider = StateProvider<bool>((ref) => true);

final selectedNoticeFilterProvider = StateProvider<String>((ref) => 'all');

