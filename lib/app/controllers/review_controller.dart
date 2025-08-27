import 'package:get/get.dart';
import '../data/models/review_model.dart';
import '../data/providers/review_provider.dart';

class ReviewController extends GetxController {
  final ReviewProvider _reviewProvider = ReviewProvider();

  // Observable state variables
  var isLoading = false.obs;
  var reviews = <ReviewList>[].obs;
  var currentReview = Rxn<ReviewDetail>();
  var reviewStats = Rxn<ReviewStats>();
  var userReviews = <ReviewList>[].obs;
  var pendingReviews = <ReviewList>[].obs;
  var reportedReviews = <ReviewList>[].obs;

  // Pagination
  var currentPage = 1.obs;
  var hasMoreReviews = true.obs;
  var totalReviews = 0.obs;

  // Filters
  var selectedRating = Rxn<int>();
  var selectedOrdering = ReviewOrdering.createdAtDesc.obs;
  var showVerifiedOnly = false.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with default reviews
    loadReviews();
  }

  /// Load reviews with current filters
  Future<void> loadReviews({
    int? artworkId,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        hasMoreReviews.value = true;
        reviews.clear();
      }

      if (!hasMoreReviews.value && !refresh) return;

      isLoading.value = true;

      final result = await _reviewProvider.getReviews(
        artworkId: artworkId,
        rating: selectedRating.value,
        isVerifiedPurchase: showVerifiedOnly.value ? true : null,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        ordering: selectedOrdering.value,
        limit: 20,
        offset: refresh ? 0 : (currentPage.value - 1) * 20,
      );

      totalReviews.value = result.count;

      if (refresh) {
        reviews.value = result.results;
      } else {
        reviews.addAll(result.results);
      }

      hasMoreReviews.value = result.next != null;
      if (!refresh) currentPage.value++;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load reviews: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more reviews for pagination
  Future<void> loadMoreReviews({int? artworkId}) async {
    if (!isLoading.value && hasMoreReviews.value) {
      await loadReviews(artworkId: artworkId);
    }
  }

  /// Get detailed review information
  Future<void> getReviewDetail(int reviewId) async {
    try {
      isLoading.value = true;
      final review = await _reviewProvider.getReviewDetail(reviewId);
      currentReview.value = review;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load review details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a new review
  Future<bool> createReview({
    required int artworkId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  }) async {
    try {
      isLoading.value = true;

      final request = ReviewCreateRequest(
        rating: rating,
        title: title,
        comment: comment,
        images: images,
      );

      final review = await _reviewProvider.createReview(artworkId, request);

      // Add to local reviews list
      reviews.insert(
          0,
          ReviewList(
            id: review.id,
            user: review.user,
            rating: review.rating,
            title: review.title,
            comment: review.comment,
            isVerifiedPurchase: review.isVerifiedPurchase,
            helpfulCount: review.helpfulCount,
            notHelpfulCount: review.notHelpfulCount,
            helpfulnessScore: review.helpfulnessScore,
            userVote: review.userVote,
            responseCount: review.responseCount,
            createdAt: review.createdAt,
            updatedAt: review.updatedAt,
          ));

      totalReviews.value++;

      Get.snackbar(
        'Success',
        'Review created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create review: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an existing review
  Future<bool> updateReview({
    required int reviewId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  }) async {
    try {
      isLoading.value = true;

      final request = ReviewUpdateRequest(
        rating: rating,
        title: title,
        comment: comment,
        images: images,
      );

      final updatedReview =
          await _reviewProvider.updateReview(reviewId, request);

      // Update in local reviews list
      final index = reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        reviews[index] = ReviewList(
          id: updatedReview.id,
          user: updatedReview.user,
          rating: updatedReview.rating,
          title: updatedReview.title,
          comment: updatedReview.comment,
          isVerifiedPurchase: updatedReview.isVerifiedPurchase,
          helpfulCount: updatedReview.helpfulCount,
          notHelpfulCount: updatedReview.notHelpfulCount,
          helpfulnessScore: updatedReview.helpfulnessScore,
          userVote: updatedReview.userVote,
          responseCount: updatedReview.responseCount,
          createdAt: updatedReview.createdAt,
          updatedAt: updatedReview.updatedAt,
        );
      }

      currentReview.value = updatedReview;

      Get.snackbar(
        'Success',
        'Review updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update review: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a review
  Future<bool> deleteReview(int reviewId) async {
    try {
      isLoading.value = true;

      await _reviewProvider.deleteReview(reviewId);

      // Remove from local reviews list
      reviews.removeWhere((r) => r.id == reviewId);
      totalReviews.value--;

      if (currentReview.value?.id == reviewId) {
        currentReview.value = null;
      }

      Get.snackbar(
        'Success',
        'Review deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete review: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Vote on review helpfulness
  Future<void> voteHelpfulness(int reviewId, String vote) async {
    try {
      final request = ReviewHelpfulnessRequest(vote: vote);
      await _reviewProvider.voteReviewHelpfulness(reviewId, request);

      // Update local review data
      _updateReviewHelpfulness(reviewId, vote);

      Get.snackbar(
        'Success',
        'Vote recorded successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to vote: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Remove helpfulness vote
  Future<void> removeHelpfulnessVote(int reviewId) async {
    try {
      await _reviewProvider.removeHelpfulnessVote(reviewId);

      // Update local review data
      _updateReviewHelpfulness(reviewId, null);

      Get.snackbar(
        'Success',
        'Vote removed successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove vote: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Report a review
  Future<bool> reportReview({
    required int reviewId,
    required String reason,
    String? description,
  }) async {
    try {
      isLoading.value = true;

      final request = ReviewReportRequest(
        reason: reason,
        description: description,
      );

      await _reviewProvider.reportReview(reviewId, request);

      Get.snackbar(
        'Success',
        'Review reported successfully. Thank you for helping us maintain quality.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to report review: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Respond to a review
  Future<bool> respondToReview({
    required int reviewId,
    required String responseText,
  }) async {
    try {
      isLoading.value = true;

      final request = ReviewResponseRequest(responseText: responseText);
      final response = await _reviewProvider.respondToReview(reviewId, request);

      // Update current review if it's loaded
      if (currentReview.value?.id == reviewId) {
        final updatedResponses =
            List<ReviewResponse>.from(currentReview.value!.responses);
        updatedResponses.add(response);

        currentReview.value = ReviewDetail(
          id: currentReview.value!.id,
          user: currentReview.value!.user,
          rating: currentReview.value!.rating,
          title: currentReview.value!.title,
          comment: currentReview.value!.comment,
          isVerifiedPurchase: currentReview.value!.isVerifiedPurchase,
          helpfulCount: currentReview.value!.helpfulCount,
          notHelpfulCount: currentReview.value!.notHelpfulCount,
          helpfulnessScore: currentReview.value!.helpfulnessScore,
          userVote: currentReview.value!.userVote,
          responseCount: currentReview.value!.responseCount + 1,
          createdAt: currentReview.value!.createdAt,
          updatedAt: currentReview.value!.updatedAt,
          responses: updatedResponses,
          artworkTitle: currentReview.value!.artworkTitle,
          images: currentReview.value!.images,
        );
      }

      Get.snackbar(
        'Success',
        'Response added successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to respond to review: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get review statistics for an artwork
  Future<void> getArtworkReviewStats(int artworkId) async {
    try {
      final stats = await _reviewProvider.getArtworkReviewStats(artworkId);
      reviewStats.value = stats;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load review statistics: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Load user's own reviews
  Future<void> loadUserReviews() async {
    try {
      isLoading.value = true;
      final result = await _reviewProvider.getUserReviews();
      userReviews.value = result.results;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load your reviews: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ADMIN METHODS

  /// Load pending reviews for moderation (Admin only)
  Future<void> loadPendingReviews() async {
    try {
      isLoading.value = true;
      final result = await _reviewProvider.getPendingReviews();
      pendingReviews.value = result.results;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load pending reviews: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load reported reviews for moderation (Admin only)
  Future<void> loadReportedReviews() async {
    try {
      isLoading.value = true;
      final result = await _reviewProvider.getReportedReviews();
      reportedReviews.value = result.results;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load reported reviews: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Moderate a review (Admin only)
  Future<bool> moderateReview({
    required int reviewId,
    bool? isApproved,
    bool? isFeatured,
    String? moderationNotes,
  }) async {
    try {
      isLoading.value = true;

      final request = ReviewModerationRequest(
        isApproved: isApproved,
        isFeatured: isFeatured,
        moderationNotes: moderationNotes,
      );

      await _reviewProvider.moderateReview(reviewId, request);

      // Remove from pending/reported lists if approved/rejected
      if (isApproved != null) {
        pendingReviews.removeWhere((r) => r.id == reviewId);
        if (!isApproved) {
          reportedReviews.removeWhere((r) => r.id == reviewId);
        }
      }

      Get.snackbar(
        'Success',
        'Review moderated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to moderate review: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // FILTER METHODS

  /// Set rating filter
  void setRatingFilter(int? rating) {
    selectedRating.value = rating;
    loadReviews(refresh: true);
  }

  /// Set ordering
  void setOrdering(String ordering) {
    selectedOrdering.value = ordering;
    loadReviews(refresh: true);
  }

  /// Toggle verified purchase filter
  void toggleVerifiedFilter() {
    showVerifiedOnly.value = !showVerifiedOnly.value;
    loadReviews(refresh: true);
  }

  /// Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
    loadReviews(refresh: true);
  }

  /// Clear all filters
  void clearFilters() {
    selectedRating.value = null;
    selectedOrdering.value = ReviewOrdering.createdAtDesc;
    showVerifiedOnly.value = false;
    searchQuery.value = '';
    loadReviews(refresh: true);
  }

  // HELPER METHODS

  /// Update review helpfulness locally
  void _updateReviewHelpfulness(int reviewId, String? vote) {
    // Update in reviews list
    final reviewIndex = reviews.indexWhere((r) => r.id == reviewId);
    if (reviewIndex != -1) {
      final review = reviews[reviewIndex];
      final oldVote = review.userVote;

      int newHelpfulCount = review.helpfulCount;
      int newNotHelpfulCount = review.notHelpfulCount;

      // Remove old vote effect
      if (oldVote == ReviewVote.helpful) {
        newHelpfulCount--;
      } else if (oldVote == ReviewVote.notHelpful) {
        newNotHelpfulCount--;
      }

      // Add new vote effect
      if (vote == ReviewVote.helpful) {
        newHelpfulCount++;
      } else if (vote == ReviewVote.notHelpful) {
        newNotHelpfulCount++;
      }

      // Calculate new helpfulness score
      final total = newHelpfulCount + newNotHelpfulCount;
      final newScore = total > 0 ? (newHelpfulCount / total) : 0.0;

      reviews[reviewIndex] = ReviewList(
        id: review.id,
        user: review.user,
        rating: review.rating,
        title: review.title,
        comment: review.comment,
        isVerifiedPurchase: review.isVerifiedPurchase,
        helpfulCount: newHelpfulCount,
        notHelpfulCount: newNotHelpfulCount,
        helpfulnessScore: newScore,
        userVote: vote,
        responseCount: review.responseCount,
        createdAt: review.createdAt,
        updatedAt: review.updatedAt,
      );
    }

    // Update current review if it matches
    if (currentReview.value?.id == reviewId) {
      final review = currentReview.value!;
      final oldVote = review.userVote;

      int newHelpfulCount = review.helpfulCount;
      int newNotHelpfulCount = review.notHelpfulCount;

      // Remove old vote effect
      if (oldVote == ReviewVote.helpful) {
        newHelpfulCount--;
      } else if (oldVote == ReviewVote.notHelpful) {
        newNotHelpfulCount--;
      }

      // Add new vote effect
      if (vote == ReviewVote.helpful) {
        newHelpfulCount++;
      } else if (vote == ReviewVote.notHelpful) {
        newNotHelpfulCount++;
      }

      // Calculate new helpfulness score
      final total = newHelpfulCount + newNotHelpfulCount;
      final newScore = total > 0 ? (newHelpfulCount / total) : 0.0;

      currentReview.value = ReviewDetail(
        id: review.id,
        user: review.user,
        rating: review.rating,
        title: review.title,
        comment: review.comment,
        isVerifiedPurchase: review.isVerifiedPurchase,
        helpfulCount: newHelpfulCount,
        notHelpfulCount: newNotHelpfulCount,
        helpfulnessScore: newScore,
        userVote: vote,
        responseCount: review.responseCount,
        createdAt: review.createdAt,
        updatedAt: review.updatedAt,
        responses: review.responses,
        artworkTitle: review.artworkTitle,
        images: review.images,
      );
    }
  }
}
