import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/artwork_model.dart';
import '../../controllers/artwork_controller.dart';

class ArtworkDetailsView extends StatelessWidget {
  const ArtworkDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ArtworkList artwork = Get.arguments as ArtworkList;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 400.h,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Icon(
                Iconsax.arrow_left,
                color: Colors.white,
                size: 24.sp,
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              // Like Button
              Builder(
                builder: (context) {
                  try {
                    final artworkController = Get.find<ArtworkController>();
                    return Obx(() {
                      final isLiked =
                          artworkController.isArtworkLiked(artwork.id);
                      final likeCount =
                          artworkController.getArtworkLikeCount(artwork.id);

                      return Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked ? Iconsax.heart5 : Iconsax.heart,
                              color: isLiked ? Colors.red : Colors.white,
                              size: 24.sp,
                            ),
                            onPressed: () =>
                                artworkController.toggleLike(artwork.id),
                          ),
                          if (likeCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  '$likeCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    });
                  } catch (e) {
                    return IconButton(
                      icon: Icon(
                        Iconsax.heart,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                      onPressed: () {
                        Get.snackbar(
                          'Info',
                          'Like feature initializing...',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    );
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Iconsax.share,
                  color: Colors.white,
                  size: 24.sp,
                ),
                onPressed: () {
                  // Share functionality
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: artwork.id,
                child: CachedNetworkImage(
                  imageUrl: artwork.getImageUrl(),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.greyLight,
                    child: Center(
                      child: Icon(
                        Iconsax.image,
                        color: AppColors.grey,
                        size: 48.sp,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.greyLight,
                    child: Center(
                      child: Icon(
                        Iconsax.image,
                        color: AppColors.grey,
                        size: 48.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                artwork.title,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'by ${artwork.artistName}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            _formatPrice(artwork.price, artwork.currency),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Stats Row
                    Row(
                      children: [
                        _buildStatItem(
                          icon: Iconsax.eye,
                          value: '${artwork.viewCount}',
                          label: 'Views',
                        ),
                        SizedBox(width: 24.w),
                        // Reactive Like Stat
                        Builder(
                          builder: (context) {
                            try {
                              final artworkController =
                                  Get.find<ArtworkController>();
                              return Obx(() {
                                final likeCount = artworkController
                                    .getArtworkLikeCount(artwork.id);
                                final isLiked = artworkController
                                    .isArtworkLiked(artwork.id);

                                return GestureDetector(
                                  onTap: () =>
                                      artworkController.toggleLike(artwork.id),
                                  child: _buildStatItem(
                                    icon: isLiked
                                        ? Iconsax.heart5
                                        : Iconsax.heart,
                                    value: '$likeCount',
                                    label: 'Likes',
                                    iconColor: isLiked ? Colors.red : null,
                                  ),
                                );
                              });
                            } catch (e) {
                              return _buildStatItem(
                                icon: Iconsax.heart,
                                value: '${artwork.likeCount}',
                                label: 'Likes',
                              );
                            }
                          },
                        ),
                        const Spacer(),
                        if (artwork.isFeatured)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'FEATURED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Action Buttons Section
                    Builder(
                      builder: (context) {
                        try {
                          final artworkController =
                              Get.find<ArtworkController>();
                          return Obx(() {
                            final isLiked =
                                artworkController.isArtworkLiked(artwork.id);
                            final likeCount = artworkController
                                .getArtworkLikeCount(artwork.id);

                            return Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: AppColors.greyLight.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.grey.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Like Button
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => artworkController
                                          .toggleLike(artwork.id),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.h,
                                          horizontal: 16.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isLiked
                                              ? Colors.red.withOpacity(0.1)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          border: Border.all(
                                            color: isLiked
                                                ? Colors.red
                                                : AppColors.grey
                                                    .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              isLiked
                                                  ? Iconsax.heart5
                                                  : Iconsax.heart,
                                              color: isLiked
                                                  ? Colors.red
                                                  : AppColors.textSecondary,
                                              size: 20.sp,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              isLiked
                                                  ? 'Liked ($likeCount)'
                                                  : 'Like ($likeCount)',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: isLiked
                                                    ? Colors.red
                                                    : AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  // Share Button
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                        horizontal: 16.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        border: Border.all(
                                          color:
                                              AppColors.grey.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Iconsax.share,
                                            color: AppColors.textSecondary,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Share',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                        } catch (e) {
                          // Fallback UI if controller not available
                          return Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: AppColors.greyLight.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                      horizontal: 16.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Iconsax.heart,
                                          color: AppColors.textSecondary,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'Like (${artwork.likeCount})',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                      horizontal: 16.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Iconsax.share,
                                          color: AppColors.textSecondary,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'Share',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),

                    SizedBox(height: 24.h),

                    // Details Section
                    _buildDetailSection('Details', [
                      _buildDetailRow('Category', artwork.categoryName),
                      _buildDetailRow('Tribe', artwork.tribe),
                      _buildDetailRow('Region', artwork.region),
                      _buildDetailRow('Material', artwork.material),
                    ]),

                    SizedBox(height: 24.h),

                    // Description (placeholder)
                    _buildDetailSection('Description', [
                      Text(
                        'This beautiful artwork represents the rich cultural heritage of ${artwork.tribe} from ${artwork.region}. Crafted with traditional techniques and ${artwork.material}, this piece showcases the authentic artistry that has been passed down through generations.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ]),

                    SizedBox(height: 100.h), // Space for bottom button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: IconButton(
                onPressed: () {
                  // Add to wishlist
                },
                icon: Icon(
                  Iconsax.heart,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Add to cart logic would go here
                  // For now, just show a success message
                  Get.snackbar(
                    'Success',
                    'Added to cart successfully!',
                    backgroundColor: AppColors.accent,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price, String currency) {
    if (currency == 'TZS') {
      // Format Tanzanian Shillings with thousands separator
      final formatter = price.toStringAsFixed(0);
      final priceStr = formatter.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return 'TZS $priceStr';
    } else {
      return '$currency ${price.toStringAsFixed(0)}';
    }
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor ?? AppColors.accent,
          size: 16.sp,
        ),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
