import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'widgets/profile_menu_item.dart';

class ProfileView extends GetView<AuthController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient.isEmpty
                        ? [AppColors.primary, AppColors.primaryLight]
                        : AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Obx(() {
                  final user = controller.currentUser.value;
                  return Column(
                    children: [
                      // Profile Picture
                      Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: user?.avatar != null
                            ? ClipOval(
                                child: Image.network(
                                  user!.avatar!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Iconsax.profile_circle,
                                size: 40.sp,
                                color: Colors.white,
                              ),
                      ),
                      SizedBox(height: 16.h),

                      // User Info
                      Text(
                        user?.displayName ?? 'Guest User',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (user?.email != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          user!.email,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],

                      SizedBox(height: 16.h),

                      // Quick Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('Orders', '12', Iconsax.box),
                          _buildStatItem('Wishlist', '8', Iconsax.heart),
                          _buildStatItem('Reviews', '15', Iconsax.star1),
                        ],
                      ),
                    ],
                  );
                }),
              ),

              SizedBox(height: 24.h),

              // Guest User Login Prompt (for marketplace browsing)
              Obx(() {
                final user = controller.currentUser.value;
                if (user == null) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 24.h),
                    padding: EdgeInsets.all(20.w),
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
                    child: Column(
                      children: [
                        Icon(
                          Iconsax.user_add,
                          size: 48.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Join SafariCrafts',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Create an account to save favorites, track orders, and get personalized recommendations',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Get.toNamed(AppRoutes.register),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Get.toNamed(AppRoutes.login),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                ),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Menu Items
              Container(
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
                child: Column(
                  children: [
                    ProfileMenuItem(
                      icon: Iconsax.edit,
                      title: 'Edit Profile',
                      subtitle: 'Update your information',
                      onTap: () => Get.toNamed(AppRoutes.editProfile),
                    ),
                    const Divider(height: 1),
                    ProfileMenuItem(
                      icon: Iconsax.box,
                      title: 'My Orders',
                      subtitle: 'Track your orders',
                      onTap: () => Get.toNamed(AppRoutes.orders),
                    ),
                    const Divider(height: 1),
                    ProfileMenuItem(
                      icon: Iconsax.location,
                      title: 'Addresses',
                      subtitle: 'Manage delivery addresses',
                      onTap: () => Get.toNamed(AppRoutes.addresses),
                    ),
                    const Divider(height: 1),
                    ProfileMenuItem(
                      icon: Iconsax.heart,
                      title: 'Wishlist',
                      subtitle: 'Your favorite artworks',
                      onTap: () => Get.toNamed(AppRoutes.wishlist),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Settings & Support
              Container(
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
                child: Column(
                  children: [
                    ProfileMenuItem(
                      icon: Iconsax.notification,
                      title: 'Notifications',
                      subtitle: 'Manage notifications',
                      onTap: () => Get.toNamed(AppRoutes.notifications),
                    ),
                    const Divider(height: 1),
                    ProfileMenuItem(
                      icon: Iconsax.lock,
                      title: 'Change Password',
                      subtitle: 'Update your password',
                      onTap: () => Get.toNamed(AppRoutes.changePassword),
                    ),
                    const Divider(height: 1),
                    ProfileMenuItem(
                      icon: Iconsax.setting_2,
                      title: 'Settings',
                      subtitle: 'App preferences',
                      onTap: () => Get.toNamed(AppRoutes.settings),
                    ),
                    const Divider(height: 1),
                    ProfileMenuItem(
                      icon: Iconsax.support,
                      title: 'Help & Support',
                      subtitle: 'Get help and support',
                      onTap: () => Get.toNamed(AppRoutes.support),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Legal & Logout
              Container(
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
                child: Column(
                  children: [
                    ProfileMenuItem(
                      icon: Iconsax.shield_security,
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      onTap: () => Get.toNamed(AppRoutes.privacy),
                    ),
                    const Divider(height: 1),
                    ProfileMenuItem(
                      icon: Iconsax.document_text,
                      title: 'Terms & Conditions',
                      subtitle: 'Read terms of service',
                      onTap: () => Get.toNamed(AppRoutes.terms),
                    ),
                    const Divider(height: 1),
                    ProfileMenuItem(
                      icon: Iconsax.logout,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      onTap: () => _showLogoutDialog(context),
                      isDestructive: true,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // App Version
              Text(
                'SafariCrafts v1.0.0',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: 100.h), // Bottom spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
