final class ApiEndpoints {
  // Authentication
  static const String googleLogin = "auth/google/";
  static const String googleCallback = "auth/google/callback/";
  static const String googleMobile = "auth/google/mobile/";
  static const String googleAccessToken = "auth/google/access-token/";
  static const String me = "auth/me/";
  static const String updateProfile = "auth/me/update/";
  static const String uploadAvatar = "auth/me/avatar/";
  static String userProfile(int userId) => "auth/users/$userId/";

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
  static String acceptOrder(int id) => "orders/$id/accept/";
  static String cancelOrder(int id) => "orders/$id/cancel/";
  static String deliverOrder(int id) => "orders/$id/deliver/";
  static String markOrderInTransit(int id) => "orders/$id/mark_in_transit/";
  static const String myPurchases = "orders/my_purchases/";
  static const String mySales = "orders/my_sales/";
  static const String purchasesSummary = "orders/purchases_summary/";
  static const String salesSummary = "orders/sales_summary/";

  // Resources endpoints
  static const String notices = "resources/notices/";
  static String noticeDetail(int id) => "resources/notices/$id/";
  static const String videos = "resources/videos/";
  static String videoDetail(int id) => "resources/videos/$id/";
  static const String cropCalendar = "resources/crop-calendar/";
  static String cropDetail(int id) => "resources/crop-calendar/$id/";
  static const String experts = "resources/experts/";
  static String expertDetail(int id) => "resources/experts/$id/";
  static const String serviceProviders = "resources/service-providers/";
  static String serviceProviderDetail(int id) => "resources/service-providers/$id/";
  static const String contacts = "resources/contacts/";
  static String contactDetail(int id) => "resources/contacts/$id/";
  static const String faqs = "resources/faqs/";
  static String faqDetail(int id) => "resources/faqs/$id/";
  static const String userManuals = "resources/user-manuals/";
  static String userManualDetail(int id) => "resources/user-manuals/$id/";
  static const String programs = "resources/programs/";
  static String programDetail(int id) => "resources/programs/$id/";
  static const String marketPrices = "resources/market-prices/";
  static String marketPriceDetail(int id) => "resources/market-prices/$id/";
  static const String soilTests = "resources/soil-tests/";
  static String soilTestDetail(int id) => "resources/soil-tests/$id/";
  static String orderUpdateContactDetails(int id) =>
      "orders/$id/update_contact_details/";

  // Notifications
  static const String notifications = "notifications/";
  static String notificationDetail(int id) => "notifications/$id/";
  static const String notificationsUnread = "notifications/unread/";
  static const String notificationsUnreadCount = "notifications/unread_count/";
  static const String notificationsMarkAllAsRead =
      "notifications/mark_all_as_read/";
  static const String notificationsDeleteAllRead =
      "notifications/delete_all_read/";
  static String notificationMarkAsRead(int id) =>
      "notifications/$id/mark_as_read/";
  static String notificationDelete(int id) =>
      "notifications/$id/delete_notification/";
}
