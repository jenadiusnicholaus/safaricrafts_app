import 'package:get/get.dart' hide Response;
import '../models/category_model.dart';
import '../../core/constants/api_constants.dart';
import '../services/api_service.dart';

class CategoryProvider {
  final ApiService _apiService = Get.find<ApiService>();

  /// Get all active categories
  Future<PaginatedCategoryList> getCategories({
    int? limit,
    int? offset,
    bool includeArtworkCount = false,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (includeArtworkCount) queryParams['include_artwork_count'] = true;

      final response = await _apiService.get(
        ApiConstants.categories,
        queryParameters: queryParams,
      );

      return PaginatedCategoryList.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Get category with artwork count
  Future<Category> getCategoryWithCount(int categoryId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.categories}$categoryId/?include_artwork_count=true',
      );

      return Category.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }

  /// Create a new category (admin only)
  Future<Category> createCategory(CategoryRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConstants.categories,
        data: request.toJson(),
      );

      return Category.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Get all collections
  Future<PaginatedCollectionList> getCollections({
    bool? featured,
    int? limit,
    int? offset,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (featured != null) queryParams['featured'] = featured;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get(
        ApiConstants.collections,
        queryParameters: queryParams,
      );

      return PaginatedCollectionList.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch collections: $e');
    }
  }

  /// Get a specific collection by slug
  Future<Collection> getCollection(String slug) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.collections}$slug/',
      );

      return Collection.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch collection: $e');
    }
  }

  /// Get filter options for artworks
  Future<Map<String, dynamic>> getFilterOptions() async {
    try {
      final response = await _apiService.get(
        ApiConstants.filterOptions,
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch filter options: $e');
    }
  }

  /// Get artwork statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiService.get(
        ApiConstants.stats,
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch statistics: $e');
    }
  }
}
