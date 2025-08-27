import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/artwork_model.dart';
import '../../../controllers/artwork_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/cart_animation_controller.dart';
import '../../../controllers/main_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/app_routes.dart';
import '../../main/main_view.dart';

class AnimatedArtworkCard extends StatefulWidget {
  final ArtworkList artwork;

  const AnimatedArtworkCard({
    super.key,
    required this.artwork,
  });

  @override
  State<AnimatedArtworkCard> createState() => _AnimatedArtworkCardState();
}

class _AnimatedArtworkCardState extends State<AnimatedArtworkCard> {
  final GlobalKey _cardKey = GlobalKey();

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

  void _handleAddToCart() {
    try {
      final cartController = Get.find<CartController>();
      final cartAnimationController = Get.find<CartAnimationController>();

      // Check if already in cart
      if (cartController.isInCart(widget.artwork.id)) {
        // Navigate to cart instead of adding again
        Get.toNamed(AppRoutes.cart);
        return;
      }

      // Trigger the flying animation
      cartAnimationController.triggerAddToCartAnimation(
        context: context,
        sourceKey: _cardKey,
        cartKey: MainView.cartIconKey,
        imageUrl: widget.artwork.getImageUrl(),
        onComplete: () {
          // Add to cart after animation starts
          cartController.addToCart(
            widget.artwork.id,
            title: widget.artwork.title,
            imageUrl: widget.artwork.getImageUrl(),
            price: widget.artwork.price,
            currency: widget.artwork.currency,
          );

          // Manually refresh the main controller cart count
          try {
            final mainController = Get.find<MainController>();
            mainController.refreshCartCount();
          } catch (e) {
            print('MainController not found: $e');
          }
        },
      );
    } catch (e) {
      // Fallback without animation
      Get.snackbar(
        'Info',
        'Cart feature initializing...',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _cardKey,
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(0), // Instagram style - no border radius
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Artist Info)
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Artist Avatar
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    widget.artwork.artistName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Artist Name and Location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.artwork.artistName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'African Art Gallery',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Featured Badge
                if (widget.artwork.isFeatured)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12.r),
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
              ],
            ),
          ),

          // Main Image
          GestureDetector(
            onTap: () => Get.toNamed(
              AppRoutes.artworkDetails,
              arguments: widget.artwork,
            ),
            child: Container(
              width: double.infinity,
              height: 350.h, // Instagram-style square-ish aspect
              child: widget.artwork.getImageUrl().isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.artwork.getImageUrl(),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: AppColors.greyLight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.image,
                              color: AppColors.grey,
                              size: 48.sp,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Loading...',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        print(
                            '🚨 Image load error for ${widget.artwork.title}: $error');
                        return Container(
                          color: AppColors.greyLight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.warning_2,
                                color: Colors.red,
                                size: 48.sp,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Failed to load',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
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
                            Iconsax.gallery,
                            color: AppColors.grey,
                            size: 64.sp,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No Image Available',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            widget.artwork.title,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          // Action Buttons Row (Like, Comment, Share, Add to Cart)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Like Button
                    Builder(
                      builder: (context) {
                        try {
                          final artworkController =
                              Get.find<ArtworkController>();
                          return Obx(() {
                            final isLiked = artworkController
                                .isArtworkLiked(widget.artwork.id);
                            return GestureDetector(
                              onTap: () => artworkController
                                  .toggleLike(widget.artwork.id),
                              child: Icon(
                                isLiked ? Iconsax.heart5 : Iconsax.heart,
                                color: isLiked
                                    ? Colors.red
                                    : AppColors.textPrimary,
                                size: 24.sp,
                              ),
                            );
                          });
                        } catch (e) {
                          return GestureDetector(
                            onTap: () {
                              Get.snackbar(
                                'Info',
                                'Like feature initializing...',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            child: Icon(
                              Iconsax.heart,
                              color: AppColors.textPrimary,
                              size: 24.sp,
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(width: 16.w),
                    // Comment Button
                    Icon(
                      Iconsax.message,
                      color: AppColors.textPrimary,
                      size: 24.sp,
                    ),
                    SizedBox(width: 16.w),
                    // Share Button
                    Icon(
                      Iconsax.send_2,
                      color: AppColors.textPrimary,
                      size: 24.sp,
                    ),
                  ],
                ),
                // Add to Cart Button (with animation)
                Builder(
                  builder: (context) {
                    try {
                      final cartController = Get.find<CartController>();
                      return Obx(() {
                        final isInCart =
                            cartController.isInCart(widget.artwork.id);
                        final isLoading = cartController.isLoading.value;

                        return GestureDetector(
                          onTap: isLoading ? null : _handleAddToCart,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: isInCart
                                  ? AppColors.accent
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isLoading) ...[
                                  SizedBox(
                                    width: 16.w,
                                    height: 16.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                ] else ...[
                                  Icon(
                                    isInCart
                                        ? Iconsax.tick_circle
                                        : Iconsax.shopping_bag,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                ],
                                Text(
                                  isInCart ? 'In Cart' : 'Add to Bag',
                                  style: TextStyle(
                                    fontSize: 12.sp,
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
                        onTap: _handleAddToCart,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.shopping_bag,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Add to Bag',
                                style: TextStyle(
                                  fontSize: 12.sp,
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

          // Likes Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Builder(
              builder: (context) {
                try {
                  final artworkController = Get.find<ArtworkController>();
                  return Obx(() {
                    final likeCount = artworkController
                        .getArtworkLikeCount(widget.artwork.id);
                    return Text(
                      '$likeCount likes',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    );
                  });
                } catch (e) {
                  return Text(
                    '${widget.artwork.likeCount} likes',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  );
                }
              },
            ),
          ),

          SizedBox(height: 4.h),

          // Caption (Title and Description)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${widget.artwork.artistName} ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: widget.artwork.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // Price Tag
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                formatPrice(widget.artwork.price, widget.artwork.currency),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // View all comments
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'View all comments',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Time posted
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Text(
              '2 hours ago',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
