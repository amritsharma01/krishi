import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/models/resources.dart';

// Videos providers
final videosListProvider = StateProvider<List<Video>>(
  (ref) => [],
);

final isLoadingVideosProvider = StateProvider<bool>((ref) => true);

final selectedVideoCategoryProvider = StateProvider<String>((ref) => 'all');

