import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/models/resources.dart';

final selectedContactUsTypeProvider = StateProvider<String>((ref) => 'all');
final contactUsListProvider = StateProvider<List<Contact>>((ref) => []);
final isLoadingContactUsProvider = StateProvider<bool>((ref) => true);
final isLoadingMoreContactUsProvider = StateProvider<bool>((ref) => false);
final contactUsCurrentPageProvider = StateProvider<int>((ref) => 1);
final contactUsHasMoreProvider = StateProvider<bool>((ref) => true);
