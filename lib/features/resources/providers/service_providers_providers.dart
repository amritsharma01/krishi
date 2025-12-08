import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/models/resources.dart';

// Service providers providers
final serviceProvidersListProvider = StateProvider<List<ServiceProvider>>(
  (ref) => [],
);

final isLoadingServiceProvidersProvider = StateProvider<bool>((ref) => true);

final selectedServiceTypeProvider = StateProvider<String>((ref) => 'all');

