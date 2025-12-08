import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/models/resources.dart';

final selectedContactUsTypeProvider = StateProvider<String>((ref) => 'all');
final isLoadingContactUsProvider = StateProvider<bool>((ref) => true);

final contactUsListProvider = FutureProvider.family<List<Contact>, String?>((ref, contactType) async {
  final apiService = ref.read(krishiApiServiceProvider);
  return apiService.getContacts(contactType: contactType == 'all' ? null : contactType);
});

