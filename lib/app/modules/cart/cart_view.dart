import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/cart_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/local_cart_item_card.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          Obx(() {
            final hasItems =
                controller.isGuest.value || !controller.isLoading.value
                    ? controller.localCart.isNotEmpty
                    : controller.cart.value?.items.isNotEmpty == true;

            return hasItems
                ? IconButton(
                    onPressed: () => _showClearCartDialog(context),
                    icon: Icon(
                      Iconsax.trash,
                      color: AppColors.error,
                      size: 24.sp,
                    ),
                  )
                : const SizedBox();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Check if cart is empty (both local and server)
        final isCartEmpty = controller.isGuest.value
            ? controller.localCart.isEmpty
            : (controller.cart.value?.items.isEmpty ?? true);

        if (isCartEmpty) {
          return _buildEmptyCart();
        }

        return Column(
          children: [
            // Guest Mode Banner
            Obx(() {
              if (controller.isGuest.value) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  margin: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.info_circle,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Guest Mode: Your cart will be saved locally. Login to sync across devices.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Cart Items
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: controller.isGuest.value
                    ? controller.localCart.length
                    : controller.cart.value!.items.length,
                itemBuilder: (context, index) {
                  if (controller.isGuest.value) {
                    // Local cart item
                    final item = controller.localCart[index];
                    return LocalCartItemCard(
                      cartItem: item,
                      index: index,
                      onQuantityChanged: (quantity) =>
                          controller.updateItemQuantity(index, quantity),
                      onRemove: () => controller.removeFromCart(index),
                    );
                  } else {
                    // Server cart item
                    final item = controller.cart.value!.items[index];
                    return CartItemCard(
                      cartItem: item,
                      onQuantityChanged: (quantity) =>
                          controller.updateItemQuantity(item.id, quantity),
                      onRemove: () => controller.removeFromCart(item.id),
                    );
                  }
                },
              ),
            ),

            // Bottom Summary
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Price Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '\$${controller.subtotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16.sp,
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
                          'Shipping',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Free',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '\$${controller.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Checkout Button
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          final canProceed =
                              await controller.prepareForCheckout();
                          if (canProceed) {
                            // Only navigate if user is already authenticated
                            // If not authenticated, prepareForCheckout handles the redirect
                            Get.toNamed(AppRoutes.checkout);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.shopping_cart,
                size: 60.sp,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Looks like you haven\'t added any artworks to your cart yet',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.artworks),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Start Shopping',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
            'Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.clearCart();
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
