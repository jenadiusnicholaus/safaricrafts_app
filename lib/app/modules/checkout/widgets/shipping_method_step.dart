import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/checkout_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/checkout/shipping_method_model.dart';

class ShippingMethodStep extends GetView<CheckoutController> {
  const ShippingMethodStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(
                Iconsax.truck,
                color: AppColors.primary,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Shipping Method',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Loading state
          Obx(() => controller.isLoading.value
              ? _buildLoadingState()
              : _buildShippingMethods()),

          SizedBox(height: 24.h),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.previousStep(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.selectedShippingMethod.value != null
                          ? () => controller.nextStep()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Continue to Billing',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        SizedBox(height: 40.h),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        SizedBox(height: 16.h),
        Text(
          'Loading shipping methods...',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildShippingMethods() {
    return Obx(() {
      if (controller.availableShippingMethods.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        children: controller.availableShippingMethods.map((method) {
          return _buildShippingMethodCard(method);
        }).toList(),
      );
    });
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        SizedBox(height: 40.h),
        Icon(
          Iconsax.truck_remove,
          color: AppColors.grey,
          size: 48.sp,
        ),
        SizedBox(height: 16.h),
        Text(
          'No shipping methods available',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Please check your shipping address or try again later.',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        ElevatedButton(
          onPressed: () => controller.loadShippingMethods(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'Retry',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildShippingMethodCard(ShippingMethodModel method) {
    return Obx(() {
      final isSelected =
          controller.selectedShippingMethod.value?.id == method.id;

      return GestureDetector(
        onTap: () => controller.selectShippingMethod(method),
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Radio button
              Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10.w,
                          height: 10.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : null,
              ),

              SizedBox(width: 12.w),

              // Method details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Method name and carrier
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            method.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          method.formattedCost,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    // Description
                    Text(
                      method.description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Carrier and delivery time
                    Row(
                      children: [
                        Icon(
                          Iconsax.truck_fast,
                          color: AppColors.accent,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          method.carrier,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Icon(
                          Iconsax.clock,
                          color: AppColors.accent,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          method.deliveryTimeRange,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    if (method.estimatedDelivery.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Iconsax.calendar,
                            color: AppColors.accent,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Est. delivery: ${method.estimatedDelivery}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Weight and dimension limits
                    if (method.maxWeight > 0) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Iconsax.weight,
                            color: AppColors.grey,
                            size: 12.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Max weight: ${method.maxWeight}kg',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.grey,
                            ),
                          ),
                          if (method.maxDimensions.isNotEmpty) ...[
                            SizedBox(width: 16.w),
                            Icon(
                              Iconsax.box,
                              color: AppColors.grey,
                              size: 12.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              method.maxDimensions,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
