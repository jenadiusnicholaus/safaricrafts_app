import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/review_model.dart';
import '../../../controllers/review_controller.dart';

class AdminReviewModerationWidget extends GetWidget<ReviewController> {
  const AdminReviewModerationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _buildHeader(context),
          const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.pending_actions),
                text: 'Pending Reviews',
              ),
              Tab(
                icon: Icon(Icons.flag),
                text: 'Reported Reviews',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPendingReviewsTab(),
                _buildReportedReviewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.admin_panel_settings,
            size: 32,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Moderation',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Manage user reviews and reports',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _refreshData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingReviewsTab() {
    return Obx(() {
      if (controller.isLoading.value && controller.pendingReviews.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.pendingReviews.isEmpty) {
        return _buildEmptyState(
          icon: Icons.check_circle_outline,
          title: 'No Pending Reviews',
          subtitle: 'All reviews have been moderated',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.pendingReviews.length,
        itemBuilder: (context, index) {
          return AdminReviewCard(
            review: controller.pendingReviews[index],
            isPending: true,
            onApprove: (reviewId) => _approveReview(reviewId),
            onReject: (reviewId) => _rejectReview(reviewId),
            onFeature: (reviewId) => _featureReview(reviewId),
          );
        },
      );
    });
  }

  Widget _buildReportedReviewsTab() {
    return Obx(() {
      if (controller.isLoading.value && controller.reportedReviews.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.reportedReviews.isEmpty) {
        return _buildEmptyState(
          icon: Icons.security,
          title: 'No Reported Reviews',
          subtitle: 'No reviews have been reported for inappropriate content',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.reportedReviews.length,
        itemBuilder: (context, index) {
          return AdminReviewCard(
            review: controller.reportedReviews[index],
            isPending: false,
            onApprove: (reviewId) => _approveReview(reviewId),
            onReject: (reviewId) => _rejectReview(reviewId),
            onFeature: (reviewId) => _featureReview(reviewId),
          );
        },
      );
    });
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Get.textTheme.headlineMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _refreshData() {
    controller.loadPendingReviews();
    controller.loadReportedReviews();
  }

  void _approveReview(int reviewId) {
    Get.dialog(
      ModerationDialog(
        reviewId: reviewId,
        action: ModerationAction.approve,
        onConfirm: (notes) async {
          final success = await controller.moderateReview(
            reviewId: reviewId,
            isApproved: true,
            moderationNotes: notes,
          );
          if (success) {
            _refreshData();
          }
        },
      ),
    );
  }

  void _rejectReview(int reviewId) {
    Get.dialog(
      ModerationDialog(
        reviewId: reviewId,
        action: ModerationAction.reject,
        onConfirm: (notes) async {
          final success = await controller.moderateReview(
            reviewId: reviewId,
            isApproved: false,
            moderationNotes: notes,
          );
          if (success) {
            _refreshData();
          }
        },
      ),
    );
  }

  void _featureReview(int reviewId) {
    Get.dialog(
      ModerationDialog(
        reviewId: reviewId,
        action: ModerationAction.feature,
        onConfirm: (notes) async {
          final success = await controller.moderateReview(
            reviewId: reviewId,
            isFeatured: true,
            moderationNotes: notes,
          );
          if (success) {
            _refreshData();
          }
        },
      ),
    );
  }
}

class AdminReviewCard extends StatelessWidget {
  final ReviewList review;
  final bool isPending;
  final Function(int reviewId)? onApprove;
  final Function(int reviewId)? onReject;
  final Function(int reviewId)? onFeature;

  const AdminReviewCard({
    super.key,
    required this.review,
    required this.isPending,
    this.onApprove,
    this.onReject,
    this.onFeature,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewHeader(context),
            if (review.title != null) ...[
              const SizedBox(height: 12),
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            _buildReviewStats(context),
            const SizedBox(height: 16),
            _buildModerationActions(context),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPending ? Colors.orange[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isPending ? 'Pending' : 'Reported',
            style: TextStyle(
              fontSize: 12,
              color: isPending ? Colors.orange[800] : Colors.red[800],
              fontWeight: FontWeight.w500,
            ),
          ),
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

  Widget _buildReviewStats(BuildContext context) {
    return Row(
      children: [
        _buildStatChip(
          icon: Icons.thumb_up_outlined,
          label: '${review.helpfulCount} helpful',
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          icon: Icons.thumb_down_outlined,
          label: '${review.notHelpfulCount} not helpful',
          color: Colors.red,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          icon: Icons.reply_outlined,
          label: '${review.responseCount} responses',
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModerationActions(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => onApprove?.call(review.id),
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Approve'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => onReject?.call(review.id),
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Reject'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => onFeature?.call(review.id),
          icon: const Icon(Icons.star_outline, size: 18),
          label: const Text('Feature'),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // Navigate to detailed review view
          },
          child: const Text('View Details'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

enum ModerationAction { approve, reject, feature }

class ModerationDialog extends StatefulWidget {
  final int reviewId;
  final ModerationAction action;
  final Function(String notes) onConfirm;

  const ModerationDialog({
    super.key,
    required this.reviewId,
    required this.action,
    required this.onConfirm,
  });

  @override
  State<ModerationDialog> createState() => _ModerationDialogState();
}

class _ModerationDialogState extends State<ModerationDialog> {
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String title;
    String content;
    Color actionColor;

    switch (widget.action) {
      case ModerationAction.approve:
        title = 'Approve Review';
        content =
            'Are you sure you want to approve this review? It will be visible to all users.';
        actionColor = Colors.green;
        break;
      case ModerationAction.reject:
        title = 'Reject Review';
        content =
            'Are you sure you want to reject this review? It will be hidden from users.';
        actionColor = Colors.red;
        break;
      case ModerationAction.feature:
        title = 'Feature Review';
        content =
            'Are you sure you want to feature this review? It will be highlighted to users.';
        actionColor = Colors.blue;
        break;
    }

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Moderation Notes (Optional)',
              hintText: 'Internal notes about this action...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(_notesController.text);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: actionColor,
            foregroundColor: Colors.white,
          ),
          child: Text(title.split(' ')[0]), // Extract action word
        ),
      ],
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
