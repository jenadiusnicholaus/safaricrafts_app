import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/checkout_controller.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/checkout_stepper.dart';
import 'widgets/shipping_address_step.dart';
import 'widgets/payment_method_step.dart';
import 'widgets/order_confirmation_step.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: AppColors.textPrimary,
            size: 24.sp,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => controller.currentStep.value != CheckoutStep.confirmation
              ? IconButton(
                  icon: Icon(
                    Iconsax.refresh,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
                  onPressed: () => controller.resetCheckout(),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.w),
            child: CheckoutStepper(),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Obx(() => _buildCurrentStep()),
            ),
          ),

          // Error display
          Obx(() => controller.error.value != null
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  color: Colors.red.shade50,
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.warning_2,
                        color: Colors.red,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          controller.error.value!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Iconsax.close_circle,
                          color: Colors.red,
                          size: 16.sp,
                        ),
                        onPressed: () => controller.error.value = null,
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (controller.currentStep.value) {
      case CheckoutStep.addressAndShipping:
        return ShippingAddressStep();
      case CheckoutStep.paymentAndReview:
        return PaymentMethodStep();
      case CheckoutStep.confirmation:
        return OrderConfirmationStep();
      default:
        return ShippingAddressStep();
    }
  }
}
