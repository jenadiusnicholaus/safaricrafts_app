import 'package:get/get.dart' hide Response;
import '../models/artwork_model.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class ProductProvider {
  final ApiService _apiService = Get.find<ApiService>();

  // Get Products (now uses artwork endpoints)
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': (page - 1) * limit,
      };

      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;
      if (minPrice != null) queryParams['price_min'] = minPrice;
      if (maxPrice != null) queryParams['price_max'] = maxPrice;
      if (sortBy != null && sortOrder != null) {
        queryParams['ordering'] = sortOrder == 'desc' ? '-$sortBy' : sortBy;
      }

      final response = await _apiService.get(
        ApiConstants.artworks,
        queryParameters: queryParams,
      );

      final data = response.data;
      final artworks = (data['results'] as List)
          .map((json) => ArtworkList.fromJson(json))
          .toList();

      return {
        'products':
            artworks, // Keeping 'products' key for backward compatibility
        'total': data['count'],
        'page': page,
        'limit': limit,
        'next': data['next'],
        'previous': data['previous'],
      };
    } catch (e) {
      throw Exception('Failed to get products: ${e.toString()}');
    }
  }

  // Get Product Details (now uses artwork detail endpoint)
  Future<ArtworkDetail> getProductDetails(String productSlug) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.artworkDetails}/$productSlug/',
      );
      return ArtworkDetail.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get product details: ${e.toString()}');
    }
  }

  // Search Products (now uses artwork search)
  Future<List<ArtworkList>> searchProducts(String query) async {
    try {
      final response = await _apiService.get(
        ApiConstants.artworks,
        queryParameters: {'search': query},
      );
      final data = response.data['results'] as List;
      return data.map((json) => ArtworkList.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search products: ${e.toString()}');
    }
  }

  // Get Featured Products
  Future<List<ArtworkList>> getFeaturedProducts() async {
    try {
      final response = await _apiService.get(
        ApiConstants.artworks,
        queryParameters: {'featured': true},
      );
      final data = response.data['results'] as List;
      return data.map((json) => ArtworkList.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get featured products: ${e.toString()}');
    }
  }

  // Get Popular Products (using view_count ordering)
  Future<List<ArtworkList>> getPopularProducts() async {
    try {
      final response = await _apiService.get(
        ApiConstants.artworks,
        queryParameters: {'ordering': '-view_count'},
      );
      final data = response.data['results'] as List;
      return data.map((json) => ArtworkList.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get popular products: ${e.toString()}');
    }
  }

  // Get Product Reviews (uses review endpoints)
  Future<Map<String, dynamic>> getProductReviews(
    String productId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.reviews,
        queryParameters: {
          'artwork': productId,
          'limit': limit,
          'offset': (page - 1) * limit,
        },
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to get product reviews: ${e.toString()}');
    }
  }

  // Add Product Review (uses review endpoints)
  Future<void> addProductReview(
    String productId,
    int rating,
    String review,
  ) async {
    try {
      await _apiService.post(
        '${ApiConstants.createReview}$productId/create/',
        data: {
          'rating': rating,
          'comment': review,
        },
      );
    } catch (e) {
      throw Exception('Failed to add product review: ${e.toString()}');
    }
  }

  // Get Products by Category
  Future<List<ArtworkList>> getProductsByCategory(
    String categorySlug, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.artworks,
        queryParameters: {
          'category': categorySlug,
          'limit': limit,
          'offset': (page - 1) * limit,
        },
      );

      final data = response.data['results'] as List;
      return data.map((json) => ArtworkList.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get products by category: ${e.toString()}');
    }
  }

  // Get Related Products (based on category and material)
  Future<List<ArtworkList>> getRelatedProducts(String productSlug) async {
    try {
      // First get the product details to find related criteria
      final productDetail = await getProductDetails(productSlug);

      // Then search for related products by category and material
      final response = await _apiService.get(
        ApiConstants.artworks,
        queryParameters: {
          'category': productDetail.category.slug,
          'material': productDetail.material,
          'limit': 10,
        },
      );

      final data = response.data['results'] as List;
      final relatedProducts = data
          .map((json) => ArtworkList.fromJson(json))
          .where((artwork) =>
              artwork.slug != productDetail.slug) // Exclude current product
          .toList();

      return relatedProducts;
    } catch (e) {
      throw Exception('Failed to get related products: ${e.toString()}');
    }
  }
}
