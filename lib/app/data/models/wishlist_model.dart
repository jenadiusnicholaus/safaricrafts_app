import 'artwork_model.dart';

class LikedArtwork {
  final int id;
  final ArtworkList artwork;
  final DateTime likedAt;

  LikedArtwork({
    required this.id,
    required this.artwork,
    required this.likedAt,
  });

  factory LikedArtwork.fromJson(Map<String, dynamic> json) {
    return LikedArtwork(
      id: json['id'],
      artwork: ArtworkList.fromJson(json['artwork']),
      likedAt: DateTime.parse(json['liked_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artwork': artwork.toJson(),
      'liked_at': likedAt.toIso8601String(),
    };
  }
}

class PaginatedLikedArtworkList {
  final int count;
  final String? next;
  final String? previous;
  final List<LikedArtwork> results;

  PaginatedLikedArtworkList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedLikedArtworkList.fromJson(Map<String, dynamic> json) {
    return PaginatedLikedArtworkList(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>)
          .map((e) => LikedArtwork.fromJson(e))
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

class LikeResponse {
  final bool liked;
  final String message;

  LikeResponse({
    required this.liked,
    required this.message,
  });

  factory LikeResponse.fromJson(Map<String, dynamic> json) {
    return LikeResponse(
      liked: json['liked'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'liked': liked,
      'message': message,
    };
  }
}
