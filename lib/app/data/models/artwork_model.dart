enum ArtworkStatus {
  draft,
  pending,
  active,
  sold,
  inactive,
  rejected,
}

enum MediaKind {
  image,
  video,
  glb,
  usdz,
}

class MainImage {
  final int id;
  final String kind;
  final String file;
  final String thumbnail;
  final String altText;
  final String caption;
  final bool isPrimary;
  final int sortOrder;
  final int? fileSize;
  final int? width;
  final int? height;
  final String? duration;
  final DateTime createdAt;

  MainImage({
    required this.id,
    required this.kind,
    required this.file,
    required this.thumbnail,
    required this.altText,
    required this.caption,
    required this.isPrimary,
    required this.sortOrder,
    this.fileSize,
    this.width,
    this.height,
    this.duration,
    required this.createdAt,
  });

  factory MainImage.fromJson(Map<String, dynamic> json) {
    print('🔧 MainImage.fromJson - Raw data: $json');

    final id = json['id'] ?? 0;
    final kind = json['kind'] ?? 'image';
    final file = json['file']?.toString() ?? '';
    final thumbnail = json['thumbnail']?.toString() ?? '';
    final altText = json['alt_text']?.toString() ?? '';
    final caption = json['caption']?.toString() ?? '';
    final isPrimary = json['is_primary'] ?? false;
    final sortOrder = json['sort_order'] ?? 0;

    print('🔧 Parsed values:');
    print('🔧   file: "$file"');
    print('🔧   thumbnail: "$thumbnail"');
    print('🔧   altText: "$altText"');

    final mainImage = MainImage(
      id: id,
      kind: kind,
      file: file,
      thumbnail: thumbnail,
      altText: altText,
      caption: caption,
      isPrimary: isPrimary,
      sortOrder: sortOrder,
      fileSize: json['file_size'],
      width: json['width'],
      height: json['height'],
      duration: json['duration']?.toString(),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );

    print('🔧 Created MainImage: $mainImage');
    return mainImage;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind,
      'file': file,
      'thumbnail': thumbnail,
      'alt_text': altText,
      'caption': caption,
      'is_primary': isPrimary,
      'sort_order': sortOrder,
      'file_size': fileSize,
      'width': width,
      'height': height,
      'duration': duration,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MainImage(id: $id, file: "$file", thumbnail: "$thumbnail", kind: "$kind")';
  }
}

class Media {
  final int id;
  final MediaKind kind;
  final String file;
  final String? thumbnail;
  final String altText;
  final String caption;
  final bool isPrimary;
  final int sortOrder;
  final int? fileSize;
  final int? width;
  final int? height;
  final String? duration;
  final DateTime createdAt;

