import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 4.h,
      ),
      leading: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
          size: 20.sp,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Iconsax.arrow_right_3,
        color: AppColors.textSecondary,
        size: 16.sp,
      ),
    );
  }
}
