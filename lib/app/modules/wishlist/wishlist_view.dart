import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/artwork_controller.dart';
import '../../core/theme/app_colors.dart';
import '../artworks/widgets/artwork_card.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    // Explicitly get the ArtworkController and fetch liked artworks when the view loads
    final artworkController = Get.find<ArtworkController>();
    artworkController.fetchLikedArtworks();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Likes',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          Obx(() => artworkController.likedArtworks.isNotEmpty
              ? IconButton(
                  onPressed: () => _showClearWishlistDialog(context),
                  icon: Icon(
                    Iconsax.trash,
                    color: AppColors.error,
                    size: 24.sp,
                  ),
                )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (artworkController.isLoadingLikedArtworks.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (artworkController.likedArtworks.isEmpty) {
          return _buildEmptyWishlist();
        }

        return RefreshIndicator(
          onRefresh: () => artworkController.fetchLikedArtworks(),
          child: Column(
            children: [
              // Wishlist Header
              Container(
                padding: EdgeInsets.all(16.w),
                margin: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.heart5,
                      color: AppColors.accent,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Favorites',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${artworkController.likedArtworks.length} ${artworkController.likedArtworks.length == 1 ? 'artwork' : 'artworks'}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Wishlist Grid
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio:
                          0.50, // Adjusted for taller content container
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                    ),
                    itemCount: artworkController.likedArtworks.length,
                    itemBuilder: (context, index) {
                      final artwork = artworkController.likedArtworks[index];
                      return ArtworkCard(artwork: artwork);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.heart,
              size: 80.sp,
              color: AppColors.greyLight,
            ),
            SizedBox(height: 24.h),
            Text(
              'Your Wishlist is Empty',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Start exploring artworks and add your favorites to see them here',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: 32.w,
                  vertical: 16.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Browse Artworks',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearWishlistDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Clear Wishlist',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to remove all items from your wishlist?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _clearWishlist();
            },
            child: Text(
              'Clear',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearWishlist() async {
    final artworkController = Get.find<ArtworkController>();
    // Remove all items one by one using toggleLike
    for (final artwork in artworkController.likedArtworks.toList()) {
      await artworkController.toggleLike(artwork.id);
    }
    // Refresh the liked artworks list
    await artworkController.fetchLikedArtworks();
  }
}
