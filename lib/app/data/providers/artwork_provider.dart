import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart' as dio;
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class ArtworkProvider {
  final ApiService _apiService = Get.find<ApiService>();

  // Get artworks with filtering and pagination
  Future<dio.Response> getArtworks({
    int? offset,
    int limit = 20,
    String? category,
    String? collection,
    String? tribe,
    String? region,
    String? material,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    bool? isFeatured,
    bool? isUnique,
    bool includeImages = true, // NEW: Include main_image data
  }) async {
    Map<String, dynamic> queryParams = {
      'limit': limit.toString(),
    };

    if (offset != null) queryParams['offset'] = offset.toString();
    if (category != null) queryParams['category'] = category;
    if (collection != null) queryParams['collection'] = collection;
    if (tribe != null) queryParams['tribe'] = tribe;
    if (region != null) queryParams['region'] = region;
    if (material != null) queryParams['material'] = material;
    if (search != null) queryParams['search'] = search;
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
    if (sortBy != null) queryParams['sort_by'] = sortBy;
    if (sortOrder != null) queryParams['sort_order'] = sortOrder;
    if (isFeatured != null) queryParams['is_featured'] = isFeatured.toString();
    if (isUnique != null) queryParams['is_unique'] = isUnique.toString();

    // Remove the forced featured=true as it might be limiting results
    // Instead, let's see if we can find the right parameter for images
    if (includeImages) {
      // Try common patterns for including related data
      queryParams['include'] = 'main_image';
      queryParams['with_images'] = 'true';
    }

    print('🌍 API Request - Endpoint: ${ApiConstants.artworks}');
    print('🌍 API Request - Query params: $queryParams');

    final response = await _apiService.get(
      ApiConstants.artworks,
      queryParameters: queryParams,
    );

    print('🌍 API Response - Status: ${response.statusCode}');
    print('🌍 API Response - Data type: ${response.data.runtimeType}');
    if (response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      print('🌍 API Response - Keys: ${data.keys.toList()}');
      if (data.containsKey('results') && data['results'] is List) {
        final results = data['results'] as List;
        print('🌍 API Response - Results count: ${results.length}');
        if (results.isNotEmpty) {
          print('🌍 API Response - First item: ${results.first}');
        }
      }
    }

    return response;
  }

  // Get single artwork by ID or slug
  Future<dio.Response> getArtwork(String idOrSlug) async {
    return await _apiService.get('${ApiConstants.artworks}$idOrSlug/');
  }

  // Get featured artworks
  Future<dio.Response> getFeaturedArtworks({
    int limit = 10,
  }) async {
    return await _apiService.get(
      ApiConstants.artworks,
      queryParameters: {
        'limit': limit.toString(),
        'is_featured': 'true',
        'sort_by': 'created_at',
        'sort_order': 'desc',
        // Add the same image inclusion parameters
        'with_images': 'true',
        'include_images': 'true',
        'include': 'main_image',
        'expand': 'main_image',
      },
    );
  }

  // Get trending artworks
  Future<dio.Response> getTrendingArtworks({
    int limit = 10,
  }) async {
    return await _apiService.get(
      ApiConstants.artworks,
      queryParameters: {
        'limit': limit.toString(),
        'sort_by': 'views', // or 'popularity' if available
        'sort_order': 'desc',
      },
    );
  }

  // Get related artworks
  Future<dio.Response> getRelatedArtworks(
    String artworkId, {
    int limit = 5,
  }) async {
    return await _apiService.get(
      '${ApiConstants.artworks}$artworkId/related/',
      queryParameters: {'limit': limit.toString()},
    );
  }

  // Search artworks
  Future<dio.Response> searchArtworks(
    String query, {
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    Map<String, dynamic> queryParams = {
      'q': query,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (filters != null) {
      queryParams.addAll(filters);
    }

    return await _apiService.get(
      ApiConstants.searchArtworks,
      queryParameters: queryParams,
    );
  }

  // Get categories with pagination
  Future<dio.Response> getCategories({
    int? offset,
    int limit = 20,
  }) async {
    Map<String, dynamic> queryParams = {
      'limit': limit.toString(),
    };

    if (offset != null) queryParams['offset'] = offset.toString();

    print('🏷️ API Request - Categories Endpoint: ${ApiConstants.categories}');
    print('🏷️ API Request - Query params: $queryParams');

    final response = await _apiService.get(
      ApiConstants.categories,
      queryParameters: queryParams,
    );

    print('🏷️ API Response - Status: ${response.statusCode}');
    print('🏷️ API Response - Data type: ${response.data.runtimeType}');
    if (response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      print('🏷️ API Response - Keys: ${data.keys.toList()}');
      if (data.containsKey('results') && data['results'] is List) {
        final results = data['results'] as List;
        print('🏷️ API Response - Categories count: ${results.length}');
        if (results.isNotEmpty) {
          print('🏷️ API Response - First category: ${results.first}');
        }
      }
    }

    return response;
  }

  // Get filter options for artworks
  Future<dio.Response> getFilterOptions() async {
    print(
        '🔍 API Request - Filter Options Endpoint: ${ApiConstants.baseUrl}/catalog/filter-options/');

    final response = await _apiService.get('/catalog/filter-options/');

    print('🔍 API Response - Status: ${response.statusCode}');
    print('🔍 API Response - Data type: ${response.data.runtimeType}');
    if (response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      print('🔍 API Response - Available filters: ${data.keys.toList()}');

      // Log each filter category
      data.forEach((key, value) {
        if (value is List) {
          print('🔍 Filter "$key": ${value.length} options');
          if (value.isNotEmpty) {
            print('🔍 "$key" sample: ${value.take(3).toList()}');
          }
        }
      });
    }

    return response;
  }

  // Get collections
  Future<dio.Response> getCollections({
    int page = 1,
    int limit = 20,
    bool? isFeatured,
  }) async {
    Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (isFeatured != null) {
      queryParams['is_featured'] = isFeatured.toString();
    }

    return await _apiService.get(
      ApiConstants.collections,
      queryParameters: queryParams,
    );
  }

  // Get single collection
  Future<dio.Response> getCollection(String idOrSlug) async {
    return await _apiService.get('${ApiConstants.collections}$idOrSlug/');
  }

  // Get artworks in collection
  Future<dio.Response> getCollectionArtworks(
    String collectionId, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _apiService.get(
      '${ApiConstants.collections}$collectionId/artworks/',
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
  }

  // Get filters data (tribes, regions, materials, etc.)
  Future<dio.Response> getFilters() async {
    return await _apiService.get(ApiConstants.artworkFilters);
  }

  // Track artwork view
  Future<dio.Response> trackView(String artworkId) async {
    return await _apiService.post('${ApiConstants.artworks}$artworkId/view/');
  }

  // Toggle artwork like/unlike
  Future<dio.Response> toggleLike(String artworkId) async {
    return await _apiService.post('${ApiConstants.artworks}$artworkId/like/');
  }

  // Get user's liked artworks
  Future<dio.Response> getLikedArtworks({
    int page = 1,
    int limit = 20,
  }) async {
    return await _apiService.get(
      ApiConstants.likedArtworks,
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
  }
}
