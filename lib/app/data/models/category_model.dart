class Category {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final int? parent;
  final List<Category> children;
  final bool isActive;
  final int sortOrder;
  final int? artworkCount;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.parent,
    required this.children,
    required this.isActive,
    required this.sortOrder,
    this.artworkCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      parent: json['parent'],
      children: json['children'] != null
          ? (json['children'] as List<dynamic>)
              .map((e) => Category.fromJson(e))
              .toList()
          : [],
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
      artworkCount: json['artwork_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'parent': parent,
      'children': children.map((e) => e.toJson()).toList(),
      'is_active': isActive,
      'sort_order': sortOrder,
      'artwork_count': artworkCount,
    };
  }
}

class CategoryRequest {
  final String name;
  final String? description;
  final int? parent;
  final bool isActive;
  final int sortOrder;

  CategoryRequest({
    required this.name,
    this.description,
    this.parent,
    this.isActive = true,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'parent': parent,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}

class Collection {
  final int id;
  final String title;
  final String slug;
  final String description;
  final String? coverImage;
  final bool isFeatured;
  final bool isActive;
  final int sortOrder;
  final int artworksCount;
  final List<dynamic>
      featuredArtworks; // You might want to create an ArtworkSummary model
  final DateTime createdAt;
  final DateTime updatedAt;

  Collection({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    this.coverImage,
    required this.isFeatured,
    required this.isActive,
    required this.sortOrder,
    required this.artworksCount,
    required this.featuredArtworks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      description: json['description'],
      coverImage: json['cover_image'],
      isFeatured: json['is_featured'] ?? false,
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
      artworksCount: int.parse(json['artworks_count'].toString()),
      featuredArtworks: json['featured_artworks'] ?? [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'cover_image': coverImage,
      'is_featured': isFeatured,
      'is_active': isActive,
      'sort_order': sortOrder,
      'artworks_count': artworksCount.toString(),
      'featured_artworks': featuredArtworks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PaginatedCategoryList {
  final int count;
  final String? next;
  final String? previous;
  final List<Category> results;

  PaginatedCategoryList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedCategoryList.fromJson(Map<String, dynamic> json) {
    return PaginatedCategoryList(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>)
          .map((e) => Category.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
}

class PaginatedCollectionList {
  final int count;
  final String? next;
  final String? previous;
  final List<Collection> results;

  PaginatedCollectionList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedCollectionList.fromJson(Map<String, dynamic> json) {
    return PaginatedCollectionList(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>)
          .map((e) => Collection.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
}
