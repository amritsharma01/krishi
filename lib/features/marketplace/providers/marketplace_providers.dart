import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/models/product.dart';
import 'package:krishi/models/category.dart';
import 'package:krishi/models/comment.dart';
import 'package:krishi/models/review.dart';
import 'package:krishi/models/unit.dart';

// Categories Provider
final categoriesProvider = FutureProvider.autoDispose<List<Category>>((
  ref,
) async {
  final apiService = ref.watch(krishiApiServiceProvider);
  return await apiService.getCategories();
});

// Units Provider
final unitsProvider = FutureProvider.autoDispose<List<Unit>>((ref) async {
  final apiService = ref.watch(krishiApiServiceProvider);
  return await apiService.getUnits();
});

// Product Reviews Provider
final productReviewsProvider = FutureProvider.autoDispose
    .family<List<Review>, int>((ref, productId) async {
      final apiService = ref.watch(krishiApiServiceProvider);
      return await apiService.getProductReviews(productId);
    });

// Product Comments Provider
final productCommentsProvider = FutureProvider.autoDispose
    .family<List<Comment>, int>((ref, productId) async {
      final apiService = ref.watch(krishiApiServiceProvider);
      return await apiService.getProductComments(productId);
    });

// Product Detail Provider (if needed for refreshing product data)
final productDetailProvider = FutureProvider.autoDispose.family<Product, int>((
  ref,
  productId,
) async {
  final apiService = ref.watch(krishiApiServiceProvider);
  return await apiService.getProduct(productId);
});

// Product detail page providers
// Note: isInCartProvider is kept for backward compatibility but should use isProductInCartProvider from cart_providers
final isInCartProvider = StateProvider.autoDispose.family<bool, int>((ref, productId) => false);
final isAddingToCartProvider = StateProvider.autoDispose.family<bool, int>((ref, productId) => false);
final isFetchingSellerListingsProvider = StateProvider.autoDispose<bool>((ref) => false);
final isSubmittingCommentProvider = StateProvider.autoDispose<bool>((ref) => false);
final feedbackTabIndexProvider = StateProvider.autoDispose<int>((ref) => 0);
final reviewRatingProvider = StateProvider.autoDispose<int>((ref) => 5);

// Add/Edit product page providers
final isSavingProductProvider = StateProvider.autoDispose<bool>((ref) => false);
final isAvailableProvider = StateProvider.autoDispose<bool>((ref) => true);
final selectedCategoryProvider = StateProvider.autoDispose<Category?>((ref) => null);
final selectedUnitProvider = StateProvider.autoDispose<Unit?>((ref) => null);
final selectedImageProvider = StateProvider.autoDispose<File?>((ref) => null);

// Marketplace page providers
final isMarketplaceBuyTabProvider = StateProvider<bool>((ref) => true);
final buyProductsProvider = StateProvider<List<Product>>((ref) => []);
final userListingsProvider = StateProvider<List<Product>>((ref) => []);
final isLoadingBuyProductsProvider = StateProvider<bool>((ref) => true);
final isLoadingUserListingsProvider = StateProvider<bool>((ref) => true);
final selectedCategoryIdProvider = StateProvider<int?>((ref) => null);
final sellStatusFilterProvider = StateProvider<String>((ref) => 'all');
final buyCurrentPageProvider = StateProvider<int>((ref) => 1);
final buyHasMoreProvider = StateProvider<bool>((ref) => true);
final isLoadingMoreBuyProductsProvider = StateProvider<bool>((ref) => false);
final sellCurrentPageProvider = StateProvider<int>((ref) => 1);
final sellHasMoreProvider = StateProvider<bool>((ref) => true);
final isLoadingMoreUserListingsProvider = StateProvider<bool>((ref) => false);
