import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/checkout_controller.dart';
import '../../../core/theme/app_colors.dart';

class CheckoutStepper extends GetView<CheckoutController> {
  const CheckoutStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentStepIndex =
          CheckoutStep.values.indexOf(controller.currentStep.value);

      return Column(
        children: [
          // Step indicators
          Row(
            children: List.generate(7, (index) {
              final isCompleted = index < currentStepIndex;
              final isCurrent = index == currentStepIndex;
              final isActive = isCompleted || isCurrent;

              return Expanded(
                child: Row(
                  children: [
                    // Step circle
                    Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColors.primary
                            : isCurrent
                                ? AppColors.accent
                                : AppColors.greyLight,
                        border: Border.all(
                          color: isActive ? AppColors.primary : AppColors.grey,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16.sp,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isActive ? Colors.white : AppColors.grey,
                                ),
                              ),
                      ),
                    ),

                    // Connecting line (except for last step)
                    if (index < 6)
                      Expanded(
                        child: Container(
                          height: 2.h,
                          color: isCompleted
                              ? AppColors.primary
                              : AppColors.greyLight,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),

          SizedBox(height: 8.h),

          // Step labels
          Row(
            children: [
              _buildStepLabel('Address', 0, currentStepIndex),
              _buildStepLabel('Shipping', 1, currentStepIndex),
              _buildStepLabel('Billing', 2, currentStepIndex),
              _buildStepLabel('Payment', 3, currentStepIndex),
              _buildStepLabel('Review', 4, currentStepIndex),
              _buildStepLabel('Pay', 5, currentStepIndex),
              _buildStepLabel('Done', 6, currentStepIndex),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStepLabel(String label, int stepIndex, int currentStepIndex) {
    final isActive = stepIndex <= currentStepIndex;

    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
