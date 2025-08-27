import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/category_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'widgets/category_grid_item.dart';

class CategoriesView extends GetView<CategoryController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Categories',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.artworkSearch),
            icon: Icon(
              Iconsax.search_normal,
              color: AppColors.textPrimary,
              size: 24.sp,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadCategories(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient.isEmpty
                      ? const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: AppColors.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore African Art',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Discover authentic pieces from different cultures and traditions',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Iconsax.crown,
                      size: 40.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Main Categories Grid
              Obx(() {
                if (controller.isLoading.value &&
                    controller.categories.isEmpty) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) => _buildShimmerItem(),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                  ),
                  itemCount: controller.categories.length +
                      CategoriesView._additionalCategories.length,
                  itemBuilder: (context, index) {
                    if (index < controller.categories.length) {
                      final category = controller.categories[index];
                      return CategoryGridItem(
                        title: category.name,
                        icon: _getCategoryIcon(category.name),
                        artworkCount:
                            0, // Default since category doesn't have artworkCount
                        onTap: () => Get.toNamed(
                          AppRoutes.artworksByCategory,
                          arguments: category,
                        ),
                      );
                    } else {
                      final additionalIndex =
                          index - controller.categories.length;
                      final category =
                          CategoriesView._additionalCategories[additionalIndex];
                      return CategoryGridItem(
                        title: category['title'],
                        icon: category['icon'],
                        artworkCount: category['count'],
                        onTap: () => Get.toNamed(category['route']),
                      );
                    }
                  },
                );
              }),

              SizedBox(height: 24.h),

              // Quick Access Section
              Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickAccessCard(
                      'Featured',
                      'Curated collection',
                      Iconsax.star1,
                      AppColors.warning,
                      () => Get.toNamed(AppRoutes.featured),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildQuickAccessCard(
                      'Trending',
                      'Popular now',
                      Iconsax.arrow_up_1,
                      AppColors.success,
                      () => Get.toNamed(AppRoutes.trending),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickAccessCard(
                      'New Arrivals',
                      'Latest additions',
                      Iconsax.add_circle,
                      AppColors.info,
                      () => Get.toNamed(AppRoutes.newArrivals),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildQuickAccessCard(
                      'Artists',
                      'Meet creators',
                      Iconsax.profile_2user,
                      AppColors.accent,
                      () => Get.toNamed(AppRoutes.artists),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 100.h), // Bottom spacing for navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'masks':
        return Iconsax.mask;
      case 'sculptures':
        return Iconsax.brush_2;
      case 'textiles':
        return Iconsax.brush_1;
      case 'jewelry':
        return Iconsax.diamonds;
      case 'pottery':
        return Iconsax.cup;
      case 'paintings':
        return Iconsax.brush_2;
      case 'baskets':
        return Iconsax.bag_2;
      case 'musical instruments':
        return Iconsax.music;
      default:
        return Iconsax.category;
    }
  }

  static const List<Map<String, dynamic>> _additionalCategories = [
    {
      'title': 'Tribes',
      'icon': Iconsax.people,
      'count': 25,
      'route': AppRoutes.tribes,
    },
    {
      'title': 'Collections',
      'icon': Iconsax.archive,
      'count': 12,
      'route': AppRoutes.collections,
    },
  ];
}
