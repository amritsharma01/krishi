import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:krishi/core/services/api_services/api_services.dart';
import 'package:krishi/core/utils/api_endpoints.dart';
import 'package:krishi/models/app_notification.dart';
import 'package:krishi/models/article.dart';
import 'package:krishi/models/cart.dart';
import 'package:krishi/models/category.dart';
import 'package:krishi/models/comment.dart';
import 'package:krishi/models/order.dart';
import 'package:krishi/models/order_summary.dart';
import 'package:krishi/models/paginated_response.dart';
import 'package:krishi/models/product.dart';
import 'package:krishi/models/resources.dart';
import 'package:krishi/models/review.dart';
import 'package:krishi/models/unit.dart';
import 'package:krishi/models/user_profile.dart';
import 'package:krishi/models/weather.dart';

class KrishiApiService {
  final ApiManager apiManager;

  KrishiApiService(this.apiManager);

  List<T> _parseListResponse<T>(
    dynamic data,
    T Function(Map<String, dynamic>) mapper,
  ) {
    if (data == null) {
      return <T>[];
    }
    if (data is String && data.trim().isEmpty) {
      return <T>[];
    }
    if (data is List) {
      return data.map((json) => mapper(json as Map<String, dynamic>)).toList();
    }
    if (data is Map<String, dynamic>) {
      final results = data['results'];
      if (results is List) {
        return results
            .map((json) => mapper(json as Map<String, dynamic>))
            .toList();
      }
      final count = data['count'];
      if (results == null && count is int && count == 0) {
        return <T>[];
      }
      if (data.isEmpty) {
        return <T>[];
      }
    }
    throw const FormatException('Unexpected list response format');
  }

  PaginatedResponse<T> _parsePaginatedResponse<T>(
    dynamic data,
    T Function(Map<String, dynamic>) mapper,
  ) {
    if (data == null ||
        (data is String && data.trim().isEmpty) ||
        (data is Map<String, dynamic> && data.isEmpty)) {
      return PaginatedResponse(
        count: 0,
        next: null,
        previous: null,
        results: <T>[],
      );
    }
    if (data is Map<String, dynamic>) {
      if (data.containsKey('results')) {
        final results = data['results'];
        if (results is List) {
          return PaginatedResponse.fromJson(data, mapper);
        }
        final count = data['count'];
        final hasNoResults =
            results == null ||
            (results is List && results.isEmpty) ||
            (results is String && results.trim().isEmpty);
        if (count is int && count == 0 && hasNoResults) {
          return PaginatedResponse(
            count: 0,
            next: data['next'] as String?,
            previous: data['previous'] as String?,
            results: <T>[],
          );
        }
      }
    }
    if (data is List) {
      final results = data
          .map((json) => mapper(json as Map<String, dynamic>))
          .toList();
      return PaginatedResponse(
        count: results.length,
        next: null,
        previous: null,
        results: results,
      );
    }
    throw const FormatException('Unexpected paginated response format');
  }

  // ==================== Authentication ====================

