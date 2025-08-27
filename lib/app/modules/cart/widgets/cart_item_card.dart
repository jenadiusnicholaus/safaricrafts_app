import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/cart_model.dart';

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
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
          // Product Image
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.greyLight,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: cartItem.artwork.getImageUrl(),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.greyLight,
                  child: Center(
                    child: Icon(
                      Iconsax.image,
                      color: AppColors.grey,
                      size: 24.sp,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) {
                  print(
                      '🖼️ Image loading error for: ${cartItem.artwork.getImageUrl()}');
                  print('🖼️ Raw mainImage: ${cartItem.artwork.mainImage}');
                  print('🖼️ Error: $error');
                  return Container(
                    color: AppColors.greyLight,
                    child: Center(
                      child: Icon(
                        Iconsax.image,
                        color: AppColors.grey,
                        size: 24.sp,
                      ),
                    ),
                  );
                },
                imageBuilder: (context, imageProvider) {
                  print(
                      '🖼️ Image loaded successfully: ${cartItem.artwork.getImageUrl()}');
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.artwork.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                if (cartItem.artwork.artistName.isNotEmpty)
                  Text(
                    'by ${cartItem.artwork.artistName}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '\$${cartItem.artwork.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Quantity Controls
                          GestureDetector(
                            onTap: () {
                              if (cartItem.quantity > 1) {
                                onQuantityChanged(cartItem.quantity - 1);
                              }
                            },
                            child: Container(
                              width: 28.w,
                              height: 28.h,
                              decoration: BoxDecoration(
                                color: AppColors.greyLight,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Icon(
                                Iconsax.minus,
                                size: 14.sp,
                                color: cartItem.quantity > 1
                                    ? AppColors.textPrimary
                                    : AppColors.grey,
                              ),
                            ),
                          ),
                          Container(
                            width: 35.w,
                            child: Text(
                              '${cartItem.quantity}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                onQuantityChanged(cartItem.quantity + 1),
                            child: Container(
                              width: 28.w,
                              height: 28.h,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Icon(
                                Iconsax.add,
                                size: 14.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Remove Button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Iconsax.trash,
                color: AppColors.error,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
