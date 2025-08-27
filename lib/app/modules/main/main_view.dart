import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../home/home_view.dart';
import '../categories/categories_view.dart';
import '../cart/cart_view.dart';
import '../profile/profile_view.dart';
import '../../controllers/main_controller.dart';
import '../../core/theme/app_colors.dart';

class MainView extends GetView<MainController> {
  static final GlobalKey cartIconKey = GlobalKey();

  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    final mainController = Get.find<MainController>();

    // Refresh cart count to ensure it's up to date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mainController.refreshCartCount();
    });

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: mainController.currentIndex.value,
            children: const [
              HomeView(),
              CategoriesView(),
              CartView(),
              ProfileView(),
            ],
          )),
      bottomNavigationBar: Obx(() => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Iconsax.home_2,
                      label: 'Home',
                      index: 0,
                      isSelected: mainController.currentIndex.value == 0,
                      controller: mainController,
                    ),
                    _buildNavItem(
                      icon: Iconsax.category,
                      label: 'Categories',
                      index: 1,
                      isSelected: mainController.currentIndex.value == 1,
                      controller: mainController,
                    ),
                    _buildNavItem(
                      icon: Iconsax.shopping_cart,
                      label: 'Cart',
                      index: 2,
                      isSelected: mainController.currentIndex.value == 2,
                      controller: mainController,
                      badge: mainController.cartItemCount.value > 0
                          ? mainController.cartItemCount.value.toString()
                          : null,
                      isCartIcon: true,
                    ),
                    _buildNavItem(
                      icon: Iconsax.user,
                      label: 'Profile',
                      index: 3,
                      isSelected: mainController.currentIndex.value == 3,
                      controller: mainController,
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required MainController controller,
    String? badge,
    bool isCartIcon = false,
  }) {
    Widget navItemWidget = GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: badge != null
              ? 20.w
              : 16.w, // Extra padding when badge is present
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none, // Allow badge to extend beyond stack
              children: [
                Icon(
                  icon,
                  size: 24.sp,
                  color: isSelected ? AppColors.primary : AppColors.grey,
                ),
                if (badge != null)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 18.w,
                        minHeight: 18.h,
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: isSelected ? AppColors.primary : AppColors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );

    // Wrap cart icon with key for animation targeting
    if (isCartIcon) {
      return Container(
        key: MainView.cartIconKey,
        child: navItemWidget,
      );
    }

    return navItemWidget;
  }
}
