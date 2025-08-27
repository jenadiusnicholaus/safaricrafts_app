import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/checkout_controller.dart';
import '../../../core/theme/app_colors.dart';

class PaymentStep extends GetView<CheckoutController> {
  const PaymentStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentOrder = controller.currentOrder.value;
      final paymentMethod = controller.selectedPaymentMethod.value;
      final isProcessingPayment = controller.isProcessingPayment.value;

      if (currentOrder == null) {
        return _buildErrorState('Order not found');
      }

      if (paymentMethod == null) {
        return _buildErrorState('Payment method not selected');
      }

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
                  Iconsax.card,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Complete Payment',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Order details
            _buildOrderDetails(currentOrder),

            SizedBox(height: 20.h),

            // Payment method details
            _buildPaymentMethodDetails(paymentMethod),

            SizedBox(height: 20.h),

            // Payment form based on method
            if (paymentMethod.provider.toLowerCase() == 'azam_pay')
              _buildMobileMoneyPayment(paymentMethod, currentOrder)
            else if (paymentMethod.provider.toLowerCase() == 'paypal')
              _buildPayPalPayment(currentOrder)
            else
              _buildGenericPayment(paymentMethod, currentOrder),

            if (isProcessingPayment) ...[
              SizedBox(height: 20.h),
              _buildProcessingIndicator(),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildErrorState(String message) {
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
        children: [
          Icon(
            Iconsax.warning_2,
            color: Colors.red,
            size: 48.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => controller.previousStep(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Go Back',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(dynamic order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Details',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ID:',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                order.id ?? 'N/A',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount:',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${order.totalAmount.toStringAsFixed(0)} TSh',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodDetails(dynamic paymentMethod) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getPaymentMethodIcon(paymentMethod.provider),
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                paymentMethod.name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            paymentMethod.description,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMoneyPayment(dynamic paymentMethod, dynamic order) {
    final phoneController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Money Payment',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),

        // Phone number input
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mobile Number',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '+255712345678',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
            ),
          ],
        ),

        SizedBox(height: 20.h),

        // Select mobile money provider
        Text(
          'Select Payment Provider',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),

        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: paymentMethod.supportedMethods.map<Widget>((method) {
            return _buildMobileMoneyOption(method);
          }).toList(),
        ),

        SizedBox(height: 24.h),

        // Pay button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                _processMobileMoneyPayment(phoneController.text, order),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Pay ${order.totalAmount.toStringAsFixed(0)} TSh',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMoneyOption(String method) {
    return Obx(() {
      final selectedMobileMethod = controller.selectedMobileMoneyMethod.value;
      final isSelected = selectedMobileMethod == method;

      return GestureDetector(
        onTap: () => controller.selectMobileMoneyMethod(method),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getMobileMoneyIcon(method),
                color: isSelected
                    ? AppColors.primary
                    : _getMobileMoneyColor(method),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                _getMobileMoneyName(method),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPayPalPayment(dynamic order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PayPal Payment',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Iconsax.card,
                color: Colors.blue[700],
                size: 48.sp,
              ),
              SizedBox(height: 12.h),
              Text(
                'You will be redirected to PayPal to complete your payment securely.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        // Pay button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _processPayPalPayment(order),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Pay with PayPal',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenericPayment(dynamic paymentMethod, dynamic order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            'Complete your payment using ${paymentMethod.name}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        SizedBox(height: 24.h),

        // Pay button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _processGenericPayment(order),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Complete Payment',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Processing your payment...',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please wait while we confirm your payment.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon(String provider) {
    switch (provider.toLowerCase()) {
      case 'azam_pay':
        return Iconsax.mobile;
      case 'paypal':
        return Iconsax.card;
      default:
        return Iconsax.card;
    }
  }

  IconData _getMobileMoneyIcon(String method) {
    switch (method.toLowerCase()) {
      case 'm_pesa':
        return Iconsax.mobile;
      case 'airtel_money':
        return Iconsax.mobile;
      case 'tigo_pesa':
        return Iconsax.mobile;
      case 'bank_transfer':
        return Iconsax.bank;
      default:
        return Iconsax.card;
    }
  }

  Color _getMobileMoneyColor(String method) {
    switch (method.toLowerCase()) {
      case 'm_pesa':
        return Colors.green;
      case 'airtel_money':
        return Colors.red;
      case 'tigo_pesa':
        return Colors.blue;
      case 'bank_transfer':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  String _getMobileMoneyName(String method) {
    switch (method.toLowerCase()) {
      case 'm_pesa':
        return 'M-Pesa';
      case 'airtel_money':
        return 'Airtel Money';
      case 'tigo_pesa':
        return 'Tigo Pesa';
      case 'bank_transfer':
        return 'Bank Transfer';
      default:
        return method;
    }
  }

  void _processMobileMoneyPayment(String phoneNumber, dynamic order) {
    if (phoneNumber.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your mobile number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final selectedMethod = controller.selectedMobileMoneyMethod.value;
    if (selectedMethod == null) {
      Get.snackbar(
        'Error',
        'Please select a payment method',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    controller.processMobilePayment(phoneNumber, selectedMethod);
  }

  void _processPayPalPayment(dynamic order) {
    controller.processPayPalPayment();
  }

  void _processGenericPayment(dynamic order) {
    controller.processGenericPayment();
  }
}
