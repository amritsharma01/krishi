import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/models/resources.dart';

// Emergency contacts providers
final emergencyContactsListProvider = StateProvider<List<Contact>>(
  (ref) => [],
);

final isLoadingEmergencyContactsProvider = StateProvider<bool>((ref) => true);
final isLoadingMoreEmergencyContactsProvider = StateProvider<bool>((ref) => false);
final emergencyContactsCurrentPageProvider = StateProvider<int>((ref) => 1);
final emergencyContactsHasMoreProvider = StateProvider<bool>((ref) => true);

final selectedContactTypeProvider = StateProvider<String>((ref) => 'all');

