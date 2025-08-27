import 'package:get/get.dart';
import '../data/models/category_model.dart';
import '../data/providers/category_provider.dart';

class CategoryController extends GetxController {
  final CategoryProvider _categoryProvider = CategoryProvider();

  // Observable state variables
  var isLoading = false.obs;
  var categories = <Category>[].obs;
  var collections = <Collection>[].obs;
  var featuredCollections = <Collection>[].obs;
  var currentCollection = Rxn<Collection>();
  var filterOptions = <String, dynamic>{}.obs;
  var stats = <String, dynamic>{}.obs;

  // Category hierarchy
  var rootCategories = <Category>[].obs;
  var categoryMap = <int, Category>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadCollections();
    loadFilterOptions();
  }

  /// Load all categories
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      final result = await _categoryProvider.getCategories(
        includeArtworkCount: true,
      );
      categories.value = result.results;

      // Build category hierarchy
      _buildCategoryHierarchy();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load categories: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load all collections
  Future<void> loadCollections() async {
    try {
      isLoading.value = true;
      final result = await _categoryProvider.getCollections();
      collections.value = result.results;

      // Load featured collections separately
      final featuredResult =
          await _categoryProvider.getCollections(featured: true);
      featuredCollections.value = featuredResult.results;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load collections: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get a specific collection
  Future<void> getCollection(String slug) async {
    try {
      isLoading.value = true;
      final collection = await _categoryProvider.getCollection(slug);
      currentCollection.value = collection;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load collection: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load filter options
  Future<void> loadFilterOptions() async {
    try {
      final options = await _categoryProvider.getFilterOptions();
      filterOptions.value = options;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load filter options: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Load statistics
  Future<void> loadStats() async {
    try {
      final statistics = await _categoryProvider.getStats();
      stats.value = statistics;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load statistics: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Create a new category (admin only)
  Future<bool> createCategory({
    required String name,
    String? description,
    int? parent,
    bool isActive = true,
    int sortOrder = 0,
  }) async {
    try {
      isLoading.value = true;

      final request = CategoryRequest(
        name: name,
        description: description,
        parent: parent,
        isActive: isActive,
        sortOrder: sortOrder,
      );

      final category = await _categoryProvider.createCategory(request);
      categories.add(category);

      // Rebuild hierarchy
      _buildCategoryHierarchy();

      Get.snackbar(
        'Success',
        'Category created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create category: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Build category hierarchy for easy navigation
  void _buildCategoryHierarchy() {
    // Clear existing hierarchy
    categoryMap.clear();
    rootCategories.clear();

    // Build category map
    for (final category in categories) {
      categoryMap[category.id] = category;
    }

    // Find root categories (no parent)
    for (final category in categories) {
      if (category.parent == null) {
        rootCategories.add(category);
      }
    }

    // Sort by sort order
    rootCategories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get subcategories for a parent category
  List<Category> getSubcategories(int parentId) {
    return categories.where((cat) => cat.parent == parentId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get category by ID
  Category? getCategoryById(int id) {
    return categoryMap[id];
  }

  /// Get category by slug
  Category? getCategoryBySlug(String slug) {
    try {
      return categories.firstWhere((cat) => cat.slug == slug);
    } catch (e) {
      return null;
    }
  }

  /// Get collection by slug
  Collection? getCollectionBySlug(String slug) {
    try {
      return collections.firstWhere((col) => col.slug == slug);
    } catch (e) {
      return null;
    }
  }

  /// Check if category has children
  bool hasSubcategories(int categoryId) {
    return categories.any((cat) => cat.parent == categoryId);
  }

  /// Get category breadcrumb path
  List<Category> getCategoryPath(int categoryId) {
    final path = <Category>[];
    Category? current = getCategoryById(categoryId);

    while (current != null) {
      path.insert(0, current);
      current =
          current.parent != null ? getCategoryById(current.parent!) : null;
    }

    return path;
  }

  /// Get available materials from filter options
  List<String> getAvailableMaterials() {
    if (filterOptions.containsKey('materials')) {
      return List<String>.from(filterOptions['materials']);
    }
    return [];
  }

  /// Get available regions from filter options
  List<String> getAvailableRegions() {
    if (filterOptions.containsKey('regions')) {
      return List<String>.from(filterOptions['regions']);
    }
    return [];
  }

  /// Get available tribes from filter options
  List<String> getAvailableTribes() {
    if (filterOptions.containsKey('tribes')) {
      return List<String>.from(filterOptions['tribes']);
    }
    return [];
  }

  /// Get price range from filter options
  Map<String, double>? getPriceRange() {
    if (filterOptions.containsKey('price_range')) {
      final range = filterOptions['price_range'];
      return {
        'min': (range['min'] ?? 0.0).toDouble(),
        'max': (range['max'] ?? 1000.0).toDouble(),
      };
    }
    return null;
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadCategories(),
      loadCollections(),
      loadFilterOptions(),
    ]);
  }
}
