class ApiConstants {
  // Network IP for your API server (accessible from any device on the network)
  static const String networkBaseUrl = 'http://192.168.1.181:8082';

  // Dynamic base URL based on platform
  static String get baseUrl {
    return networkBaseUrl; // Use network IP for all platforms
  }

  // Legacy localhost URLs (kept for reference)
  static const String localhostBaseUrl = 'http://127.0.0.1:8082';
  static const String androidEmulatorBaseUrl =
      'http://10.0.2.2:8082'; // Auth endpoints
  static const String login = '/api/v1/auth/login/';
  static const String register = '/api/v1/auth/register/';
  static const String logout = '/api/v1/auth/logout/';
  static const String refreshToken = '/api/v1/auth/token/refresh/';
  static const String changePassword = '/api/v1/auth/password/change/';

  // User endpoints
  static const String profile = '/api/v1/auth/profile/';
  static const String updateProfile = '/api/v1/auth/profile/';
  static const String addresses = '/api/v1/auth/addresses/';

  // Artwork endpoints (note: renamed from products to artworks)
  static const String artworks = '/api/v1/catalog/artworks/';
  static const String artworkDetails = '/api/v1/catalog/artworks'; // {slug}/
  static const String createArtwork = '/api/v1/catalog/artworks/create/';
  static const String updateArtwork =
      '/api/v1/catalog/artworks'; // {id}/update/
  static const String featuredArtworks = '/api/v1/catalog/artworks/featured/';
  static const String trendingArtworks = '/api/v1/catalog/artworks/trending/';
  static const String searchArtworks = '/api/v1/catalog/artworks/search/';
  static const String artworkFilters = '/api/v1/catalog/artworks/filters/';
  static const String likedArtworks = '/api/v1/catalog/artworks/liked/';
  static const String likeArtwork = '/api/v1/catalog/artworks'; // {id}/like/
  static const String categories = '/api/v1/catalog/categories/';
  static const String collections = '/api/v1/catalog/collections/';
  static const String filterOptions = '/api/v1/catalog/filter-options/';
  static const String stats = '/api/v1/catalog/stats/';

  // Cart endpoints
  static const String cart = '/api/v1/catalog/cart/';
  static const String addToCart = '/api/v1/catalog/cart/items/';
  static const String updateCartItem = '/api/v1/catalog/cart/items/';
  static const String removeFromCart = '/api/v1/catalog/cart/items/';
  static const String clearCart = '/api/v1/catalog/cart/';

  // Review endpoints
  static const String reviews = '/api/v1/reviews/api/';
  static const String reviewDetail = '/api/v1/reviews/api/'; // {id}/
  static const String createReview =
      '/api/v1/reviews/api/artwork/'; // {artwork_id}/create/
  static const String updateReview = '/api/v1/reviews/api/'; // {id}/update/
  static const String deleteReview = '/api/v1/reviews/api/'; // {id}/delete/
  static const String moderateReview = '/api/v1/reviews/api/'; // {id}/moderate/
  static const String reviewHelpfulness =
      '/api/v1/reviews/api/'; // {review_id}/helpfulness/
  static const String reportReview =
      '/api/v1/reviews/api/'; // {review_id}/report/
  static const String respondToReview =
      '/api/v1/reviews/api/'; // {review_id}/respond/
  static const String reviewStats =
      '/api/v1/reviews/api/artwork/'; // {artwork_id}/stats/
  static const String userReviews = '/api/v1/reviews/api/user/'; // [user_id]/
  static const String pendingReviews = '/api/v1/reviews/api/admin/pending/';
  static const String reportedReviews = '/api/v1/reviews/api/admin/reported/';

  // Order endpoints (for future implementation)
  static const String orders = '/api/v1/orders/';
  static const String orderDetails = '/api/v1/orders';
  static const String createOrder = '/api/v1/orders/create/';
  static const String cancelOrder = '/api/v1/orders';
  static const String orderHistory = '/api/v1/orders/history/';

  // Checkout endpoints
  static const String getShippingMethods = '/api/v1/shipping/methods/';
  static const String calculateShippingCost = '/api/v1/shipping/calculate/';
  static const String getPaymentMethods = '/api/v1/payments/methods/';
  static const String initializePayment = '/api/v1/payments/initialize/';
  static const String processMobilePayment = '/api/v1/payments/process-mobile/';
  static const String checkPaymentStatus = '/api/v1/payments';
  static const String getOrderDetails = '/api/v1/orders';
  static const String getUserOrders = '/api/v1/orders/';
}

class ApiHeaders {
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String accept = 'Accept';
  static const String userAgent = 'User-Agent';
  static const String deviceId = 'X-Device-ID';
  static const String appVersion = 'X-App-Version';
}

class ApiStatus {
  static const int success = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int internalServerError = 500;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
  static const int gatewayTimeout = 504;
}
