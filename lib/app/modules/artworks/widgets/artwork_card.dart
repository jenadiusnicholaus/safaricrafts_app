import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/artwork_model.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/artwork_controller.dart';

class ArtworkCard extends StatelessWidget {
  final ArtworkList artwork;

  const ArtworkCard({
    super.key,
    required this.artwork,
  });

  @override
  Widget build(BuildContext context) {
    // Debug: Print the image URL being used
    print(
        '🎨 Artwork: ${artwork.title} - Image URL: "${artwork.getImageUrl()}"');

    // Format price with proper currency and thousands separator
    String formatPrice(double price, String currency) {
      final symbol = AppConstants.currencySymbols[currency] ?? currency;

      if (currency == AppConstants.defaultCurrency) {
        // Format Tanzanian Shillings with thousands separator
        final formatter = price.toStringAsFixed(0);
        final priceStr = formatter.replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
        return '$symbol $priceStr';
      } else {
        return '$symbol ${price.toStringAsFixed(2)}';
      }
    }

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.artworkDetails,
        arguments: artwork,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                      child: artwork.getImageUrl().isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: artwork.getImageUrl(),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.greyLight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Iconsax.image,
                                      color: AppColors.grey,
                                      size: 32.sp,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Loading...',
                                      style: TextStyle(
                                        color: AppColors.grey,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                print(
                                    '🚨 Image load error for ${artwork.title}: $error');
                                print('🔗 Failed URL: $url');
                                return Container(
                                  color: AppColors.greyLight,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Iconsax.warning_2,
                                        color: Colors.red,
                                        size: 32.sp,
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Failed to load',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: AppColors.greyLight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.gallery_slash,
                                    color: AppColors.grey,
                                    size: 32.sp,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'No Image URL',
                                    style: TextStyle(
                                      color: AppColors.grey,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: () {
                        try {
                          final artworkController =
                              Get.find<ArtworkController>();
                          artworkController.toggleLike(artwork.id);
                        } catch (e) {
                          print('ArtworkController not available: $e');
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Builder(
                          builder: (context) {
                            try {
                              final artworkController =
                                  Get.find<ArtworkController>();
                              return Obx(() {
                                final isLiked = artworkController
                                    .isArtworkLiked(artwork.id);
                                return GestureDetector(
                                  onTap: () =>
                                      artworkController.toggleLike(artwork.id),
                                  child: Icon(
                                    isLiked ? Iconsax.heart5 : Iconsax.heart,
                                    color:
                                        isLiked ? Colors.red : AppColors.grey,
                                    size: 16.sp,
                                  ),
                                );
                              });
                            } catch (e) {
                              // Fallback when controller is not available
                              return Icon(
                                Iconsax.heart,
                                color: AppColors.grey,
                                size: 16.sp,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  // Featured Badge (if applicable)
                  if (artwork.isFeatured)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content - Fixed height approach
            Container(
              height: 130.h, // Increased height for content area
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - Fixed height container
                  Container(
                    height: 42.h, // Slightly reduced title height
                    child: Text(
                      artwork.title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 3.h), // Reduced spacing
                  // Artist - Fixed height
                  Container(
                    height: 16.h, // Reduced artist height
                    child: Text(
                      'by ${artwork.artistName}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 6.h), // Reduced spacing
                  // Price and Add to Cart - Use remaining space
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Changed to start
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formatPrice(artwork.price, artwork.currency),
                                style: TextStyle(
                                  fontSize: 12.sp, // Slightly smaller font
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 1.h), // Minimal spacing
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Iconsax.heart,
                                    color: AppColors.accent,
                                    size: 9.sp, // Smaller icon
                                  ),
                                  SizedBox(width: 1.w), // Reduced spacing
                                  // Reactive like count
                                  Builder(
                                    builder: (context) {
                                      try {
                                        final artworkController =
                                            Get.find<ArtworkController>();
                                        return Obx(() {
                                          final likeCount = artworkController
                                              .getArtworkLikeCount(artwork.id);
                                          return Text(
                                            '$likeCount',
                                            style: TextStyle(
                                              fontSize: 8.sp, // Smaller font
                                              color: AppColors.textSecondary,
                                            ),
                                          );
                                        });
                                      } catch (e) {
                                        // Fallback to static count
                                        return Text(
                                          '${artwork.likeCount}',
                                          style: TextStyle(
                                            fontSize: 8.sp, // Smaller font
                                            color: AppColors.textSecondary,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Add to Cart Button
                        Builder(
                          builder: (context) {
                            try {
                              final cartController = Get.find<CartController>();
                              return Obx(() {
                                final isInCart =
                                    cartController.isInCart(artwork.id);
                                final isLoading =
                                    cartController.isLoading.value;

                                return GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () {
                                          if (isInCart) {
                                            // Navigate to cart
                                            Get.toNamed(AppRoutes.cart);
                                          } else {
                                            cartController.addToCart(
                                              artwork.id,
                                              title: artwork.title,
                                              imageUrl: artwork.getImageUrl(),
                                              price: artwork.price,
                                              currency: artwork.currency,
                                            );
                                          }
                                        },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isInCart
                                          ? AppColors.accent
                                          : AppColors.primary,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isLoading) ...[
                                          SizedBox(
                                            width: 10.w,
                                            height: 10.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                        ] else ...[
                                          Icon(
                                            isInCart
                                                ? Iconsax.tick_circle
                                                : Iconsax.add,
                                            color: Colors.white,
                                            size: 10.sp,
                                          ),
                                          SizedBox(width: 2.w),
                                        ],
                                        Text(
                                          isInCart ? 'Added' : 'Add',
                                          style: TextStyle(
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                            } catch (e) {
                              // Fallback when controller is not available
                              return GestureDetector(
                                onTap: () {
                                  Get.snackbar(
                                    'Info',
                                    'Cart feature initializing...',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Iconsax.add,
                                        color: Colors.white,
                                        size: 10.sp,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        'Add',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
