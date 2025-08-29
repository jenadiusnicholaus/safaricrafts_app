import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/checkout_controller.dart';
import '../../../core/theme/app_colors.dart';

class EnhancedPaymentMethodStep extends GetView<CheckoutController> {
  const EnhancedPaymentMethodStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step title
        Text(
          'Payment & Review',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Choose your payment method and complete your order',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 24.h),

        // Order Summary Card
        _buildOrderSummaryCard(),
        SizedBox(height: 24.h),

        // Payment Methods
        Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),

        Obx(() => controller.isLoading.value
            ? _buildLoadingState()
            : _buildPaymentMethods()),

        SizedBox(height: 24.h),

        // Payment Details Section
        Obx(() => controller.selectedPaymentMethod.value != null
            ? _buildPaymentDetailsSection()
            : const SizedBox.shrink()),

        SizedBox(height: 32.h),

        // Complete Order Button
        _buildCompleteOrderButton(),
      ],
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(
                Iconsax.receipt_1,
                size: 20.sp,
                color: AppColors.primary,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() => Column(
                children: [
                  _buildSummaryRow('Subtotal', controller.formattedCartTotal),
                  SizedBox(height: 8.h),
                  _buildSummaryRow('Shipping', controller.formattedShippingCost),
                  SizedBox(height: 8.h),
                  Divider(color: AppColors.border),
                  SizedBox(height: 8.h),
                  _buildSummaryRow(
                    'Total',
                    controller.formattedTotalAmount,
                    isTotal: true,
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
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

  Widget _buildPaymentMethods() {
    return Obx(() => Column(
          children: controller.availablePaymentMethods.map((method) {
            final isSelected = controller.selectedPaymentMethod.value?.method == method.method;
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              child: InkWell(
                onTap: () => controller.selectPaymentMethod(method),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Payment method icon
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.background,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Icon(
                            controller.getPaymentMethodIcon(method.method),
                            size: 24.sp,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      
                      // Payment method details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method.displayName,
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
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (method.fees != null) ...[
                              SizedBox(height: 4.h),
                              Text(
                                'Fee: ${method.fees}%',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Selection indicator
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 16.sp,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildPaymentDetailsSection() {
    final selectedMethod = controller.selectedPaymentMethod.value!;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.card,
                size: 20.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          if (selectedMethod.isMobilePayment) ...[
            _buildMobilePaymentDetails(),
          ] else if (selectedMethod.method == 'bank') ...[
            _buildBankPaymentDetails(),
          ] else if (selectedMethod.method == 'paypal') ...[
            _buildPayPalDetails(),
          ],
        ],
      ),
    );
  }

  Widget _buildMobilePaymentDetails() {
    return Column(
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
          initialValue: controller.mobilePaymentPhoneNumber.value,
          onChanged: (value) => controller.mobilePaymentPhoneNumber.value = value,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
          ],
          decoration: InputDecoration(
            hintText: '+255 712 345 678',
            prefixIcon: Icon(Iconsax.call, size: 20.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(
                Iconsax.info_circle,
                size: 16.sp,
                color: Colors.blue,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'You will receive a payment prompt on your phone. Enter your PIN to complete the payment.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankPaymentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bank selection
        Text(
          'Select Bank',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() => DropdownButtonFormField<String>(
              value: controller.bankName.value.isEmpty ? null : controller.bankName.value,
              onChanged: (value) => controller.setPaymentDetails(bank: value),
              decoration: InputDecoration(
                hintText: 'Choose your bank',
                prefixIcon: Icon(Iconsax.bank, size: 20.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: [
                DropdownMenuItem(value: 'CRDB', child: Text('CRDB Bank')),
                DropdownMenuItem(value: 'NMB', child: Text('NMB Bank')),
              ],
            )),
        SizedBox(height: 16.h),
        
        // Phone number for OTP
        Text(
          'Mobile Number (for OTP)',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          initialValue: controller.mobilePaymentPhoneNumber.value,
          onChanged: (value) => controller.mobilePaymentPhoneNumber.value = value,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '+255 712 345 678',
            prefixIcon: Icon(Iconsax.call, size: 20.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 16.h),
        
        // Bank account number
        Text(
          'Bank Account Number',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          initialValue: controller.bankAccountNumber.value,
          onChanged: (value) => controller.setPaymentDetails(bankAccount: value),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'Enter your account number',
            prefixIcon: Icon(Iconsax.card, size: 20.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        
        // OTP Input (shown when needed)
        Obx(() => controller.showOtpInput.value
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Text(
                    'Enter OTP Code',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    onChanged: (value) => controller.otpCode.value = value,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(
                      hintText: '123456',
                      prefixIcon: Icon(Iconsax.password_check, size: 20.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink()),
        
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(
                Iconsax.security_safe,
                size: 16.sp,
                color: Colors.orange,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Bank payments require OTP verification for security. You will receive an OTP on your registered mobile number.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayPalDetails() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.global,
            size: 16.sp,
            color: Colors.blue,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'You will be redirected to PayPal to complete your payment securely.',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteOrderButton() {
    return Obx(() {
      final isProcessing = controller.isProcessingPayment.value || controller.isLoading.value;
      final canProceed = controller.selectedPaymentMethod.value != null && 
                        _hasRequiredPaymentDetails();
      
      return SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: canProceed && !isProcessing 
              ? () => controller.completePaymentAndReview()
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
          child: isProcessing
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.tick_circle,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Complete Order',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  bool _hasRequiredPaymentDetails() {
    final selectedMethod = controller.selectedPaymentMethod.value;
    if (selectedMethod == null) return false;
    
    if (selectedMethod.isMobilePayment) {
      return controller.mobilePaymentPhoneNumber.value.isNotEmpty &&
             controller.isValidPhoneNumber(controller.mobilePaymentPhoneNumber.value);
    } else if (selectedMethod.isBankTransfer) {
      return controller.bankName.value.isNotEmpty &&
             controller.bankAccountNumber.value.isNotEmpty;
    } else if (selectedMethod.isPayPal) {
      return true; // PayPal doesn't require additional details upfront
    }
    
    return false;
  }

}
