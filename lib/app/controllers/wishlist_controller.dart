import 'package:get/get.dart';
import '../data/models/wishlist_model.dart';
import '../data/providers/wishlist_provider.dart';

class WishlistController extends GetxController {
  final WishlistProvider _wishlistProvider = Get.find<WishlistProvider>();

  // Reactive variables
  final RxList<LikedArtwork> likedArtworks = <LikedArtwork>[].obs;
  final RxSet<String> likedArtworkIds = <String>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isToggling = false.obs;
  final RxString error = ''.obs;
  final RxInt currentPage = 0.obs;
  final RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadLikedArtworks();
  }

  // Load liked artworks
  Future<void> loadLikedArtworks({bool reset = true}) async {
    try {
      if (reset) {
        likedArtworks.clear();
        likedArtworkIds.clear();
        currentPage.value = 0;
        hasMore.value = true;
      }

      if (!hasMore.value) return;

      isLoading.value = true;
      error.value = '';

      final result = await _wishlistProvider.getLikedArtworks(
        limit: 20,
        offset: currentPage.value * 20,
      );

      if (reset) {
        likedArtworks.value = result.results;
      } else {
        likedArtworks.addAll(result.results);
      }

      // Update liked artwork IDs for quick lookup
      for (final liked in result.results) {
        likedArtworkIds.add(liked.artwork.id);
      }

      hasMore.value = result.next != null;
      currentPage.value++;

      print('✅ Loaded ${result.results.length} liked artworks');
    } catch (e) {
      error.value = e.toString();
      print('❌ Error loading liked artworks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle like status of an artwork
  Future<void> toggleLike(String artworkId) async {
    try {
      isToggling.value = true;
      error.value = '';

      final response = await _wishlistProvider.toggleLike(artworkId);

      if (response.liked) {
        likedArtworkIds.add(artworkId);
        Get.snackbar(
          'Added to Wishlist',
          'Artwork added to your favorites',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        likedArtworkIds.remove(artworkId);
        // Remove from liked artworks list
        likedArtworks.removeWhere((liked) => liked.artwork.id == artworkId);
        Get.snackbar(
          'Removed from Wishlist',
          'Artwork removed from your favorites',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      print('✅ Toggled like for artwork $artworkId: ${response.liked}');
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update wishlist',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('❌ Error toggling like: $e');
    } finally {
      isToggling.value = false;
    }
  }

  // Like an artwork
  Future<void> likeArtwork(String artworkId) async {
    try {
      error.value = '';

      final response = await _wishlistProvider.likeArtwork(artworkId);
      likedArtworkIds.add(artworkId);

      Get.snackbar(
        'Added to Wishlist',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
      );

      print('✅ Liked artwork: $artworkId');
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to add to wishlist',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('❌ Error liking artwork: $e');
    }
  }

  // Unlike an artwork
  Future<void> unlikeArtwork(String artworkId) async {
    try {
      error.value = '';

      final response = await _wishlistProvider.unlikeArtwork(artworkId);
      likedArtworkIds.remove(artworkId);

      // Remove from liked artworks list
      likedArtworks.removeWhere((liked) => liked.artwork.id == artworkId);

      Get.snackbar(
        'Removed from Wishlist',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
      );

      print('✅ Unliked artwork: $artworkId');
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to remove from wishlist',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('❌ Error unliking artwork: $e');
    }
  }

  // Check if artwork is liked
  bool isLiked(String artworkId) {
    return likedArtworkIds.contains(artworkId);
  }

  // Get total liked artworks count
  int get totalLiked => likedArtworks.length;

  // Check if wishlist is empty
  bool get isEmpty => likedArtworks.isEmpty;

  // Load more liked artworks (pagination)
  Future<void> loadMore() async {
    if (!isLoading.value && hasMore.value) {
      await loadLikedArtworks(reset: false);
    }
  }

  // Refresh liked artworks
  Future<void> refresh() async {
    await loadLikedArtworks(reset: true);
  }

  // Clear all liked artworks (local only - doesn't affect server)
  void clearLocal() {
    likedArtworks.clear();
    likedArtworkIds.clear();
    currentPage.value = 0;
    hasMore.value = true;
  }

  // Preload liked status for multiple artworks
  Future<void> preloadLikedStatus(List<String> artworkIds) async {
    try {
      for (final artworkId in artworkIds) {
        if (!likedArtworkIds.contains(artworkId)) {
          final isLiked = await _wishlistProvider.isArtworkLiked(artworkId);
          if (isLiked) {
            likedArtworkIds.add(artworkId);
          }
        }
      }
    } catch (e) {
      print('❌ Error preloading liked status: $e');
    }
  }
}
