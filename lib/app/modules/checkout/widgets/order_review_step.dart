import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/checkout_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../core/theme/app_colors.dart';

class OrderReviewStep extends GetView<CheckoutController> {
  Widget _buildOrderItems(List cartItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Items (${cartItems.length})',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: cartItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == cartItems.length - 1;

              // Support both String and object for mainImage
              String? imageUrl;
              final mainImage = item.artwork.mainImage;
              if (mainImage is String) {
                imageUrl = mainImage;
              } else if (mainImage != null && mainImage.file != null) {
                imageUrl = mainImage.file;
              }

              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    // Product image
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6.r),
                        image: (imageUrl != null && imageUrl.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (imageUrl == null || imageUrl.isEmpty)
                          ? Icon(
                              Iconsax.image,
                              color: AppColors.textSecondary,
                              size: 20.sp,
                            )
                          : null,
                    ),

                    SizedBox(width: 12.w),

                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.artwork.title ?? 'Product',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Qty: ${item.quantity}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Text(
                      '${(item.unitPrice * item.quantity).toStringAsFixed(0)} TSh',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  const OrderReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cartController = Get.find<CartController>();
      final cartItems = cartController.cart.value?.items ?? [];
      final shippingAddress = controller.shippingAddress.value;
      final billingAddress = controller.billingAddress.value;
      final shippingMethod = controller.selectedShippingMethod.value;
      final paymentMethod = controller.selectedPaymentMethod.value;

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
                  Iconsax.receipt_edit,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Review Your Order',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Order Items
            _buildOrderItems(cartItems),

            SizedBox(height: 20.h),

            // Shipping Address
            if (shippingAddress != null)
              _buildAddressSection(
                  'Shipping Address', shippingAddress, Iconsax.location),

            SizedBox(height: 16.h),

            // Billing Address
            if (billingAddress != null)
              _buildAddressSection(
                  'Billing Address', billingAddress, Iconsax.receipt_edit),

            SizedBox(height: 16.h),

            // Shipping Method
            if (shippingMethod != null)
              _buildShippingMethodSection(shippingMethod)
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  'No shipping method selected. Please go back and select a shipping method.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 13.sp,
                  ),
                ),
              ),

            SizedBox(height: 16.h),

            // Payment Method
            if (paymentMethod != null)
              _buildPaymentMethodSection(paymentMethod),

            SizedBox(height: 20.h),

            // Order Summary
            _buildOrderSummary(cartController, shippingMethod),

            SizedBox(height: 24.h),

            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.previousStep(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
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
                    onPressed: _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: controller.isCreatingOrder.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Place Order',
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

  Widget _buildAddressSection(String title, dynamic address, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            address.formattedAddress,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShippingMethodSection(dynamic shippingMethod) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Iconsax.truck,
              color: AppColors.primary,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Shipping Method',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shippingMethod.name,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      // Prefer deliveryTimeRange if available, else estimatedDelivery
                      (shippingMethod.deliveryTimeRange != null &&
                              shippingMethod.deliveryTimeRange
                                  .toString()
                                  .isNotEmpty)
                          ? '${shippingMethod.deliveryTimeRange} delivery'
                          : (shippingMethod.estimatedDelivery != null &&
                                  shippingMethod.estimatedDelivery
                                      .toString()
                                      .isNotEmpty)
                              ? 'Est. delivery: ${shippingMethod.estimatedDelivery}'
                              : '',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                (shippingMethod.calculatedCost != null
                        ? shippingMethod.calculatedCost.toStringAsFixed(0)
                        : '0') +
                    ' TSh',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(dynamic paymentMethod) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Iconsax.card,
              color: AppColors.primary,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentMethod.name,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      paymentMethod.description,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (paymentMethod.processingFee > 0)
                Text(
                  '+${paymentMethod.processingFee.toStringAsFixed(0)} TSh',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.orange,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(
      CartController cartController, dynamic shippingMethod) {
    final subtotal = cartController.subtotal;
    final shippingCost = shippingMethod?.calculatedCost ?? 0.0;
    final tax = 0.0; // You can calculate tax if needed
    final total = subtotal + shippingCost + tax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                  'Subtotal', '${subtotal.toStringAsFixed(0)} TSh'),
              SizedBox(height: 8.h),
              _buildSummaryRow(
                  'Shipping', '${shippingCost.toStringAsFixed(0)} TSh'),
              if (tax > 0) ...[
                SizedBox(height: 8.h),
                _buildSummaryRow('Tax', '${tax.toStringAsFixed(0)} TSh'),
              ],
              Divider(height: 24.h, color: AppColors.border),
              _buildSummaryRow(
                'Total',
                '${total.toStringAsFixed(0)} TSh',
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
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
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: FontWeight.w600,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _placeOrder() {
    controller.createOrder();
  }
}
