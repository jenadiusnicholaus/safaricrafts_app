import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/review_model.dart';
import '../../../controllers/review_controller.dart';
import '../../../controllers/auth_controller.dart';

class ReviewListWidget extends GetWidget<ReviewController> {
  final int? artworkId;
  final bool showCreateButton;

  const ReviewListWidget({
    super.key,
    this.artworkId,
    this.showCreateButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        _buildFilters(context),
        _buildReviewsList(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reviews',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Obx(() => Text(
                    '${controller.totalReviews.value} reviews',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  )),
            ],
          ),
          if (showCreateButton &&
              Get.find<AuthController>().isAuthenticated.value)
            ElevatedButton.icon(
              onPressed: () => _showCreateReviewDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Write Review'),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              'All Ratings',
              controller.selectedRating.value == null,
              () => controller.setRatingFilter(null),
            ),
            for (int i = 5; i >= 1; i--) _buildRatingFilterChip(i),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Verified Only',
              controller.showVerifiedOnly.value,
              () => controller.toggleVerifiedFilter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingFilterChip(int rating) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 16, color: Colors.amber),
            Text(' $rating'),
          ],
        ),
        selected: controller.selectedRating.value == rating,
        onSelected: (selected) =>
            controller.setRatingFilter(selected ? rating : null),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildReviewsList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.reviews.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.reviews.isEmpty) {
        return _buildEmptyState(context);
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.reviews.length +
            (controller.hasMoreReviews.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.reviews.length) {
            // Load more button
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () =>
                            controller.loadMoreReviews(artworkId: artworkId),
                        child: const Text('Load More Reviews'),
                      ),
              ),
            );
          }

          return ReviewItemWidget(
            review: controller.reviews[index],
            onHelpfulVote: (reviewId, vote) =>
                controller.voteHelpfulness(reviewId, vote),
            onReport: (reviewId) => _showReportDialog(context, reviewId),
            onRespond: (reviewId) => _showRespondDialog(context, reviewId),
          );
        },
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your experience!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          if (showCreateButton &&
              Get.find<AuthController>().isAuthenticated.value) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showCreateReviewDialog(context),
              child: const Text('Write the First Review'),
            ),
          ],
        ],
      ),
    );
  }

  void _showCreateReviewDialog(BuildContext context) {
    if (artworkId == null) return;

    showDialog(
      context: context,
      builder: (context) => CreateReviewDialog(artworkId: artworkId!),
    );
  }

  void _showReportDialog(BuildContext context, int reviewId) {
    showDialog(
      context: context,
      builder: (context) => ReportReviewDialog(reviewId: reviewId),
    );
  }

  void _showRespondDialog(BuildContext context, int reviewId) {
    showDialog(
      context: context,
      builder: (context) => RespondToReviewDialog(reviewId: reviewId),
    );
  }
}

class ReviewItemWidget extends StatelessWidget {
  final ReviewList review;
  final Function(int reviewId, String vote)? onHelpfulVote;
  final Function(int reviewId)? onReport;
  final Function(int reviewId)? onRespond;

  const ReviewItemWidget({
    super.key,
    required this.review,
    this.onHelpfulVote,
    this.onReport,
    this.onRespond,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewHeader(context),
            if (review.title != null) ...[
              const SizedBox(height: 8),
              Text(
                review.title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
            if (review.comment != null) ...[
              const SizedBox(height: 8),
              Text(
                review.comment!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            _buildReviewActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: review.user.avatar != null
              ? NetworkImage(review.user.avatar!)
              : null,
          child: review.user.avatar == null
              ? Text(review.user.firstName[0].toUpperCase())
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    review.user.fullName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (review.isVerifiedPurchase) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  _buildStarRating(review.rating),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(review.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'report':
                onReport?.call(review.id);
                break;
              case 'respond':
                onRespond?.call(review.id);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag_outlined),
                  SizedBox(width: 8),
                  Text('Report'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'respond',
              child: Row(
                children: [
                  Icon(Icons.reply_outlined),
                  SizedBox(width: 8),
                  Text('Respond'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 16,
          color: Colors.amber,
        );
      }),
    );
  }

  Widget _buildReviewActions(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: review.userVote != ReviewVote.helpful
                  ? () => onHelpfulVote?.call(review.id, ReviewVote.helpful)
                  : null,
              icon: Icon(
                Icons.thumb_up_outlined,
                color:
                    review.userVote == ReviewVote.helpful ? Colors.blue : null,
              ),
            ),
            Text('${review.helpfulCount}'),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: review.userVote != ReviewVote.notHelpful
                  ? () => onHelpfulVote?.call(review.id, ReviewVote.notHelpful)
                  : null,
              icon: Icon(
                Icons.thumb_down_outlined,
                color: review.userVote == ReviewVote.notHelpful
                    ? Colors.red
                    : null,
              ),
            ),
            Text('${review.notHelpfulCount}'),
          ],
        ),
        const Spacer(),
        if (review.responseCount > 0)
          TextButton(
            onPressed: () {
              // Navigate to detailed review view
            },
            child: Text('${review.responseCount} responses'),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }
}

// Dialog widgets would be implemented here
class CreateReviewDialog extends StatelessWidget {
  final int artworkId;

  const CreateReviewDialog({super.key, required this.artworkId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Write a Review'),
      content: const Text('Review creation dialog would be implemented here'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class ReportReviewDialog extends StatelessWidget {
  final int reviewId;

  const ReportReviewDialog({super.key, required this.reviewId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report Review'),
      content: const Text('Report dialog would be implemented here'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Report'),
        ),
      ],
    );
  }
}

class RespondToReviewDialog extends StatelessWidget {
  final int reviewId;

  const RespondToReviewDialog({super.key, required this.reviewId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Respond to Review'),
      content: const Text('Response dialog would be implemented here'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
