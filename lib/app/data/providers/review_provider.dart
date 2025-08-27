import 'package:get/get.dart' hide Response;
import '../models/review_model.dart';
import '../../core/constants/api_constants.dart';
import '../services/api_service.dart';

class ReviewProvider {
  final ApiService _apiService = Get.find<ApiService>();

  /// Get paginated list of approved reviews with optional filtering
  Future<PaginatedReviewList> getReviews({
    int? artworkId,
    bool? isVerifiedPurchase,
    int? rating,
    String? search,
    String? ordering,
    int? limit,
    int? offset,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (artworkId != null) queryParams['artwork'] = artworkId;
      if (isVerifiedPurchase != null)
        queryParams['is_verified_purchase'] = isVerifiedPurchase;
      if (rating != null) queryParams['rating'] = rating;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (ordering != null) queryParams['ordering'] = ordering;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get(
        ApiConstants.reviews,
        queryParameters: queryParams,
      );

      return PaginatedReviewList.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  /// Get detailed information about a specific review
  Future<ReviewDetail> getReviewDetail(int reviewId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.reviewDetail}$reviewId/',
      );

      return ReviewDetail.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch review detail: $e');
    }
  }

  /// Create a new review for an artwork
  Future<ReviewDetail> createReview(
    int artworkId,
    ReviewCreateRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.createReview}$artworkId/create/',
        data: request.toJson(),
      );

      return ReviewDetail.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  /// Update your own review
  Future<ReviewDetail> updateReview(
    int reviewId,
    ReviewUpdateRequest request,
  ) async {
    try {
      final response = await _apiService.patch(
        '${ApiConstants.updateReview}$reviewId/update/',
        data: request.toJson(),
      );

      return ReviewDetail.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  /// Get your own review for editing
  Future<ReviewDetail> getReviewForUpdate(int reviewId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.updateReview}$reviewId/update/',
      );

      return ReviewDetail.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch review for update: $e');
    }
  }

  /// Delete your own review
  Future<void> deleteReview(int reviewId) async {
    try {
      await _apiService.delete(
        '${ApiConstants.deleteReview}$reviewId/delete/',
      );
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  /// Vote on review helpfulness
  Future<void> voteReviewHelpfulness(
    int reviewId,
    ReviewHelpfulnessRequest request,
  ) async {
    try {
      await _apiService.post(
        '${ApiConstants.reviewHelpfulness}$reviewId/helpfulness/',
        data: request.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to vote on review helpfulness: $e');
    }
  }

  /// Remove your vote on review helpfulness
  Future<void> removeHelpfulnessVote(int reviewId) async {
    try {
      await _apiService.delete(
        '${ApiConstants.reviewHelpfulness}$reviewId/helpfulness/',
      );
    } catch (e) {
      throw Exception('Failed to remove helpfulness vote: $e');
    }
  }

  /// Report a review for inappropriate content
  Future<ReviewReport> reportReview(
    int reviewId,
    ReviewReportRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.reportReview}$reviewId/report/',
        data: request.toJson(),
      );

      return ReviewReport.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to report review: $e');
    }
  }

  /// Respond to a review
  Future<ReviewResponse> respondToReview(
    int reviewId,
    ReviewResponseRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.respondToReview}$reviewId/respond/',
        data: request.toJson(),
      );

      return ReviewResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to respond to review: $e');
    }
  }

  /// Get comprehensive review statistics for a specific artwork
  Future<ReviewStats> getArtworkReviewStats(int artworkId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.reviewStats}$artworkId/stats/',
      );

      return ReviewStats.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch review statistics: $e');
    }
  }

  /// Get reviews by current user
  Future<PaginatedReviewList> getUserReviews({
    int? limit,
    int? offset,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get(
        ApiConstants.userReviews,
        queryParameters: queryParams,
      );

      return PaginatedReviewList.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch user reviews: $e');
    }
  }

  /// Get reviews by a specific user
  Future<PaginatedReviewList> getUserReviewsById(
    int userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get(
        '${ApiConstants.userReviews}$userId/',
        queryParameters: queryParams,
      );

      return PaginatedReviewList.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch user reviews: $e');
    }
  }

  // ADMIN ONLY METHODS

  /// Get all reviews pending moderation (Admin only)
  Future<PaginatedReviewList> getPendingReviews({
    int? limit,
    int? offset,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get(
        ApiConstants.pendingReviews,
        queryParameters: queryParams,
      );

      return PaginatedReviewList.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch pending reviews: $e');
    }
  }

  /// Get all reviews that have been reported (Admin only)
  Future<PaginatedReviewList> getReportedReviews({
    int? limit,
    int? offset,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get(
        ApiConstants.reportedReviews,
        queryParameters: queryParams,
      );

      return PaginatedReviewList.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch reported reviews: $e');
    }
  }

  /// Moderate a review - approve, reject, or feature (Admin only)
  Future<void> moderateReview(
    int reviewId,
    ReviewModerationRequest request,
  ) async {
    try {
      await _apiService.patch(
        '${ApiConstants.moderateReview}$reviewId/moderate/',
        data: request.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to moderate review: $e');
    }
  }
}
