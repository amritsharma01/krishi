import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/models/resources.dart';

// Crop calendar providers
final cropCalendarListProvider = StateProvider<List<CropCalendar>>(
  (ref) => [],
);

final isLoadingCropCalendarProvider = StateProvider<bool>((ref) => true);
final isLoadingMoreCropCalendarProvider = StateProvider<bool>((ref) => false);
final cropCalendarCurrentPageProvider = StateProvider<int>((ref) => 1);
final cropCalendarHasMoreProvider = StateProvider<bool>((ref) => true);

final selectedCropTypeProvider = StateProvider<String>((ref) => 'all');

