import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../controllers/artwork_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../data/models/artwork_model.dart';
import '../artworks/widgets/instagram_style_artwork_card.dart';
import '../artworks/widgets/artwork_filters_sheet.dart';
import 'widgets/category_chip.dart';
import 'widgets/search_bar_widget.dart';

class HomeView extends GetView<ArtworkController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              Future.sync(() => controller.pagingController.refresh()),
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                title: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Iconsax.crown,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SafariCrafts',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Discover authentic African art',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  // Wishlist Button with Badge
                  Builder(
                    builder: (context) {
                      try {
                        final artworkController = Get.find<ArtworkController>();
                        return Obx(() {
                          final likedCount =
                              artworkController.getTotalLikedCount();

                          return IconButton(
                            onPressed: () => Get.toNamed(AppRoutes.wishlist),
                            icon: Stack(
                              children: [
                                Icon(
                                  Iconsax.heart,
                                  color: AppColors.textPrimary,
                                  size: 24.sp,
                                ),
                                if (likedCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(2.w),
                                      decoration: const BoxDecoration(
                                        color: AppColors.accent,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 16.w,
                                        minHeight: 16.h,
                                      ),
                                      child: Text(
                                        '$likedCount',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        });
                      } catch (e) {
                        // Fallback when ArtworkController is not available
                        return IconButton(
                          onPressed: () => Get.toNamed(AppRoutes.wishlist),
                          icon: Icon(
                            Iconsax.heart,
                            color: AppColors.textPrimary,
                            size: 24.sp,
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    onPressed: () => Get.toNamed(AppRoutes.notifications),
                    icon: Stack(
                      children: [
                        Icon(
                          Iconsax.notification,
                          color: AppColors.textPrimary,
                          size: 24.sp,
                        ),
                        Positioned(
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
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: const SearchBarWidget(),
                ),
              ),

              // Featured Banner
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  height: 200.h,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 200.h,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                    ),
                    items: [
                      _buildFeaturedBanner(
                        'Traditional Masks',
                        'Explore authentic African masks',
                        'assets/images/masks_banner.jpg',
                        AppColors.primary,
                      ),
                      _buildFeaturedBanner(
                        'Handcrafted Sculptures',
                        'Unique wooden sculptures',
                        'assets/images/sculptures_banner.jpg',
                        AppColors.accent,
                      ),
                      _buildFeaturedBanner(
                        'Textile Art',
                        'Beautiful traditional fabrics',
                        'assets/images/textiles_banner.jpg',
                        AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),

              // Categories Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Shop by Category',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed(AppRoutes.categories),
                            child: Text(
                              'See All',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        height: 120.h,
                        child: Obx(() {
                          if (controller.categories.isEmpty) {
                            // Loading state for categories
                            return ListView(
                              scrollDirection: Axis.horizontal,
                              children: List.generate(
                                5,
                                (index) => Container(
                                  width: 100.w,
                                  margin: EdgeInsets.only(right: 12.w),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.categories.length,
                            itemBuilder: (context, index) {
                              final category = controller.categories[index];
                              return CategoryChip(
                                title: category.name,
                                icon: _getCategoryIcon(category.name),
                                onTap: () {
                                  // Navigate to artworks by category page with proper arguments
                                  Get.toNamed(
                                    AppRoutes.artworksByCategory,
                                    arguments: {
                                      'categoryId': category.id,
                                      'categoryName': category.name,
                                    },
                                  );
                                },
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              // Featured Artworks
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Artworks',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
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
                                  final hasActiveFilters = controller
                                          .selectedCategory.value.isNotEmpty ||
                                      controller
                                          .selectedTribe.value.isNotEmpty ||
                                      controller
                                          .selectedRegion.value.isNotEmpty ||
                                      controller
                                          .selectedMaterial.value.isNotEmpty ||
                                      controller.selectedCollection.value
                                          .isNotEmpty ||
                                      controller.minPrice.value != null ||
                                      controller.maxPrice.value != null ||
                                      controller.showFeaturedOnly.value ||
                                      controller.showUniqueOnly.value;

                                  if (!hasActiveFilters)
                                    return const SizedBox.shrink();

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
                          TextButton(
                            onPressed: () => Get.toNamed(AppRoutes.featured),
                            child: Text(
                              'See All',
                              style: TextStyle(
                                fontSize: 14.sp,
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

              // Artworks List (Loading State)
              // Infinite scroll pagination for artworks
              PagingListener(
                controller: controller.pagingController,
                builder: (context, state, fetchNextPage) =>
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
                      children: List.generate(
                          3, (index) => _buildShimmerInstagramCard()),
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
                            'No artworks match your current filters.',
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
              ),

              // Bottom Spacing
              SliverToBoxAdapter(
                child: SizedBox(height: 100.h),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get appropriate icon for category
  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('mask') || name.contains('traditional')) {
      return Iconsax.mask;
    } else if (name.contains('sculpture') || name.contains('carving')) {
      return Iconsax.brush_2;
    } else if (name.contains('textile') ||
        name.contains('fabric') ||
        name.contains('cloth')) {
      return Iconsax.brush_1;
    } else if (name.contains('jewelry') ||
        name.contains('jewellery') ||
        name.contains('bead')) {
      return Iconsax.diamonds;
    } else if (name.contains('pottery') ||
        name.contains('ceramic') ||
        name.contains('clay')) {
      return Iconsax.cup;
    } else if (name.contains('painting') || name.contains('art')) {
      return Iconsax.paintbucket;
    } else if (name.contains('basket') || name.contains('weaving')) {
      return Iconsax.box;
    } else {
      // Default icon for unknown categories
      return Iconsax.category;
    }
  }

  Widget _buildFeaturedBanner(
    String title,
    String subtitle,
    String imagePath,
    Color overlayColor,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: [
            overlayColor.withOpacity(0.8),
            overlayColor.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: overlayColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  colors: [
                    overlayColor.withOpacity(0.1),
                    overlayColor.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.artworks),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: overlayColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                  ),
                  child: Text(
                    'Explore Now',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildShimmerInstagramCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Colors.grey[300],
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
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          width: 80.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
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
              color: Colors.grey[300],
            ),
            // Actions and content shimmer
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Container(
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Container(
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 100.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Likes count
                  Container(
                    width: 60.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Caption
                  Container(
                    width: double.infinity,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Price
                  Container(
                    width: 80.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(14.r),
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

  Widget _buildShimmerListCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              // Image placeholder
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(16.r),
                  ),
                ),
              ),
              // Content placeholder
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title placeholder
                      Container(
                        width: double.infinity,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      // Artist placeholder
                      Container(
                        width: 100.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Price and button placeholder
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 60.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          Container(
                            width: 80.w,
                            height: 32.h,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.r),
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
      ),
    );
  }
}
