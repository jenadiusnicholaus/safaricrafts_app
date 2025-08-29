import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/checkout_controller.dart';
import '../../../core/theme/app_colors.dart';

class OrderConfirmationStep extends GetView<CheckoutController> {
  const OrderConfirmationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentOrder = controller.currentOrder.value;
      final paymentStatus = controller.paymentStatus.value;

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),

            // Status icon and message
            _buildStatusIcon(paymentStatus),

            SizedBox(height: 24.h),

            _buildStatusMessage(paymentStatus),

            SizedBox(height: 24.h),

            // Order details
            if (currentOrder != null) _buildOrderDetails(currentOrder),

            SizedBox(height: 24.h),

            // Action buttons
            _buildActionButtons(paymentStatus),

            SizedBox(height: 20.h),
          ],
        ),
      );
    });
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        icon = Iconsax.tick_circle;
        color = AppColors.success;
        break;
      case 'pending':
        icon = Iconsax.clock;
        color = Colors.orange;
        break;
      case 'failed':
      case 'error':
        icon = Iconsax.close_circle;
        color = Colors.red;
        break;
      case 'processing':
        icon = Iconsax.refresh;
        color = AppColors.primary;
        break;
      default:
        icon = Iconsax.info_circle;
        color = AppColors.primary;
    }

    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 40.sp,
      ),
    );
  }

  Widget _buildStatusMessage(String status) {
    String title;
    String subtitle;
    Color titleColor;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        title = 'Order Confirmed!';
        subtitle =
            'Thank you for your purchase. Your order has been successfully placed and payment confirmed.';
        titleColor = AppColors.success;
        break;
      case 'pending':
        title = 'Payment Pending';
        subtitle =
            'Your order has been placed but payment is still being processed. You will receive a confirmation once payment is complete.';
        titleColor = Colors.orange;
        break;
      case 'failed':
      case 'error':
        title = 'Payment Failed';
        subtitle =
            'We encountered an issue processing your payment. Please try again or use a different payment method.';
        titleColor = Colors.red;
        break;
      case 'processing':
        title = 'Processing Payment';
        subtitle =
            'We are currently processing your payment. This may take a few moments.';
        titleColor = AppColors.primary;
        break;
      default:
        title = 'Order Status';
        subtitle = 'Please check your order status below.';
        titleColor = AppColors.primary;
    }

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(dynamic order) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.receipt_edit,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Order Details',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _buildDetailRow('Order ID', order.id ?? 'N/A'),
          _buildDetailRow('Order Date', _formatDate(order.createdAt)),
          _buildDetailRow(
              'Total Amount', '${order.totalAmount.toStringAsFixed(0)} TSh'),
          _buildDetailRow('Payment Method',
              controller.selectedPaymentMethod.value?.name ?? 'N/A'),
          _buildDetailRow('Status', order.status?.toString().split('.').last ?? 'Unknown'),

          SizedBox(height: 16.h),

          // Shipping address
          if (controller.shippingAddress.value != null) ...[
            Text(
              'Shipping Address',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                controller.shippingAddress.value!.formattedAddress,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    return Column(
      children: [
        // Primary action button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _getPrimaryAction(status),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getPrimaryButtonColor(status),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              _getPrimaryButtonText(status),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // Secondary action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _goToOrders(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'View Orders',
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
              child: OutlinedButton(
                onPressed: () => _continueShopping(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.textSecondary),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Continue Shopping',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Show retry button for failed payments
        if (status.toLowerCase() == 'failed' ||
            status.toLowerCase() == 'error') ...[
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _retryPayment(),
              child: Text(
                'Try Different Payment Method',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  VoidCallback? _getPrimaryAction(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return () => _goToOrders();
      case 'pending':
        return () => _checkPaymentStatus();
      case 'failed':
      case 'error':
        return () => _retryPayment();
      case 'processing':
        return () => _checkPaymentStatus();
      default:
        return () => _goToOrders();
    }
  }

  Color _getPrimaryButtonColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return AppColors.success;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'error':
        return Colors.red;
      case 'processing':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  String _getPrimaryButtonText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return 'View Order Details';
      case 'pending':
        return 'Check Payment Status';
      case 'failed':
      case 'error':
        return 'Retry Payment';
      case 'processing':
        return 'Check Status';
      default:
        return 'View Orders';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _goToOrders() {
    // Navigate to orders page
    Get.offAllNamed('/orders');
  }

  void _continueShopping() {
    // Reset checkout and go back to home
    controller.resetCheckout();
    Get.offAllNamed('/main');
  }

  void _retryPayment() {
    // Go back to payment step
    controller.goToStepByIndex(5); // Payment step
  }

  void _checkPaymentStatus() {
    // Refresh payment status
    controller.checkPaymentStatus();
  }
}
