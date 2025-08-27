import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../data/models/artwork_model.dart';
import '../data/providers/artwork_provider.dart';

enum ArtworkDisplayType { grid, list }

class ArtworkController extends GetxController {
  final ArtworkProvider _artworkProvider = Get.find<ArtworkProvider>();

  // PagingController for infinite scroll pagination
  late final PagingController<int, ArtworkList> pagingController =
      PagingController<int, ArtworkList>(
    getNextPageKey: (state) {
      print('🔄 getNextPageKey called');
      print('🔄 state.lastPageIsEmpty: ${state.lastPageIsEmpty}');
      print('🔄 state.items.length: ${state.items?.length ?? 0}');

      // If this is the last page (no more items), return null
      if (state.lastPageIsEmpty) {
        print('🔄 Last page is empty, returning null');
        return null;
      }

      // Calculate next offset based on current items count
      final itemCount = state.items?.length ?? 0;
      print('🔄 Next offset will be: $itemCount');
      return itemCount;
    },
    fetchPage: (offset) => _fetchPage(offset),
  ); // Reactive variables
  final RxList<ArtworkList> featuredArtworks = <ArtworkList>[].obs;
  final RxList<ArtworkList> trendingArtworks = <ArtworkList>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<Collection> collections = <Collection>[].obs;
  final Rx<ArtworkDetail?> selectedArtwork = Rx<ArtworkDetail?>(null);

  // Like status tracking for optimistic updates
  final RxMap<String, bool> likeStatuses = <String, bool>{}.obs;
  final RxMap<String, int> likeCounts = <String, int>{}.obs;

  // Filter options from API
  final Rx<Map<String, dynamic>> filterOptions = Rx<Map<String, dynamic>>({});

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Pagination settings
  static const int pageSize = 20;

  @override
  void onInit() {
    super.onInit();

    // Load initial data (excluding artworks which are handled by pagination)
    loadInitialData();
  }

  @override
  void onClose() {
    pagingController.dispose();
    super.onClose();
  }

  // Filters
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedCollection = ''.obs;
  final RxString selectedTribe = ''.obs;
  final RxString selectedRegion = ''.obs;
  final RxString selectedMaterial = ''.obs;
  final Rx<double?> minPrice = Rx<double?>(null);
  final Rx<double?> maxPrice = Rx<double?>(null);
  final RxString sortBy = 'created_at'.obs;
  final RxString sortOrder = 'desc'.obs;
  final RxBool showFeaturedOnly = false.obs;
  final RxBool showUniqueOnly = false.obs;

  // Display preferences
  final Rx<ArtworkDisplayType> displayType = ArtworkDisplayType.grid.obs;

  Future<void> loadInitialData() async {
    await Future.wait([
      fetchCategories(),
      fetchFilterOptions(),
      fetchFeaturedArtworks(),
      fetchTrendingArtworks(),
    ]);
    // The pagination controller will handle artwork loading
  }

