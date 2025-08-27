class ReviewList {
  final int id;
  final Reviewer user;
  final int rating;
  final String? title;
  final String? comment;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final int notHelpfulCount;
  final double helpfulnessScore;
  final String? userVote;
  final int responseCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewList({
    required this.id,
    required this.user,
    required this.rating,
    this.title,
    this.comment,
    required this.isVerifiedPurchase,
    required this.helpfulCount,
    required this.notHelpfulCount,
    required this.helpfulnessScore,
    this.userVote,
    required this.responseCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewList.fromJson(Map<String, dynamic> json) {
    return ReviewList(
      id: json['id'],
      user: Reviewer.fromJson(json['user']),
      rating: json['rating'],
      title: json['title'],
      comment: json['comment'],
      isVerifiedPurchase: json['is_verified_purchase'],
      helpfulCount: json['helpful_count'],
      notHelpfulCount: json['not_helpful_count'],
      helpfulnessScore: double.parse(json['helpfulness_score'].toString()),
      userVote: json['user_vote'],
      responseCount: int.parse(json['response_count'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'rating': rating,
      'title': title,
      'comment': comment,
      'is_verified_purchase': isVerifiedPurchase,
      'helpful_count': helpfulCount,
      'not_helpful_count': notHelpfulCount,
      'helpfulness_score': helpfulnessScore.toString(),
      'user_vote': userVote,
      'response_count': responseCount.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ReviewDetail {
  final int id;
  final Reviewer user;
  final int rating;
  final String? title;
  final String? comment;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final int notHelpfulCount;
  final double helpfulnessScore;
  final String? userVote;
  final int responseCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ReviewResponse> responses;
  final String artworkTitle;
  final List<String>? images;

  ReviewDetail({
    required this.id,
    required this.user,
    required this.rating,
    this.title,
    this.comment,
    required this.isVerifiedPurchase,
    required this.helpfulCount,
    required this.notHelpfulCount,
    required this.helpfulnessScore,
    this.userVote,
    required this.responseCount,
    required this.createdAt,
    required this.updatedAt,
    required this.responses,
    required this.artworkTitle,
    this.images,
  });

  factory ReviewDetail.fromJson(Map<String, dynamic> json) {
    return ReviewDetail(
      id: json['id'],
      user: Reviewer.fromJson(json['user']),
      rating: json['rating'],
      title: json['title'],
      comment: json['comment'],
      isVerifiedPurchase: json['is_verified_purchase'],
      helpfulCount: json['helpful_count'],
      notHelpfulCount: json['not_helpful_count'],
      helpfulnessScore: double.parse(json['helpfulness_score'].toString()),
      userVote: json['user_vote'],
      responseCount: int.parse(json['response_count'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      responses: (json['responses'] as List<dynamic>?)
              ?.map((e) => ReviewResponse.fromJson(e))
              .toList() ??
          [],
      artworkTitle: json['artwork_title'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'rating': rating,
      'title': title,
      'comment': comment,
      'is_verified_purchase': isVerifiedPurchase,
      'helpful_count': helpfulCount,
      'not_helpful_count': notHelpfulCount,
      'helpfulness_score': helpfulnessScore.toString(),
      'user_vote': userVote,
      'response_count': responseCount.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'responses': responses.map((e) => e.toJson()).toList(),
      'artwork_title': artworkTitle,
      'images': images,
    };
  }
}

class Reviewer {
  final int id;
  final String firstName;
  final String lastName;
  final String? avatar;

  Reviewer({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatar,
  });

  String get fullName => '$firstName $lastName';

  factory Reviewer.fromJson(Map<String, dynamic> json) {
    return Reviewer(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
    };
  }
}

class ReviewResponse {
  final int id;
  final Reviewer user;
  final String responseText;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewResponse({
    required this.id,
    required this.user,
    required this.responseText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      id: json['id'],
      user: Reviewer.fromJson(json['user']),
      responseText: json['response_text'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'response_text': responseText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ReviewStats {
  final int totalReviews;
  final double averageRating;
  final Map<String, int> ratingDistribution;
  final int verifiedPurchaseCount;

  ReviewStats({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
    required this.verifiedPurchaseCount,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      totalReviews: json['total_reviews'],
      averageRating: double.parse(json['average_rating'].toString()),
      ratingDistribution: Map<String, int>.from(json['rating_distribution']),
      verifiedPurchaseCount: json['verified_purchase_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_reviews': totalReviews,
      'average_rating': averageRating.toString(),
      'rating_distribution': ratingDistribution,
      'verified_purchase_count': verifiedPurchaseCount,
    };
  }
}

class ReviewCreateRequest {
  final int rating;
  final String? title;
  final String? comment;
  final List<String>? images;

  ReviewCreateRequest({
    required this.rating,
    this.title,
    this.comment,
    this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'title': title,
      'comment': comment,
      'images': images,
    };
  }
}

class ReviewUpdateRequest {
  final int rating;
  final String? title;
  final String? comment;
  final List<String>? images;

  ReviewUpdateRequest({
    required this.rating,
    this.title,
    this.comment,
    this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'title': title,
      'comment': comment,
      'images': images,
    };
  }
}

class ReviewHelpfulnessRequest {
  final String vote; // 'helpful' or 'not_helpful'

  ReviewHelpfulnessRequest({required this.vote});

  Map<String, dynamic> toJson() {
    return {
      'vote': vote,
    };
  }
}

class ReviewReportRequest {
  final String reason; // 'spam', 'inappropriate', 'fake', 'other'
  final String? description;

  ReviewReportRequest({
    required this.reason,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'description': description,
    };
  }
}

class ReviewResponseRequest {
  final String responseText;

  ReviewResponseRequest({required this.responseText});

  Map<String, dynamic> toJson() {
    return {
      'response_text': responseText,
    };
  }
}

class ReviewModerationRequest {
  final bool? isApproved;
  final bool? isFeatured;
  final String? moderationNotes;

  ReviewModerationRequest({
    this.isApproved,
    this.isFeatured,
    this.moderationNotes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (isApproved != null) data['is_approved'] = isApproved;
    if (isFeatured != null) data['is_featured'] = isFeatured;
    if (moderationNotes != null) data['moderation_notes'] = moderationNotes;
    return data;
  }
}

class ReviewReport {
  final int id;
  final String reason;
  final String? description;
  final DateTime createdAt;

  ReviewReport({
    required this.id,
    required this.reason,
    this.description,
    required this.createdAt,
  });

  factory ReviewReport.fromJson(Map<String, dynamic> json) {
    return ReviewReport(
      id: json['id'],
      reason: json['reason'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PaginatedReviewList {
  final int count;
  final String? next;
  final String? previous;
  final List<ReviewList> results;

  PaginatedReviewList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedReviewList.fromJson(Map<String, dynamic> json) {
    return PaginatedReviewList(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>)
          .map((e) => ReviewList.fromJson(e))
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

// Enum classes for better type safety
class ReviewReason {
  static const String spam = 'spam';
  static const String inappropriate = 'inappropriate';
  static const String fake = 'fake';
  static const String other = 'other';
}

class ReviewVote {
  static const String helpful = 'helpful';
  static const String notHelpful = 'not_helpful';
}

class ReviewOrdering {
  static const String createdAt = 'created_at';
  static const String createdAtDesc = '-created_at';
  static const String rating = 'rating';
  static const String ratingDesc = '-rating';
  static const String helpfulCount = 'helpful_count';
  static const String helpfulCountDesc = '-helpful_count';
  static const String helpfulness = 'helpfulness';
}
