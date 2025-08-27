import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/artwork_model.dart';

class ArtworkListTile extends StatelessWidget {
  final ArtworkList artwork;

  const ArtworkListTile({
    super.key,
    required this.artwork,
  });

  @override
  Widget build(BuildContext context) {
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
            // Artwork Image
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(16.r),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(16.r),
                ),
                child: artwork.getImageUrl().isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: artwork.getImageUrl(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.greyLight,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.greyLight,
                          child: Icon(
                            Iconsax.image,
                            color: AppColors.grey,
                            size: 32.sp,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.greyLight,
                        child: Icon(
                          Iconsax.image,
                          color: AppColors.grey,
                          size: 32.sp,
                        ),
                      ),
              ),
            ),

            // Artwork Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      artwork.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.greyDark,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4.h),

                    // Artist
                    Text(
                      'by ${artwork.artistName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8.h),

                    // Category & Region
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            artwork.categoryName,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (artwork.region.isNotEmpty) ...[
                          SizedBox(width: 8.w),
                          Icon(
                            Iconsax.location,
                            size: 12.sp,
                            color: AppColors.grey,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            artwork.region,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.grey,
                                    ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Price and Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${artwork.currency} ${artwork.price.toStringAsFixed(0)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                            ),
                          ],
                        ),

                        // Featured Badge
                        if (artwork.isFeatured)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Featured',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
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