  // Method for infinite scroll pagination
  Future<List<ArtworkList>> _fetchPage(int offset) async {
    try {
      print('🎨 Starting fetchPage with offset: $offset');
      print('🎨 Using pageSize: $pageSize');

      final response = await _artworkProvider.getArtworks(
        offset: offset,
        limit: pageSize,
        category:
            selectedCategory.value.isEmpty ? null : selectedCategory.value,
        collection:
            selectedCollection.value.isEmpty ? null : selectedCollection.value,
        tribe: selectedTribe.value.isEmpty ? null : selectedTribe.value,
        region: selectedRegion.value.isEmpty ? null : selectedRegion.value,
        material:
            selectedMaterial.value.isEmpty ? null : selectedMaterial.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        sortBy: sortBy.value,
        sortOrder: sortOrder.value,
        isFeatured: showFeaturedOnly.value ? true : null,
        isUnique: showUniqueOnly.value ? true : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> results = data['results'] ?? [];
        final bool hasNext = data['next'] != null;
        final int totalCount = data['count'] ?? 0;

        print('📊 Fetched ${results.length} artworks from API');
        print('🔄 Has next page: $hasNext');
        print('📈 Total count: $totalCount');
        print('📍 Current offset: $offset');

        final List<ArtworkList> newArtworks =
            results.map((json) => ArtworkList.fromJson(json)).toList();

        print('✅ Successfully parsed ${newArtworks.length} artworks');

        // Initialize like status for new artworks
        for (final artwork in newArtworks) {
          initializeLikeStatus(artwork);
        }

        // According to infinite_scroll_pagination documentation:
        // - If we received fewer items than requested (pageSize), it means this is the last page
        // - The package will automatically detect this and stop pagination
        final isLastPage = newArtworks.length < pageSize || !hasNext;
        print(
            '🎯 Is last page: $isLastPage (items: ${newArtworks.length}, pageSize: $pageSize, hasNext: $hasNext)');

        if (isLastPage) {
          print('🏁 This is the last page - pagination will stop');
        } else {
          print('🔄 More pages available - pagination will continue');
        }

        return newArtworks;
      } else {
        throw Exception('Failed to load artworks: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 Error fetching artworks: $e');
      String errorMessage = e.toString();
      if (e.toString().contains('Connection') ||
          e.toString().contains('SocketException')) {
        errorMessage =
            'Please check your internet connection and ensure the API server is running';
      }
      throw Exception(errorMessage);
    }
  }

  Future<void> fetchArtworkDetail(String idOrSlug) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _artworkProvider.getArtwork(idOrSlug);

      if (response.statusCode == 200 && response.data != null) {
        selectedArtwork.value = ArtworkDetail.fromJson(response.data);
        // Track view
        await _artworkProvider.trackView(idOrSlug);
      } else {
        error.value = 'Failed to load artwork details';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFeaturedArtworks() async {
    try {
      if (kDebugMode) {
        print('🎨 Fetching featured artworks...');
      }

      final response = await _artworkProvider.getFeaturedArtworks(limit: 10);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> results = data['results'] ?? [];
        featuredArtworks.assignAll(
          results.map((json) => ArtworkList.fromJson(json)).toList(),
        );

        if (kDebugMode) {
          print('✅ Featured artworks loaded: ${featuredArtworks.length} items');
        }
      } else {
        if (kDebugMode) {
          print('❌ Featured artworks request failed: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching featured artworks: $e');
      }
    }
  }

  Future<void> fetchTrendingArtworks() async {
    try {
      if (kDebugMode) {
        print('📈 Fetching trending artworks...');
      }

      final response = await _artworkProvider.getTrendingArtworks(limit: 10);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> results = data['results'] ?? [];
        trendingArtworks.assignAll(
          results.map((json) => ArtworkList.fromJson(json)).toList(),
        );

        if (kDebugMode) {
          print('✅ Trending artworks loaded: ${trendingArtworks.length} items');
        }
      } else {
        if (kDebugMode) {
          print('❌ Trending artworks request failed: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching trending artworks: $e');
      }
    }
  }

  Future<void> fetchCategories() async {
    try {
      print('🏷️ Fetching categories...');

      // Load all categories using pagination
      List<Category> allCategories = [];
      int offset = 0;
      const int pageSize = 20;

      while (true) {
        final response = await _artworkProvider.getCategories(
          offset: offset,
          limit: pageSize,
        );

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          final List<dynamic> results = data['results'] ?? [];
          final bool hasNext = data['next'] != null;
          final int totalCount = data['count'] ?? 0;

          print(
              '🏷️ Fetched ${results.length} categories from API (offset: $offset)');
          print('🏷️ Total categories available: $totalCount');
          print('🏷️ Has next page: $hasNext');

          final List<Category> newCategories =
              results.map((json) => Category.fromJson(json)).toList();

          allCategories.addAll(newCategories);

          // Break if this is the last page
          if (!hasNext || newCategories.length < pageSize) {
            break;
          }

          offset += newCategories.length;
        } else {
          print('❌ Categories request failed: ${response.statusCode}');
          break;
        }
      }

      categories.assignAll(allCategories);
      print('✅ All categories loaded: ${categories.length} total');
    } catch (e) {
      print('❌ Error fetching categories: $e');
    }
  }

  Future<void> fetchFilterOptions() async {
    try {
      print('🔍 Fetching filter options...');

      final response = await _artworkProvider.getFilterOptions();

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        filterOptions.value = data;

        print('✅ Filter options loaded successfully');
        print('🔍 Available filter categories: ${data.keys.toList()}');

        // Log details of each filter category
        data.forEach((key, value) {
          if (value is List) {
            print('🔍 $key: ${value.length} options available');
          }
        });
      } else {
        print('❌ Filter options request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching filter options: $e');
    }
  }

  Future<void> searchArtworks(String query) async {
    searchQuery.value = query;
    pagingController.refresh();
  }

  Future<void> toggleLike(String artworkId) async {
    try {
      print('🤍 Toggling like for artwork: $artworkId');

      // Optimistic update
      final currentLiked = isArtworkLiked(artworkId);
      final currentCount = getArtworkLikeCount(artworkId);
      final newLiked = !currentLiked;
      final newCount = newLiked ? currentCount + 1 : currentCount - 1;

      // Update UI immediately
      updateArtworkLikeStatus(artworkId, newLiked, newCount);

      final response = await _artworkProvider.toggleLike(artworkId);

      print('🤍 Like toggle response: ${response.data}');

      // Handle the response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final actualLiked = responseData['liked'] ?? false;
        final actualCount = responseData['like_count'] ?? 0;

        print(
            '🤍 Actual like status - isLiked: $actualLiked, count: $actualCount');

        // Update with actual values from server
        updateArtworkLikeStatus(artworkId, actualLiked, actualCount);

        // Show success message
        Get.snackbar(
          'Success',
          actualLiked ? 'Added to favorites' : 'Removed from favorites',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('❌ Error toggling like: $e');

      // Revert optimistic update on error
      final revertLiked = !isArtworkLiked(artworkId);
      final revertCount = revertLiked
          ? getArtworkLikeCount(artworkId) + 1
          : getArtworkLikeCount(artworkId) - 1;
      updateArtworkLikeStatus(artworkId, revertLiked, revertCount);

      Get.snackbar(
        'Error',
        'Failed to toggle like. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  void applyFilters({
    String? category,
    String? collection,
    String? tribe,
    String? region,
    String? material,
    double? minPrice,
    double? maxPrice,
    bool? featuredOnly,
    bool? uniqueOnly,
  }) {
    if (category != null) selectedCategory.value = category;
    if (collection != null) selectedCollection.value = collection;
    if (tribe != null) selectedTribe.value = tribe;
    if (region != null) selectedRegion.value = region;
    if (material != null) selectedMaterial.value = material;
    if (minPrice != null) this.minPrice.value = minPrice;
    if (maxPrice != null) this.maxPrice.value = maxPrice;
    if (featuredOnly != null) showFeaturedOnly.value = featuredOnly;
    if (uniqueOnly != null) showUniqueOnly.value = uniqueOnly;

    pagingController.refresh();
  }

  void clearFilters() {
    selectedCategory.value = '';
    selectedCollection.value = '';
    selectedTribe.value = '';
    selectedRegion.value = '';
    selectedMaterial.value = '';
    minPrice.value = null;
    maxPrice.value = null;
    showFeaturedOnly.value = false;
    showUniqueOnly.value = false;
    searchQuery.value = '';

    pagingController.refresh();
  }

  void sortArtworks(String field, String order) {
    sortBy.value = field;
    sortOrder.value = order;
    pagingController.refresh();
  }

  // Remove the old loadMoreArtworks method - pagination handles this automatically

  void toggleDisplayType() {
    displayType.value = displayType.value == ArtworkDisplayType.grid
        ? ArtworkDisplayType.list
        : ArtworkDisplayType.grid;
  }

  // Debug method to test pagination
  void debugPaginationState() {
    print('🐛 DEBUG: Pagination State');
    print(
        '🐛 Current items count: ${pagingController.value.items?.length ?? 0}');
    print('🐛 Has error: ${pagingController.value.error != null}');
    if (pagingController.value.error != null) {
      print('🐛 Error: ${pagingController.value.error}');
    }
  }

  // Method to force load all items (for testing)
  Future<void> loadAllItems() async {
    print('🔄 Loading all items manually...');
    int offset = 0;
    List<ArtworkList> allItems = [];

    while (true) {
      try {
        final newItems = await _fetchPage(offset);
        if (newItems.isEmpty || newItems.length < pageSize) {
          allItems.addAll(newItems);
          break;
        }
        allItems.addAll(newItems);
        offset += newItems.length;
        print('🔄 Loaded ${allItems.length} items so far...');
      } catch (e) {
        print('🚨 Error loading all items: $e');
        break;
      }
    }

    print('✅ Total items loaded: ${allItems.length}');
  }

  // Convenient getters for filter options
  List<String> get availableTribes {
    final tribes = filterOptions.value['tribes'] as List?;
    return tribes?.map((e) => e.toString()).toList() ?? [];
  }

  List<String> get availableRegions {
    final regions = filterOptions.value['regions'] as List?;
    return regions?.map((e) => e.toString()).toList() ?? [];
  }

  List<String> get availableMaterials {
    final materials = filterOptions.value['materials'] as List?;
    return materials?.map((e) => e.toString()).toList() ?? [];
  }

  List<String> get availableCollections {
    final collections = filterOptions.value['collections'] as List?;
    return collections?.map((e) => e.toString()).toList() ?? [];
  }

  Map<String, dynamic> get priceRange {
    return filterOptions.value['price_range'] as Map<String, dynamic>? ?? {};
  }

  double? get minPriceLimit {
    final range = priceRange;
    return range['min']?.toDouble();
  }

  double? get maxPriceLimit {
    final range = priceRange;
    return range['max']?.toDouble();
  }

  // Get all filter options for a specific category
  List<dynamic> getFilterOptions(String category) {
    return filterOptions.value[category] as List? ?? [];
  }

  // Check if filter options are loaded
  bool get hasFilterOptions => filterOptions.value.isNotEmpty;

  // Helper methods for like functionality
  bool isArtworkLiked(String artworkId) {
    return likeStatuses[artworkId] ?? false;
  }

  int getArtworkLikeCount(String artworkId) {
    return likeCounts[artworkId] ?? 0;
  }

  void updateArtworkLikeStatus(String artworkId, bool isLiked, int likeCount) {
    likeStatuses[artworkId] = isLiked;
    likeCounts[artworkId] = likeCount;
  }

  // Initialize like status from artwork data
  void initializeLikeStatus(ArtworkList artwork) {
    likeStatuses[artwork.id] = artwork.isLiked;
    likeCounts[artwork.id] = artwork.likeCount;
  }

  // Get total count of liked artworks
  int getTotalLikedCount() {
    return likeStatuses.values.where((isLiked) => isLiked).length;
  }

  // Get list of liked artwork IDs
  List<String> getLikedArtworkIds() {
    return likeStatuses.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  // Get liked artworks from the current artwork list
  List<ArtworkList> getLikedArtworks() {
    final likedIds = getLikedArtworkIds();
    final currentItems = pagingController.value.items ?? <ArtworkList>[];
    return currentItems
        .where((artwork) => likedIds.contains(artwork.id))
        .toList();
  }

  // Fetch liked artworks from API
  final RxList<ArtworkList> likedArtworks = <ArtworkList>[].obs;
  final RxBool isLoadingLikedArtworks = false.obs;

  Future<void> fetchLikedArtworks() async {
    try {
      isLoadingLikedArtworks.value = true;
      final response = await _artworkProvider.getLikedArtworks();

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];

        likedArtworks.value =
            results.map((json) => ArtworkList.fromJson(json)).toList();

        // Initialize like status for these artworks
        for (final artwork in likedArtworks) {
          initializeLikeStatus(artwork);
        }
      }
    } catch (e) {
      print('Error fetching liked artworks: $e');
    } finally {
      isLoadingLikedArtworks.value = false;
    }
  }
}
