import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../controllers/cart_controller.dart';

class LocalCartItemCard extends StatelessWidget {
  final LocalCartItem cartItem;
  final int index;
  final VoidCallback? onRemove;
  final Function(int)? onQuantityChanged;

  const LocalCartItemCard({
    super.key,
    required this.cartItem,
    required this.index,
    this.onRemove,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Artwork Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: CachedNetworkImage(
              imageUrl: cartItem.artworkImage,
              width: 80.w,
              height: 80.h,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 80.w,
                height: 80.h,
                color: AppColors.greyLight,
                child: Icon(
                  Iconsax.image,
                  color: AppColors.grey,
                  size: 32.sp,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 80.w,
                height: 80.h,
                color: AppColors.greyLight,
                child: Icon(
                  Iconsax.image,
                  color: AppColors.grey,
                  size: 32.sp,
                ),
              ),
            ),
          ),

          SizedBox(width: 16.w),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.artworkTitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'by ${cartItem.artistName}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${cartItem.unitPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Row(
                      children: [
                        // Quantity Controls
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.greyLight),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (cartItem.quantity > 1) {
                                    onQuantityChanged
                                        ?.call(cartItem.quantity - 1);
                                  } else {
                                    onRemove?.call();
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  child: Icon(
                                    cartItem.quantity > 1
                                        ? Iconsax.minus
                                        : Iconsax.trash,
                                    size: 16.sp,
                                    color: cartItem.quantity > 1
                                        ? AppColors.textSecondary
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                child: Text(
                                  '${cartItem.quantity}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  onQuantityChanged
                                      ?.call(cartItem.quantity + 1);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  child: Icon(
                                    Iconsax.add,
                                    size: 16.sp,
                                    color: AppColors.textSecondary,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
