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

class ArtworkListCard extends StatelessWidget {
  final ArtworkList artwork;

  const ArtworkListCard({
    super.key,
    required this.artwork,
  });

  @override
  Widget build(BuildContext context) {
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
        margin: EdgeInsets.only(bottom: 16.h),
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
        child: Row(
          children: [
            // Image Section
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(16.r),
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(16.r),
                    ),
                    child: artwork.getImageUrl().isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: artwork.getImageUrl(),
                            width: 120.w,
                            height: 120.h,
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              print(
                                  '📱 List Card - Loading image for ${artwork.title}: $url');
                              return Container(
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
                              );
                            },
                            errorWidget: (context, url, error) {
                              print(
                                  '🚨 List Card - Image load error for ${artwork.title}: $error');
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
                            width: 120.w,
                            height: 120.h,
                            color: AppColors.greyLight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.gallery,
                                  color: AppColors.grey,
                                  size: 40.sp,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'No Image',
                                  style: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  // Featured Badge
                  if (artwork.isFeatured)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
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
                        padding: EdgeInsets.all(4.w),
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
                                return Icon(
                                  isLiked ? Iconsax.heart5 : Iconsax.heart,
                                  color: isLiked
                                      ? AppColors.accent
                                      : AppColors.grey,
                                  size: 14.sp,
                                );
                              });
                            } catch (e) {
                              return Icon(
                                Iconsax.heart,
                                color: AppColors.grey,
                                size: 14.sp,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      artwork.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    // Artist
                    Text(
                      'by ${artwork.artistName}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    // Price and Actions Row
                    Row(
                      children: [
                        // Price and Like Count
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatPrice(artwork.price, artwork.currency),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.heart,
                                    color: AppColors.accent,
                                    size: 10.sp,
                                  ),
                                  SizedBox(width: 2.w),
                                  Flexible(
                                    child: Builder(
                                      builder: (context) {
                                        try {
                                          final artworkController =
                                              Get.find<ArtworkController>();
                                          return Obx(() {
                                            final likeCount = artworkController
                                                .getArtworkLikeCount(
                                                    artwork.id);
                                            return Text(
                                              '$likeCount likes',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: AppColors.textSecondary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          });
                                        } catch (e) {
                                          return Text(
                                            '${artwork.likeCount} likes',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: AppColors.textSecondary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Add to Cart Button
                        Flexible(
                          flex: 1,
                          child: Builder(
                            builder: (context) {
                              try {
                                final cartController =
                                    Get.find<CartController>();
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
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isInCart
                                            ? AppColors.accent
                                            : AppColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(6.r),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isLoading) ...[
                                            SizedBox(
                                              width: 12.w,
                                              height: 12.h,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                          ] else ...[
                                            Icon(
                                              isInCart
                                                  ? Iconsax.tick_circle
                                                  : Iconsax.add,
                                              color: Colors.white,
                                              size: 12.sp,
                                            ),
                                            SizedBox(width: 4.w),
                                          ],
                                          Text(
                                            isInCart ? 'Added' : 'Add',
                                            style: TextStyle(
                                              fontSize: 11.sp,
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
                                      horizontal: 12.w,
                                      vertical: 6.h,
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
                                          size: 12.sp,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          'Add',
                                          style: TextStyle(
                                            fontSize: 11.sp,
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
