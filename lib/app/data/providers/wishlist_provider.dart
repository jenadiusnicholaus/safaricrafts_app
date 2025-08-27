import 'package:get/get.dart' hide Response;
import '../models/wishlist_model.dart';
import '../../core/constants/api_constants.dart';
import '../services/api_service.dart';

class WishlistProvider {
  final ApiService _apiService = Get.find<ApiService>();

  /// Get user's liked artworks
  Future<PaginatedLikedArtworkList> getLikedArtworks({
    int? limit,
    int? offset,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get(
        ApiConstants.likedArtworks,
        queryParameters: queryParams,
      );

      return PaginatedLikedArtworkList.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch liked artworks: $e');
    }
  }

  /// Like an artwork
  Future<LikeResponse> likeArtwork(String artworkId) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.artworkDetails}/$artworkId/like/',
      );

      return LikeResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to like artwork: $e');
    }
  }

  /// Unlike an artwork
  Future<LikeResponse> unlikeArtwork(String artworkId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.artworkDetails}/$artworkId/like/',
      );

      return LikeResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to unlike artwork: $e');
    }
  }

  /// Check if artwork is liked
  Future<bool> isArtworkLiked(String artworkId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.artworkDetails}/$artworkId/like/status/',
      );

      return response.data['liked'] ?? false;
    } catch (e) {
      // If endpoint doesn't exist, fall back to checking liked artworks list
      try {
        final likedArtworks = await getLikedArtworks(limit: 1000);
        return likedArtworks.results
            .any((liked) => liked.artwork.id == artworkId);
      } catch (e2) {
        throw Exception('Failed to check if artwork is liked: $e');
      }
    }
  }

  /// Toggle like status of an artwork
  Future<LikeResponse> toggleLike(String artworkId) async {
    try {
      final isLiked = await isArtworkLiked(artworkId);

      if (isLiked) {
        return await unlikeArtwork(artworkId);
      } else {
        return await likeArtwork(artworkId);
      }
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }
}
