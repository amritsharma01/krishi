import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/models/category.dart';
import 'package:krishi/models/comment.dart';
import 'package:krishi/models/product.dart';
import 'package:krishi/models/review.dart';
import 'package:krishi/models/unit.dart';

// Categories Provider
final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final apiService = ref.watch(krishiApiServiceProvider);
  return await apiService.getCategories();
});

// Units Provider
final unitsProvider = FutureProvider.autoDispose<List<Unit>>((ref) async {
  final apiService = ref.watch(krishiApiServiceProvider);
  return await apiService.getUnits();
});

// Product Reviews Provider
final productReviewsProvider = FutureProvider.autoDispose.family<List<Review>, int>(
  (ref, productId) async {
    final apiService = ref.watch(krishiApiServiceProvider);
    return await apiService.getProductReviews(productId);
  },
);

// Product Comments Provider
final productCommentsProvider = FutureProvider.autoDispose.family<List<Comment>, int>(
  (ref, productId) async {
    final apiService = ref.watch(krishiApiServiceProvider);
    return await apiService.getProductComments(productId);
  },
);

// Product Detail Provider (if needed for refreshing product data)
final productDetailProvider = FutureProvider.autoDispose.family<Product, int>(
  (ref, productId) async {
    final apiService = ref.watch(krishiApiServiceProvider);
    return await apiService.getProduct(productId);
  },
);
