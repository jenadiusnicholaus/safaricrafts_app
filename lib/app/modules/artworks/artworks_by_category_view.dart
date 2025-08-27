import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../controllers/artwork_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/artwork_model.dart';
import 'widgets/instagram_style_artwork_card.dart';
import 'widgets/artwork_filters_sheet.dart';

class ArtworksByCategory extends GetView<ArtworkController> {
  const ArtworksByCategory({super.key});

  @override
  Widget build(BuildContext context) {
    // Get category arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    final categoryName = arguments?['categoryName'] ?? 'Category';

    // Set the category filter when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (categoryName != 'Category') {
        controller.selectedCategory.value = categoryName;
        controller.pagingController.refresh();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            // Clear category filter when going back
            controller.selectedCategory.value = '';
            controller.pagingController.refresh();
            Get.back();
          },
          icon: Icon(
            Iconsax.arrow_left,
            color: AppColors.textPrimary,
            size: 24.sp,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categoryName,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // Filter Button
          IconButton(
            onPressed: () {
              Get.bottomSheet(
                const ArtworkFiltersSheet(),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              );
            },
            icon: Stack(
              children: [
                Icon(
                  Iconsax.filter,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                // Show indicator if filters are active
                Obx(() {
                  final hasActiveFilters =
                      controller.selectedCategory.value.isNotEmpty ||
                          controller.selectedTribe.value.isNotEmpty ||
                          controller.selectedRegion.value.isNotEmpty ||
                          controller.selectedMaterial.value.isNotEmpty ||
                          controller.selectedCollection.value.isNotEmpty ||
                          controller.minPrice.value != null ||
                          controller.maxPrice.value != null ||
                          controller.showFeaturedOnly.value ||
                          controller.showUniqueOnly.value;

                  if (!hasActiveFilters) return const SizedBox.shrink();

                  return Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            Future.sync(() => controller.pagingController.refresh()),
        child: PagingListener(
          controller: controller.pagingController,
          builder: (context, state, fetchNextPage) => CustomScrollView(
            slivers: [
              // Active Filters Display
              Obx(() {
                final hasActiveFilters =
                    controller.selectedCategory.value.isNotEmpty ||
                        controller.selectedTribe.value.isNotEmpty ||
                        controller.selectedRegion.value.isNotEmpty ||
                        controller.selectedMaterial.value.isNotEmpty ||
                        controller.selectedCollection.value.isNotEmpty ||
                        controller.showFeaturedOnly.value ||
                        controller.showUniqueOnly.value;

                if (!hasActiveFilters)
                  return const SliverToBoxAdapter(child: SizedBox.shrink());

                return SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(16.w),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Iconsax.filter,
                              size: 16.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Active Filters:',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                controller.clearFilters();
                              },
                              child: Text(
                                'Clear All',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 4.h,
                          children: [
                            if (controller.selectedCategory.value.isNotEmpty)
                              _buildFilterChip(
                                  'Category: ${controller.selectedCategory.value}'),
                            if (controller.selectedTribe.value.isNotEmpty)
                              _buildFilterChip(
                                  'Tribe: ${controller.selectedTribe.value}'),
                            if (controller.selectedRegion.value.isNotEmpty)
                              _buildFilterChip(
                                  'Region: ${controller.selectedRegion.value}'),
                            if (controller.selectedMaterial.value.isNotEmpty)
                              _buildFilterChip(
                                  'Material: ${controller.selectedMaterial.value}'),
                            if (controller.selectedCollection.value.isNotEmpty)
                              _buildFilterChip(
                                  'Collection: ${controller.selectedCollection.value}'),
                            if (controller.showFeaturedOnly.value)
                              _buildFilterChip('Featured Only'),
                            if (controller.showUniqueOnly.value)
                              _buildFilterChip('Unique Only'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Artworks List
              PagedSliverList<int, ArtworkList>(
                state: state,
                fetchNextPage: fetchNextPage,
                builderDelegate: PagedChildBuilderDelegate<ArtworkList>(
                  itemBuilder: (context, artwork, index) {
                    return InstagramStyleArtworkCard(artwork: artwork);
                  },
                  firstPageErrorIndicatorBuilder: (context) => Container(
                    margin: EdgeInsets.all(20.w),
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
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
                          onPressed: fetchNextPage,
                          icon: Icon(Iconsax.refresh, size: 16.sp),
                          label: Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  firstPageProgressIndicatorBuilder: (context) => Column(
                    children: List.generate(3, (index) => _buildShimmerCard()),
                  ),
                  newPageProgressIndicatorBuilder: (context) => Container(
                    padding: EdgeInsets.all(16.w),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.w,
                      ),
                    ),
                  ),
                  noItemsFoundIndicatorBuilder: (context) => Container(
                    margin: EdgeInsets.all(20.w),
                    padding: EdgeInsets.all(40.w),
                    child: Column(
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
                          'No artworks found in "$categoryName" category.\nTry adjusting your filters.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          width: 80.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Main image shimmer
            Container(
              width: double.infinity,
              height: 350.h,
              color: Colors.white,
            ),
            // Actions and content shimmer
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Container(
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 100.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
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
