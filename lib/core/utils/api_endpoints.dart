final class ApiEndpoints {
  // Authentication
  static const String googleLogin = "auth/google/";
  static const String googleCallback = "auth/google/callback/";
  static const String googleMobile = "auth/google/mobile/";
  static const String googleAccessToken = "auth/google/access-token/";
  static const String me = "auth/me/";
  static const String updateProfile = "auth/me/update/";
  static const String uploadAvatar = "auth/me/avatar/";

  // Weather
  static const String currentWeather = "weather/current/";

  // Knowledge (Krishi Gyan)
  static const String articles = "knowledge/articles/";
  static String articleDetail(int id) => "knowledge/articles/$id/";

  // News
  static const String news = "news/";
  static String newsDetail(int id) => "news/$id/";

  // Marketplace - Fixed to match API documentation
  static const String categories = "categories/";
  static const String units = "units/";
  static const String products = "products/";
  static String productDetail(int id) => "products/$id/";

  // Comments
  static String productComments(int productId) =>
      "products/$productId/comments/";

  // Reviews
  static String productReviews(int productId) => "products/$productId/reviews/";

  // Cart
  static const String cart = "cart/";
  static const String addToCart = "cart/add/";
  static String cartItem(int itemId) => "cart/items/$itemId/";
  static const String checkout = "cart/checkout/";

  // Orders
  static const String orders = "orders/";
  static String orderDetail(int id) => "orders/$id/";
  static String completeOrder(int id) => "orders/$id/complete/";
}
