import 'package:dio/dio.dart';
import 'package:krishi/core/services/api_services/api_services.dart';
import 'package:krishi/core/utils/api_endpoints.dart';
import 'package:krishi/models/article.dart';
import 'package:krishi/models/cart.dart';
import 'package:krishi/models/category.dart';
import 'package:krishi/models/comment.dart';
import 'package:krishi/models/order.dart';
import 'package:krishi/models/paginated_response.dart';
import 'package:krishi/models/product.dart';
import 'package:krishi/models/review.dart';
import 'package:krishi/models/unit.dart';
import 'package:krishi/models/user_profile.dart';
import 'package:krishi/models/weather.dart';

class KrishiApiService {
  final ApiManager apiManager;

  KrishiApiService(this.apiManager);

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
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;

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
    required int category,
    required String price,
    required String description,
    required int unit,

    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'seller_phone_number': sellerPhoneNumber,
        'category': category,
        'price': price,
        'description': description,
        'unit': unit,
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
    int? category,
    String? price,
    String? description,
    int? unit,
    String? imagePath,
  }) async {
    try {
      final formData = FormData();
      if (name != null) formData.fields.add(MapEntry('name', name));
      if (sellerPhoneNumber != null) {
        formData.fields.add(MapEntry('seller_phone_number', sellerPhoneNumber));
      }
      if (category != null) {
        formData.fields.add(MapEntry('category', category.toString()));
      }
      if (price != null) formData.fields.add(MapEntry('price', price));
      if (description != null) {
        formData.fields.add(MapEntry('description', description));
      }
      if (unit != null) formData.fields.add(MapEntry('unit', unit.toString()));

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
  Future<CartItem> updateCartItem({
    required int itemId,
    required int quantity,
  }) async {
    try {
      final response = await apiManager.patch(
        ApiEndpoints.cartItem(itemId),
        data: {'quantity': quantity},
      );
      return CartItem.fromJson(response.data as Map<String, dynamic>);
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

  /// Get my purchases (orders where user is the buyer)
  Future<List<Order>> getMyPurchases() async {
    try {
      final response = await apiManager.get(ApiEndpoints.myPurchases);
      return (response.data as List<dynamic>)
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get my sales (orders where user is the seller)
  Future<List<Order>> getMySales() async {
    try {
      final response = await apiManager.get(ApiEndpoints.mySales);
      return (response.data as List<dynamic>)
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
