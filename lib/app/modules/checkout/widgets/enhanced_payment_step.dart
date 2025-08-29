import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/checkout_controller.dart';
import '../../../core/theme/app_colors.dart';

class EnhancedPaymentStep extends GetView<CheckoutController> {
  const EnhancedPaymentStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step title
        Text(
          'Payment Processing',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Complete your payment to confirm your order',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 24.h),

        // Payment status card
        _buildPaymentStatusCard(),
        SizedBox(height: 24.h),

        // Payment instructions
        Obx(() => controller.paymentInstructions.value.isNotEmpty
            ? _buildPaymentInstructions()
            : const SizedBox.shrink()),

        // OTP Input (for bank payments)
        Obx(() => controller.showOtpInput.value
            ? _buildOtpInput()
            : const SizedBox.shrink()),

        SizedBox(height: 24.h),

        // Action buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildPaymentStatusCard() {
    return Obx(() {
      final status = controller.paymentStatus.value;
      // final paymentMethod = controller.selectedPaymentMethod.value;
      
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Status icon and title
            Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  child: Center(
                    child: _getStatusIcon(status),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusTitle(status),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _getStatusDescription(status),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (status == 'processing') ...[
              SizedBox(height: 20.h),
              // Progress indicator
              LinearProgressIndicator(
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              SizedBox(height: 12.h),
              // Countdown timer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time remaining:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    controller.formattedTimeRemaining,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
            
            if (controller.paymentReference.value.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.receipt_text,
                      size: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Reference: ',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        controller.paymentReference.value,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildPaymentInstructions() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.info_circle,
                size: 20.sp,
                color: Colors.blue,
              ),
              SizedBox(width: 8.w),
              Text(
                'Payment Instructions',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            controller.paymentInstructions.value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.blue.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInput() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.password_check,
                size: 20.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Enter OTP Code',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          TextFormField(
            onChanged: (value) => controller.otpCode.value = value,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: '123456',
              prefixIcon: Icon(Iconsax.key, size: 20.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.background,
              counterText: '',
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.processBankPaymentWithOTP(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Verify & Pay',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      final status = controller.paymentStatus.value;
      final isProcessing = controller.isProcessingPayment.value;
      
      return Column(
        children: [
          if (status == 'failed') ...[
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: isProcessing ? null : _retryPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.refresh, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Retry Payment',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          
          if (status == 'processing') ...[
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton(
                onPressed: () => controller.checkPaymentStatus(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.refresh_2, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Check Status',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          
          // Back to payment methods button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: TextButton(
              onPressed: () => controller.goToStep(CheckoutStep.paymentAndReview),
              child: Text(
                'Change Payment Method',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'processing':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icon(
          Iconsax.tick_circle,
          size: 28.sp,
          color: Colors.green,
        );
      case 'failed':
        return Icon(
          Iconsax.close_circle,
          size: 28.sp,
          color: Colors.red,
        );
      case 'processing':
        return SizedBox(
          width: 28.w,
          height: 28.w,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        );
      default:
        return Icon(
          Iconsax.card,
          size: 28.sp,
          color: AppColors.textSecondary,
        );
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'completed':
        return 'Payment Successful!';
      case 'failed':
        return 'Payment Failed';
      case 'processing':
        return 'Processing Payment...';
      default:
        return 'Payment Pending';
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'completed':
        return 'Your order has been confirmed and will be processed shortly.';
      case 'failed':
        return 'There was an issue processing your payment. Please try again.';
      case 'processing':
        return 'Please complete the payment on your device.';
      default:
        return 'Waiting for payment to be initiated.';
    }
  }

  void _retryPayment() {
    final paymentMethod = controller.selectedPaymentMethod.value;
    if (paymentMethod == null) return;
    
    if (paymentMethod.isMobilePayment) {
      controller.processEnhancedMobilePayment();
    } else if (paymentMethod.isBankTransfer) {
      controller.requestBankOTP();
    } else {
      controller.processPayPalPayment();
    }
  }
}
