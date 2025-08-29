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
          // Step indicators - Simplified to 3 steps
          Row(
            children: List.generate(3, (index) {
              final isCompleted = index < currentStepIndex;
              final isCurrent = index == currentStepIndex;
              final isActive = isCompleted || isCurrent;

              return Expanded(
                child: Row(
                  children: [
                    // Step circle
                    Container(
                      width: 40.w,
                      height: 40.h,
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
                                size: 20.sp,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isActive ? Colors.white : AppColors.grey,
                                ),
                              ),
                      ),
                    ),

                    // Connecting line (except for last step)
                    if (index < 2)
                      Expanded(
                        child: Container(
                          height: 3.h,
                          color: isCompleted
                              ? AppColors.primary
                              : AppColors.greyLight,
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),

          SizedBox(height: 12.h),

          // Step labels - Simplified to 3 steps
          Row(
            children: [
              _buildStepLabel('Address & Shipping', 0, currentStepIndex),
              _buildStepLabel('Payment', 1, currentStepIndex),
              _buildStepLabel('Complete', 2, currentStepIndex),
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
