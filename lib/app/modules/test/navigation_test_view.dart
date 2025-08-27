import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class NavigationTestView extends StatelessWidget {
  const NavigationTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Navigation Test',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Authentication'),
              _buildNavigationCard('Login', AppRoutes.login, Iconsax.login),
              _buildNavigationCard(
                  'Register', AppRoutes.register, Iconsax.user_add),
              SizedBox(height: 24.h),
              _buildSectionTitle('Main Navigation'),
              _buildNavigationCard('Main App', AppRoutes.main, Iconsax.home),
              _buildNavigationCard('Home', AppRoutes.home, Iconsax.home_2),
              _buildNavigationCard(
                  'Categories', AppRoutes.categories, Iconsax.category),
              _buildNavigationCard(
                  'Cart', AppRoutes.cart, Iconsax.shopping_cart),
              _buildNavigationCard('Profile', AppRoutes.profile, Iconsax.user),
              SizedBox(height: 24.h),
              _buildSectionTitle('Artwork Pages'),
              _buildNavigationCard('Search Artworks', AppRoutes.artworkSearch,
                  Iconsax.search_normal),
              SizedBox(height: 24.h),
              _buildSectionTitle('Other Routes'),
              _buildNavigationCard(
                  'Splash Screen', AppRoutes.splash, Iconsax.flash),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildNavigationCard(String title, String route, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.primary,
          size: 24.sp,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          route,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Iconsax.arrow_right_3,
          color: AppColors.grey,
          size: 16.sp,
        ),
        onTap: () {
          try {
            Get.toNamed(route);
          } catch (e) {
            Get.snackbar(
              'Navigation Error',
              'Route $route not found: $e',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
      ),
    );
  }
}
