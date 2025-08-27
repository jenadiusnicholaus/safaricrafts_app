import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/checkout_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/checkout/payment_method_model.dart';

class PaymentMethodStep extends GetView<CheckoutController> {
  const PaymentMethodStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final paymentMethods = controller.availablePaymentMethods;

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
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            if (isLoading)
              _buildLoadingState()
            else if (paymentMethods.isEmpty)
              _buildErrorState()
            else
              _buildPaymentMethods(),

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
                  child: ElevatedButton(
                    onPressed: controller.selectedPaymentMethod.value != null
                        ? _continueToReview
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Review Order',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading payment methods...',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              color: Colors.orange,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load payment methods',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please check your connection and try again',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => controller.loadPaymentMethods(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final paymentMethods = controller.availablePaymentMethods;
    final selectedPaymentMethod = controller.selectedPaymentMethod.value;

    return Column(
      children: [
        // Group payment methods by provider
        ...paymentMethods.map((method) => _buildPaymentMethodCard(method, selectedPaymentMethod)),
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethodModel method, PaymentMethodModel? selected) {
    final isSelected = selected?.method == method.method;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12.r),
        color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.selectPaymentMethod(method),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Payment method icon
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: _getPaymentMethodColor(method.provider).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        _getPaymentMethodIcon(method.provider),
                        color: _getPaymentMethodColor(method.provider),
                        size: 24.sp,
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // Payment method info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            method.description,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Radio button
                    Radio<String>(
                      value: method.method,
                      groupValue: selected?.method,
                      onChanged: (value) => controller.selectPaymentMethod(method),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),

                // Show payment options for mobile money
                if (method.provider == 'azam_pay' && method.supportedMethods.isNotEmpty)
                  _buildMobileMoneyOptions(method),

                // Show processing info
                if (method.processingFee > 0) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.info_circle,
                          color: Colors.orange,
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Processing fee: ${method.processingFee.toStringAsFixed(0)} TSh',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileMoneyOptions(PaymentMethodModel method) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Supported payment methods:',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: method.supportedMethods.map((supportedMethod) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getMobileMoneyColor(supportedMethod).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                    color:
                        _getMobileMoneyColor(supportedMethod).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getMobileMoneyIcon(supportedMethod),
                      color: _getMobileMoneyColor(supportedMethod),
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _getMobileMoneyName(supportedMethod),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: _getMobileMoneyColor(supportedMethod),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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

  Color _getPaymentMethodColor(String provider) {
    switch (provider.toLowerCase()) {
      case 'azam_pay':
        return Colors.blue;
      case 'paypal':
        return Colors.blue[800]!;
      default:
        return AppColors.primary;
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

  void _continueToReview() {
    controller.nextStep();
  }
}
