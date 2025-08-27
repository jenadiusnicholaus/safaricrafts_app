import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../controllers/artwork_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/artwork_model.dart';
import 'widgets/artwork_card.dart';
import 'widgets/artwork_list_card.dart';

class ArtworkGalleryView extends GetView<ArtworkController> {
  const ArtworkGalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Artworks',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.greyDark,
          ),
        ),
        actions: [
          Obx(() => IconButton(
                onPressed: controller.toggleDisplayType,
                icon: Icon(
                  controller.displayType.value == ArtworkDisplayType.grid
                      ? Iconsax.element_4
                      : Iconsax.row_vertical,
                  color: AppColors.greyDark,
                ),
              )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            Future.sync(() => controller.pagingController.refresh()),
        child: Obx(() => PagingListener(
              controller: controller.pagingController,
              builder: (context, state, fetchNextPage) {
                if (controller.displayType.value == ArtworkDisplayType.grid) {
                  return PagedGridView<int, ArtworkList>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.55, // Adjusted for redesigned card
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                    ),
                    padding: EdgeInsets.all(16.w),
                    builderDelegate: PagedChildBuilderDelegate<ArtworkList>(
                      itemBuilder: (context, artwork, index) {
                        return ArtworkCard(artwork: artwork);
                      },
                      firstPageErrorIndicatorBuilder: (context) =>
                          _buildErrorIndicator(fetchNextPage),
                      newPageErrorIndicatorBuilder: (context) =>
                          _buildErrorIndicator(fetchNextPage),
                      firstPageProgressIndicatorBuilder: (context) =>
                          _buildLoadingIndicator(),
                      newPageProgressIndicatorBuilder: (context) =>
                          _buildLoadingMoreIndicator(),
                      noItemsFoundIndicatorBuilder: (context) =>
                          _buildNoItemsIndicator(),
                    ),
                  );
                } else {
                  return PagedListView<int, ArtworkList>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    padding: EdgeInsets.all(16.w),
                    builderDelegate: PagedChildBuilderDelegate<ArtworkList>(
                      itemBuilder: (context, artwork, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: ArtworkListCard(artwork: artwork),
                        );
                      },
                      firstPageErrorIndicatorBuilder: (context) =>
                          _buildErrorIndicator(fetchNextPage),
                      newPageErrorIndicatorBuilder: (context) =>
                          _buildErrorIndicator(fetchNextPage),
                      firstPageProgressIndicatorBuilder: (context) =>
                          _buildLoadingIndicator(),
                      newPageProgressIndicatorBuilder: (context) =>
                          _buildLoadingMoreIndicator(),
                      noItemsFoundIndicatorBuilder: (context) =>
                          _buildNoItemsIndicator(),
                    ),
                  );
                }
              },
            )),
      ),
    );
  }

  Widget _buildErrorIndicator(VoidCallback onRetry) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.wifi_square,
            size: 48.sp,
            color: Colors.red.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'Connection Error',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Failed to load artworks. Please check your connection.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.red.shade600,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Iconsax.refresh, size: 16.sp),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.w,
        ),
      ),
    );
  }

  Widget _buildNoItemsIndicator() {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.gallery_slash,
            size: 64.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Artworks Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No artworks match your current filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
