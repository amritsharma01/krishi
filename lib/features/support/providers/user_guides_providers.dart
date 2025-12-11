import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/models/resources.dart';

// User guides providers
final userGuidesListProvider = StateProvider<List<UserManual>>(
  (ref) => [],
);

final isLoadingUserGuidesProvider = StateProvider<bool>((ref) => true);
final isLoadingMoreUserGuidesProvider = StateProvider<bool>((ref) => false);
final userGuidesCurrentPageProvider = StateProvider<int>((ref) => 1);
final userGuidesHasMoreProvider = StateProvider<bool>((ref) => true);

final selectedUserGuideCategoryProvider = StateProvider<String>((ref) => 'all');