  Media({
    required this.id,
    required this.kind,
    required this.file,
    this.thumbnail,
    required this.altText,
    required this.caption,
    required this.isPrimary,
    required this.sortOrder,
    this.fileSize,
    this.width,
    this.height,
    this.duration,
    required this.createdAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] ?? 0,
      kind: MediaKind.values.firstWhere(
        (e) => e.name == json['kind'],
        orElse: () => MediaKind.image,
      ),
      file: json['file'] ?? '',
      thumbnail: json['thumbnail'],
      altText: json['alt_text'] ?? '',
      caption: json['caption'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
      fileSize: json['file_size'],
      width: json['width'],
      height: json['height'],
      duration: json['duration'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'file': file,
      'thumbnail': thumbnail,
      'alt_text': altText,
      'caption': caption,
      'is_primary': isPrimary,
      'sort_order': sortOrder,
      'file_size': fileSize,
      'width': width,
      'height': height,
      'duration': duration,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Category {
  final int id;
  final String name;
  final String slug;
  final String description;
  final int? parent;
  final List<Category> children;
  final bool isActive;
  final int sortOrder;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.parent,
    required this.children,
    required this.isActive,
    required this.sortOrder,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      parent: json['parent'],
      children: json['children'] != null
          ? (json['children'] as List).map((c) => Category.fromJson(c)).toList()
          : [],
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'parent': parent,
      'children': children.map((c) => c.toJson()).toList(),
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}

class ArtworkList {
  final String id;
  final String title;
  final String slug;
  final String artistName;
  final String categoryName;
  final double price;
  final String currency;
  final MainImage? mainImage;
  final bool isFeatured;
  final String tribe;
  final String region;
  final String material;
  final int viewCount;
  final int likeCount;
  final bool isLiked; // New field for like status

  ArtworkList({
    required this.id,
    required this.title,
    required this.slug,
    required this.artistName,
    required this.categoryName,
    required this.price,
    required this.currency,
    this.mainImage,
    required this.isFeatured,
    required this.tribe,
    required this.region,
    required this.material,
    required this.viewCount,
    required this.likeCount,
    this.isLiked = false, // Default to false
  });

  // Helper method to get the image URL (thumbnail preferred, fallback to file)
  String getImageUrl() {
    if (mainImage == null) return '';
    if (mainImage!.thumbnail.isNotEmpty) {
      return mainImage!.thumbnail;
    }
    return mainImage!.file;
  }

  factory ArtworkList.fromJson(Map<String, dynamic> json) {
    print('🚀 ArtworkList.fromJson called for: ${json['title']}');
    print('📦 Full JSON data: $json');

    // Handle main_image using the MainImage model
    MainImage? mainImage;
    print('🔍 Checking main_image field...');
    print('🔍 main_image value: ${json['main_image']}');
    print('🔍 main_image type: ${json['main_image'].runtimeType}');
    print('🔍 main_image is null: ${json['main_image'] == null}');

    if (json['main_image'] != null &&
        json['main_image'] is Map<String, dynamic>) {
      try {
        print('🔧 Attempting to parse MainImage...');
        mainImage =
            MainImage.fromJson(json['main_image'] as Map<String, dynamic>);
        print('🖼️ Successfully parsed MainImage for: ${json['title']}');
        print('📸 Thumbnail URL: ${mainImage.thumbnail}');
        print('🖼️ File URL: ${mainImage.file}');
      } catch (e) {
        print('⚠️ Error parsing MainImage for ${json['title']}: $e');
        print('⚠️ Stack trace: $e');
        mainImage = null;
      }
    } else {
      if (json['main_image'] == null) {
        print('❌ main_image is null for artwork: ${json['title']}');
      } else {
        print(
            '⚠️ main_image is not a Map<String, dynamic> for artwork: ${json['title']}');
        print('⚠️ Type: ${json['main_image'].runtimeType}');
        print('⚠️ Value: ${json['main_image']}');
      }
      mainImage = null;
    }

    final artwork = ArtworkList(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      artistName: json['artist_name'] ?? '',
      categoryName: json['category_name'] ?? '',
      price: double.parse(json['price']?.toString() ?? '0'),
      currency: json['currency'] ?? 'TZS',
      mainImage: mainImage,
      isFeatured: json['is_featured'] ?? false,
      tribe: json['tribe'] ?? '',
      region: json['region'] ?? '',
      material: json['material'] ?? '',
      viewCount: json['view_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      isLiked: json['is_liked'] ?? false, // Parse is_liked field
    );

    print('🎯 Created artwork with imageUrl: "${artwork.getImageUrl()}"');
    print('🎯 Created artwork with mainImage: "${artwork.mainImage}"');
    return artwork;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'artist_name': artistName,
      'category_name': categoryName,
      'price': price.toString(),
      'currency': currency,
      'main_image': mainImage?.toJson(),
      'is_featured': isFeatured,
      'tribe': tribe,
      'region': region,
      'material': material,
      'view_count': viewCount,
      'like_count': likeCount,
      'is_liked': isLiked, // Include is_liked in JSON
    };
  }
}

class ArtworkDetail {
  final String id;
  final String title;
  final String slug;
  final String description;
  final String? story;
  final String? meaning;
  final String artist;
  final Category category;
  final List<String> collections;
  final String tribe;
  final String region;
  final String material;
  final List<String> tags;
  final String dimensions;
  final double? weight;
  final double price;
  final String currency;
  final int stockQuantity;
  final ArtworkStatus status;
  final bool isFeatured;
  final bool isUnique;
  final Map<String, dynamic>? attributes;
  final String? metaDescription;
  final String? metaKeywords;
  final List<Media> media;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final int viewCount;
  final int likeCount;
  final bool isLiked; // Add isLiked field
  final bool isAvailable;

  ArtworkDetail({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    this.story,
    this.meaning,
    required this.artist,
    required this.category,
    required this.collections,
    required this.tribe,
    required this.region,
    required this.material,
    required this.tags,
    required this.dimensions,
    this.weight,
    required this.price,
    required this.currency,
    required this.stockQuantity,
    required this.status,
    required this.isFeatured,
    required this.isUnique,
    this.attributes,
    this.metaDescription,
    this.metaKeywords,
    required this.media,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    required this.viewCount,
    required this.likeCount,
    this.isLiked = false, // Add isLiked to constructor with default value
    required this.isAvailable,
  });

  String get mainImage => media.isNotEmpty
      ? media.firstWhere((m) => m.isPrimary, orElse: () => media.first).file
      : '';

  factory ArtworkDetail.fromJson(Map<String, dynamic> json) {
    return ArtworkDetail(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      story: json['story'],
      meaning: json['meaning'],
      artist: json['artist'] ?? '',
      category: Category.fromJson(json['category'] ?? {}),
      collections: List<String>.from(json['collections'] ?? []),
      tribe: json['tribe'] ?? '',
      region: json['region'] ?? '',
      material: json['material'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      dimensions: json['dimensions'] ?? '',
      weight: json['weight']?.toDouble(),
      price: double.parse(json['price']?.toString() ?? '0'),
      currency: json['currency'] ?? 'TZS',
      stockQuantity: json['stock_quantity'] ?? 0,
      status: ArtworkStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ArtworkStatus.draft,
      ),
      isFeatured: json['is_featured'] ?? false,
      isUnique: json['is_unique'] ?? false,
      attributes: json['attributes'],
      metaDescription: json['meta_description'],
      metaKeywords: json['meta_keywords'],
      media: json['media'] != null
          ? (json['media'] as List).map((m) => Media.fromJson(m)).toList()
          : [],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : null,
      viewCount: json['view_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      isLiked: json['is_liked'] ?? false, // Parse isLiked field
      isAvailable:
          json['is_available'] == 'true' || json['is_available'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'story': story,
      'meaning': meaning,
      'artist': artist,
      'category': category.toJson(),
      'collections': collections,
      'tribe': tribe,
      'region': region,
      'material': material,
      'tags': tags,
      'dimensions': dimensions,
      'weight': weight,
      'price': price.toString(),
      'currency': currency,
      'stock_quantity': stockQuantity,
      'status': status.name,
      'is_featured': isFeatured,
      'is_unique': isUnique,
      'attributes': attributes,
      'meta_description': metaDescription,
      'meta_keywords': metaKeywords,
      'media': media.map((m) => m.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'view_count': viewCount,
      'like_count': likeCount,
      'is_liked': isLiked, // Include isLiked in JSON
      'is_available': isAvailable,
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
  final List<ArtworkList> featuredArtworks;
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
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['cover_image'],
      isFeatured: json['is_featured'] ?? false,
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
      artworksCount: int.parse(json['artworks_count']?.toString() ?? '0'),
      featuredArtworks: json['featured_artworks'] != null
          ? (json['featured_artworks'] as List)
              .map((a) => ArtworkList.fromJson(a))
              .toList()
          : [],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
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
      'featured_artworks': featuredArtworks.map((a) => a.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