  /// Authenticate with Google (Mobile)
  /// Sends the Google id_token in the request body
  /// Backend responds with a token that should be used for subsequent requests
  Future<Map<String, dynamic>> authenticateWithGoogleMobile(
    String idToken,
  ) async {
    try {
      // Send Google id_token in request body
      // This is a public endpoint that doesn't require authentication
      final response = await apiManager.post(
        ApiEndpoints.googleMobile,
        data: {'id_token': idToken},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final response = await apiManager.get(ApiEndpoints.me);
      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get public user profile by user ID
  Future<User> getUserProfile(int userId) async {
    try {
      final response = await apiManager.get(ApiEndpoints.userProfile(userId));
      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get public seller profile via KR user id
  Future<UserPublicProfile> getSellerPublicProfile(String krUserId) async {
    try {
      final response = await apiManager.get(
        ApiEndpoints.userProfilePublic(krUserId),
      );
      return UserPublicProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  Future<User> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (address != null) data['address'] = address;

      final response = await apiManager.patch(
        ApiEndpoints.updateProfile,
        data: data,
      );
      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload avatar
  Future<User> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'profile_image': await MultipartFile.fromFile(filePath),
      });

      final response = await apiManager.post(
        ApiEndpoints.uploadAvatar,
        data: formData,
      );
      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Weather ====================

  /// Get current weather
  Future<Weather> getCurrentWeather() async {
    try {
      final response = await apiManager.get(ApiEndpoints.currentWeather);
      return Weather.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Knowledge (Articles) ====================

  /// Get paginated list of articles
  Future<PaginatedResponse<Article>> getArticles({
    int page = 1,
    String? language,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (language != null) queryParams['language'] = language;

      final response = await apiManager.get(
        ApiEndpoints.articles,
        queryParameters: queryParams,
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => Article.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get single article
  Future<Article> getArticle(int id) async {
    try {
      final response = await apiManager.get(ApiEndpoints.articleDetail(id));
      return Article.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== News ====================

  /// Get paginated list of news
  Future<PaginatedResponse<Article>> getNews({
    int page = 1,
    String? language,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (language != null) queryParams['language'] = language;

      final response = await apiManager.get(
        ApiEndpoints.news,
        queryParameters: queryParams,
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => Article.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Marketplace ====================

  /// Get all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await apiManager.get(ApiEndpoints.categories);
      // API returns array directly according to documentation
      if (response.data is List) {
        return (response.data as List<dynamic>)
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Fallback for paginated response
        final data = response.data as Map<String, dynamic>;
        return (data['results'] as List<dynamic>)
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get all units
  Future<List<Unit>> getUnits() async {
    try {
      final response = await apiManager.get(ApiEndpoints.units);
      // API returns array directly according to documentation
      if (response.data is List) {
        return (response.data as List<dynamic>)
            .map((json) => Unit.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Fallback for paginated response
        final data = response.data as Map<String, dynamic>;
        return (data['results'] as List<dynamic>)
            .map((json) => Unit.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get paginated list of products
  Future<PaginatedResponse<Product>> getProducts({
    int page = 1,
    int? category,
    String? categoryName,
    String? search,
    String? sellerId,
    String? sellerEmail,
    String? minPrice,
    String? maxPrice,
    String? approvalStatus,
    String? ordering,
    bool? isAvailable,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (category != null) queryParams['category'] = category;
      final trimmedCategoryName = categoryName?.trim();
      if (trimmedCategoryName != null && trimmedCategoryName.isNotEmpty) {
        queryParams['category_name'] = trimmedCategoryName;
      }
      final trimmedSearch = search?.trim();
      if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
        queryParams['search'] = trimmedSearch;
      }
      final trimmedSellerId = sellerId?.trim();
      if (trimmedSellerId != null && trimmedSellerId.isNotEmpty) {
        queryParams['seller_id'] = trimmedSellerId;
      }
      if (sellerEmail != null && sellerEmail.trim().isNotEmpty) {
        queryParams['seller_email'] = sellerEmail.trim();
      }
      if (minPrice != null && minPrice.trim().isNotEmpty) {
        queryParams['min_price'] = minPrice.trim();
      }
      if (maxPrice != null && maxPrice.trim().isNotEmpty) {
        queryParams['max_price'] = maxPrice.trim();
      }
      if (approvalStatus != null && approvalStatus.trim().isNotEmpty) {
        queryParams['approval_status'] = approvalStatus.trim();
      }
      if (ordering != null && ordering.trim().isNotEmpty) {
        queryParams['ordering'] = ordering.trim();
      }
      if (isAvailable != null) {
        queryParams['is_available'] = isAvailable;
      }

      final response = await apiManager.get(
        ApiEndpoints.products,
        queryParameters: queryParams,
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => Product.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get single product
  Future<Product> getProduct(int id) async {
    try {
      final response = await apiManager.get(ApiEndpoints.productDetail(id));
      return Product.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new product
  Future<Product> createProduct({
    required String name,
    required String sellerPhoneNumber,
    required String sellerAddress,
    required int category,
    required String basePrice,
    required String description,
    required int unit,
    bool isAvailable = true,
    String? imagePath,
  }) async {
    try {
      final payload = {
        'name': name,
        'seller_phone_number': sellerPhoneNumber,
        'address': sellerAddress,
        'category': category,
        'base_price': basePrice,
        'description': description,
        'unit': unit,
        'is_available': isAvailable,
      };

      if (kDebugMode) {
        print(
          '🆕 Create Product Payload: $payload'
          ' ${imagePath != null ? '(includes image)' : ''}',
        );
      }

      final formData = FormData.fromMap({
        ...payload,
        if (imagePath != null) 'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await apiManager.post(
        ApiEndpoints.products,
        data: formData,
      );

      // Debug: Print the response to see what we're getting
      print('📦 Create Product Response: ${response.data}');

      return Product.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Error parsing product response: $e');
      rethrow;
    }
  }

  /// Update a product
  Future<Product> updateProduct({
    required int id,
    String? name,
    String? sellerPhoneNumber,
    String? sellerAddress,
    int? category,
    String? basePrice,
    String? description,
    int? unit,
    bool? isAvailable,
    String? imagePath,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (sellerPhoneNumber != null) {
        data['seller_phone_number'] = sellerPhoneNumber;
      }
      if (sellerAddress != null) {
        data['address'] = sellerAddress;
      }
      if (category != null) data['category'] = category;
      if (basePrice != null) data['base_price'] = basePrice;
      if (description != null) data['description'] = description;
      if (unit != null) data['unit'] = unit;
      if (isAvailable != null) data['is_available'] = isAvailable;

      if (kDebugMode) {
        print(
          '📝 Update Product Payload: $data'
          ' ${imagePath != null ? '(includes new image)' : ''}',
        );
      }
      final formData = FormData.fromMap(data);
      if (imagePath != null) {
        formData.files.add(
          MapEntry('image', await MultipartFile.fromFile(imagePath)),
        );
      }

      final response = await apiManager.patch(
        ApiEndpoints.productDetail(id),
        data: formData,
      );
      return Product.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a product
  Future<void> deleteProduct(int id) async {
    try {
      await apiManager.delete(ApiEndpoints.productDetail(id));
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Comments ====================

  /// Get comments for a product
  Future<List<Comment>> getProductComments(int productId) async {
    try {
      final response = await apiManager.get(
        ApiEndpoints.productComments(productId),
      );
      return (response.data as List<dynamic>)
          .map((json) => Comment.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Add comment to a product
  Future<Comment> addComment(int productId, String text) async {
    try {
      final response = await apiManager.post(
        ApiEndpoints.productComments(productId),
        data: {'text': text},
      );
      return Comment.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Reviews ====================

  /// Get reviews for a product
  Future<List<Review>> getProductReviews(int productId) async {
    try {
      final response = await apiManager.get(
        ApiEndpoints.productReviews(productId),
      );
      return (response.data as List<dynamic>)
          .map((json) => Review.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Add review to a product
  Future<Review> addReview({
    required int productId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await apiManager.post(
        ApiEndpoints.productReviews(productId),
        data: {'rating': rating, 'comment': comment},
      );
      return Review.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Cart ====================

  /// Get user's cart
  Future<Cart> getCart() async {
    try {
      final response = await apiManager.get(ApiEndpoints.cart);
      return Cart.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Add item to cart
  Future<Cart> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      final response = await apiManager.post(
        ApiEndpoints.addToCart,
        data: {'product_id': productId, 'quantity': quantity},
      );
      return Cart.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Update cart item quantity
  Future<void> updateCartItem({
    required int itemId,
    required int quantity,
  }) async {
    try {
      await apiManager.patch(
        ApiEndpoints.cartItem(itemId),
        data: {'quantity': quantity},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Remove item from cart
  Future<void> removeCartItem(int itemId) async {
    try {
      await apiManager.delete(ApiEndpoints.cartItem(itemId));
    } catch (e) {
      rethrow;
    }
  }

  /// Clear all items from cart
  Future<void> clearCart() async {
    try {
      final cart = await getCart();
      // Remove all items
      for (final item in cart.items) {
        await removeCartItem(item.id);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Checkout
  Future<Map<String, dynamic>> checkout({
    required String buyerName,
    required String buyerAddress,
    required String buyerPhoneNumber,
  }) async {
    try {
      final response = await apiManager.post(
        ApiEndpoints.checkout,
        data: {
          'buyer_name': buyerName,
          'buyer_address': buyerAddress,
          'buyer_phone_number': buyerPhoneNumber,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Orders ====================

  /// Get paginated list of orders
  Future<PaginatedResponse<Order>> getOrders({int page = 1}) async {
    try {
      final response = await apiManager.get(
        ApiEndpoints.orders,
        queryParameters: {'page': page},
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => Order.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get single order
  Future<Order> getOrder(int id) async {
    try {
      final response = await apiManager.get(ApiEndpoints.orderDetail(id));
      return Order.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Complete an order (buyer only)
  Future<Order> completeOrder(int id) async {
    try {
      final response = await apiManager.post(ApiEndpoints.completeOrder(id));
      return Order.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Order> updateOrderContactDetails({
    required int orderId,
    required String buyerName,
    required String buyerAddress,
    required String buyerPhoneNumber,
  }) async {
    try {
      final response = await apiManager.patch(
        ApiEndpoints.orderUpdateContactDetails(orderId),
        data: {
          'buyer_name': buyerName,
          'buyer_address': buyerAddress,
          'buyer_phone_number': buyerPhoneNumber,
        },
      );
      return Order.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get my purchases (orders where user is the buyer)
  Future<PaginatedResponse<Order>> getMyPurchasesPaginated({
    int page = 1,
  }) async {
    try {
      final response = await apiManager.get(
        ApiEndpoints.myPurchases,
        queryParameters: {'page': page},
      );
      
      // Check if response is a list or paginated object
      List<dynamic> results;
      int? count;
      String? next;
      String? previous;
      
      if (response.data is List) {
        // Direct list response
        results = response.data as List<dynamic>;
        count = results.length;
        next = null;
        previous = null;
      } else {
        // Paginated response
        final data = response.data as Map<String, dynamic>;
        results = data['results'] as List<dynamic>? ?? [];
        count = data['count'] as int?;
        next = data['next'] as String?;
        previous = data['previous'] as String?;
      }
      
      // Parse orders directly from response (list API already includes all needed data)
      // The simplified response has: id, created_at, total_price, items_count, status
      // Order.fromJson can handle missing fields with defaults
      final orders = results.map((item) {
        final orderData = item as Map<String, dynamic>;
        // Ensure updated_at exists (use created_at if not present)
        if (!orderData.containsKey('updated_at') && orderData.containsKey('created_at')) {
          orderData['updated_at'] = orderData['created_at'];
        }
        // Map items_count to items array if items are not present
        if (!orderData.containsKey('items') && orderData.containsKey('items_count')) {
          orderData['items'] = [];
        }
        return Order.fromJson(orderData);
      }).toList();
      
      return PaginatedResponse(
        count: count ?? orders.length,
        next: next,
        previous: previous,
        results: orders,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get my purchases (orders where user is the buyer)
  Future<List<Order>> getMyPurchases() async {
    final response = await getMyPurchasesPaginated(page: 1);
    return response.results;
  }

  /// Get my sales (order items where user is the seller) with pagination support
  Future<PaginatedResponse<OrderItemSeller>> getMySalesPaginated({int page = 1}) async {
    try {
      final response = await apiManager.get(
        ApiEndpoints.mySales,
        queryParameters: {'page': page},
      );
      
      // Check if response is a list or paginated object
      List<dynamic> results;
      int? count;
      String? next;
      String? previous;
      
      if (response.data is List) {
        // Direct list response
        results = response.data as List<dynamic>;
        count = results.length;
        next = null;
        previous = null;
      } else {
        // Paginated response
        final data = response.data as Map<String, dynamic>;
        results = data['results'] as List<dynamic>? ?? [];
        count = data['count'] as int?;
        next = data['next'] as String?;
        previous = data['previous'] as String?;
      }
      
      // Parse order items directly from response
      final orderItems = results
          .map((item) => OrderItemSeller.fromJson(item as Map<String, dynamic>))
          .toList();
      
      return PaginatedResponse(
        count: count ?? orderItems.length,
        next: next,
        previous: previous,
        results: orderItems,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get my sales (order items where user is the seller)
  Future<List<OrderItemSeller>> getMySales() async {
    final response = await getMySalesPaginated(page: 1);
    return response.results;
  }

  /// Get order item details (for seller)
  Future<OrderItemSeller> getOrderItemDetail(int itemId) async {
    try {
      final response = await apiManager.get(ApiEndpoints.orderItemDetail(itemId));
      return OrderItemSeller.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Start delivery for an order (seller only - marks as IN_TRANSIT)
  Future<Order> startDelivery(int id) async {
    try {
      final response = await apiManager.post(ApiEndpoints.startDelivery(id));
      return Order.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel an order (buyer or seller)
  Future<Order> cancelOrder(int id) async {
    try {
      final response = await apiManager.post(ApiEndpoints.cancelOrder(id));
      return Order.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Mark order as delivered (seller only)
  Future<Order> deliverOrder(int id) async {
    try {
      final response = await apiManager.post(ApiEndpoints.deliverOrder(id));
      return Order.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get buyer's purchases summary
  Future<PurchasesSummary> getPurchasesSummary() async {
    try {
      final response = await apiManager.get(ApiEndpoints.purchasesSummary);
      return PurchasesSummary.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get seller's sales summary by category
  Future<SalesSummary> getSalesSummary() async {
    try {
      final response = await apiManager.get(ApiEndpoints.salesSummary);
      return SalesSummary.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get counts of sales and purchases without fetching full lists
  Future<OrdersCounts> getOrdersCounts() async {
    try {
      final response = await apiManager.get(ApiEndpoints.ordersCounts);
      return OrdersCounts.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Resources ====================

  /// Get all notices
  Future<List<Notice>> getNotices({String? noticeType}) async {
    try {
      final queryParams = noticeType != null
          ? {'notice_type': noticeType}
          : null;
      final response = await apiManager.get(
        ApiEndpoints.notices,
        queryParameters: queryParams,
      );
      return _parseListResponse(response.data, Notice.fromJson);
    } catch (e) {
      rethrow;
    }
  }

  /// Get single notice
  Future<Notice> getNoticeDetail(int id) async {
    try {
      final response = await apiManager.get(ApiEndpoints.noticeDetail(id));
      return Notice.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all videos
  Future<List<Video>> getVideos({String? category}) async {
    try {
      final queryParams = category != null ? {'category': category} : null;
      final response = await apiManager.get(
        ApiEndpoints.videos,
        queryParameters: queryParams,
      );
      return _parseListResponse(response.data, Video.fromJson);
    } catch (e) {
      rethrow;
    }
  }

  /// Get single video
  Future<Video> getVideoDetail(int id) async {
    try {
      final response = await apiManager.get(ApiEndpoints.videoDetail(id));
      return Video.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get crop calendar
  Future<List<CropCalendar>> getCropCalendar({String? cropType}) async {
    try {
      final queryParams = cropType != null ? {'crop_type': cropType} : null;
      final response = await apiManager.get(
        ApiEndpoints.cropCalendar,
        queryParameters: queryParams,
      );
      return _parseListResponse(response.data, CropCalendar.fromJson);
    } catch (e) {
      rethrow;
    }
  }

  /// Get single crop detail
  Future<CropCalendar> getCropDetail(int id) async {
    try {
      final response = await apiManager.get(ApiEndpoints.cropDetail(id));
      return CropCalendar.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all experts
  Future<List<Expert>> getExperts() async {
    try {
      final response = await apiManager.get(ApiEndpoints.experts);
      return _parseListResponse(response.data, Expert.fromJson);
    } catch (e) {
      rethrow;
    }
  }

  /// Get single expert
  Future<Expert> getExpertDetail(int id) async {
    try {
      final response = await apiManager.get(ApiEndpoints.expertDetail(id));
      return Expert.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all service providers
  Future<List<ServiceProvider>> getServiceProviders({
    String? serviceType,
  }) async {
    try {
      final queryParams = serviceType != null
          ? {'service_type': serviceType}
          : null;
      final response = await apiManager.get(
        ApiEndpoints.serviceProviders,
        queryParameters: queryParams,
      );
      return _parseListResponse(response.data, ServiceProvider.fromJson);
    } catch (e) {
      rethrow;
    }
  }

  /// Get single service provider
  Future<ServiceProvider> getServiceProviderDetail(int id) async {
    try {
      final response = await apiManager.get(
        ApiEndpoints.serviceProviderDetail(id),
      );
      return ServiceProvider.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all contacts
  Future<List<Contact>> getContacts({String? contactType}) async {
    try {
      final queryParams = contactType != null
          ? {'contact_type': contactType}
          : null;
      final response = await apiManager.get(
        ApiEndpoints.contacts,
        queryParameters: queryParams,
      );
      return _parseListResponse(response.data, Contact.fromJson);
    } catch (e) {
      rethrow;
    }
  }

  /// Get single contact
  Future<Contact> getContactDetail(int id) async {
    try {
      final response = await apiManager.get(ApiEndpoints.contactDetail(id));
      return Contact.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all FAQs
  Future<List<FAQ>> getFAQs() async {
    try {
      final response = await apiManager.get(ApiEndpoints.faqs);
      return _parseListResponse(response.data, FAQ.fromJson);
    } catch (e) {
      rethrow;
    }
  }

  /// Get single FAQ
  Future<FAQ> getFAQDetail(int id) async {
    try {
      final response = await apiManager.get(ApiEndpoints.faqDetail(id));
      return FAQ.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== User Manuals ====================

  /// Get list of user manuals
  Future<List<UserManual>> getUserManuals({
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;

      final response = await apiManager.get(
        ApiEndpoints.userManuals,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return _parseListResponse(response.data, UserManual.fromJson);
    } catch (e) {
      rethrow;
    }
  }

  /// Get single user manual
  Future<UserManual> getUserManual(int id) async {
    try {
      final response = await apiManager.get(ApiEndpoints.userManualDetail(id));
      return UserManual.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Programs ====================

  Future<PaginatedResponse<Program>> getPrograms({
    int page = 1,
    String? search,
    String? ordering,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      final trimmedSearch = search?.trim();
      final trimmedOrdering = ordering?.trim();
      if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
        queryParams['search'] = trimmedSearch;
      }
      if (trimmedOrdering != null && trimmedOrdering.isNotEmpty) {
        queryParams['ordering'] = trimmedOrdering;
      }

      final response = await apiManager.get(
        ApiEndpoints.programs,
        queryParameters: queryParams,
      );
      return _parsePaginatedResponse(response.data, Program.fromJson);
    } catch (e) {
      rethrow;
    }
  }

  Future<Program> getProgram(int id) async {
    try {
      final response = await apiManager.get(ApiEndpoints.programDetail(id));
      return Program.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Market Prices ====================

  Future<PaginatedResponse<MarketPrice>> getMarketPrices({
    int page = 1,
    String? category,
    String? search,
    String? ordering,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      final trimmedSearch = search?.trim();
      final trimmedOrdering = ordering?.trim();
      final trimmedCategory = category?.trim();

      if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
        queryParams['search'] = trimmedSearch;
      }
      if (trimmedOrdering != null && trimmedOrdering.isNotEmpty) {
        queryParams['ordering'] = trimmedOrdering;
      }
      if (trimmedCategory != null &&
          trimmedCategory.isNotEmpty &&
          trimmedCategory != 'all') {
        queryParams['category'] = trimmedCategory;
      }

      final response = await apiManager.get(
        ApiEndpoints.marketPrices,
        queryParameters: queryParams,
      );
      return _parsePaginatedResponse(response.data, MarketPrice.fromJson);
    } catch (e) {
      rethrow;
    }
  }

  Future<MarketPrice> getMarketPrice(int id) async {
    try {
      final response = await apiManager.get(ApiEndpoints.marketPriceDetail(id));
      return MarketPrice.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Soil Tests ====================

  Future<PaginatedResponse<SoilTest>> getSoilTests({
    int page = 1,
    String? search,
    String? ordering,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      final trimmedSearch = search?.trim();
      final trimmedOrdering = ordering?.trim();
      if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
        queryParams['search'] = trimmedSearch;
      }
      if (trimmedOrdering != null && trimmedOrdering.isNotEmpty) {
        queryParams['ordering'] = trimmedOrdering;
      }
      final response = await apiManager.get(
        ApiEndpoints.soilTests,
        queryParameters: queryParams,
      );
      return _parsePaginatedResponse(response.data, SoilTest.fromJson);
    } catch (e) {
      rethrow;
    }
  }

  Future<SoilTest> getSoilTest(int id) async {
    try {
      final response = await apiManager.get(ApiEndpoints.soilTestDetail(id));
      return SoilTest.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Notifications ====================

  Future<PaginatedResponse<AppNotification>> getNotifications({
    int page = 1,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await apiManager.get(
        unreadOnly
            ? ApiEndpoints.notificationsUnread
            : ApiEndpoints.notifications,
        queryParameters: {'page': page},
      );
      return _parsePaginatedResponse(
        response.data,
        (json) => AppNotification.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<AppNotification> getNotification(int id) async {
    try {
      final response = await apiManager.get(
        ApiEndpoints.notificationDetail(id),
      );
      return AppNotification.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadNotificationsCount() async {
    try {
      final response = await apiManager.get(
        ApiEndpoints.notificationsUnreadCount,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['count'] is int) return data['count'] as int;
        if (data['unread_count'] is int) return data['unread_count'] as int;
        if (data['results'] is List) {
          return (data['results'] as List).length;
        }
      }
      if (data is int) return data;
      return 0;
    } catch (e) {
      rethrow;
    }
  }

  Future<AppNotification> markNotificationAsRead(int id) async {
    try {
      final response = await apiManager.post(
        ApiEndpoints.notificationMarkAsRead(id),
        data: {'is_read': true},
      );
      return AppNotification.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await apiManager.post(
        ApiEndpoints.notificationsMarkAllAsRead,
        data: {'is_read': true},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await apiManager.delete(ApiEndpoints.notificationDelete(id));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllReadNotifications() async {
    try {
      await apiManager.delete(ApiEndpoints.notificationsDeleteAllRead);
    } catch (e) {
      rethrow;
    }
  }
}
