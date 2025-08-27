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
            final hasItems = controller.isGuest
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
        final isCartEmpty = controller.isGuest
            ? controller.localCart.isEmpty
            : controller.cart.value?.items.isEmpty == true;

        if (isCartEmpty) {
          return _buildEmptyCart();
        }

        return Column(
          children: [
            // Guest Mode Banner
            Obx(() {
              if (controller.isGuest) {
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
                itemCount: controller.isGuest
                    ? controller.localCart.length
                    : controller.cart.value?.items.length ?? 0,
                itemBuilder: (context, index) {
                  if (controller.isGuest) {
                    // Local cart item
                    final item = controller.localCart[index];
                    return LocalCartItemCard(
                      cartItem: item,
                      index: index,
                      onQuantityChanged: (quantity) => controller
                          .updateLocalItemQuantity(item.artworkId, quantity),
                      onRemove: () => controller.removeFromCart(item.artworkId),
                    );
                  } else {
                    // Server cart item
                    final item = controller.cart.value!.items[index];
                    return CartItemCard(
                      cartItem: item,
                      onQuantityChanged: (quantity) =>
                          controller.updateCartItemQuantity(item.id, quantity),
                      onRemove: () => controller.removeFromCart(item.id),
                    );
                  }
                },
              ),
            ),

            // Cart Summary
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Subtotal
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
                        controller.formatPrice(
                            controller.subtotal, controller.cartCurrency),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Tax
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tax (10%)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        controller.formatPrice(
                            controller.tax, controller.cartCurrency),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  Divider(height: 20.h),

                  // Total
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
                        controller.formatPrice(
                            controller.total, controller.cartCurrency),
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
                      onPressed: () {
                        final checkoutData = controller.prepareForCheckout();
                        if (checkoutData.isNotEmpty) {
                          // Only navigate if we have checkout data
                          Get.toNamed(AppRoutes.checkout,
                              arguments: checkoutData);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
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
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.shopping_cart,
            size: 80.sp,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 24.h),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add some artworks to get started',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 32.w,
                vertical: 12.h,
              ),
            ),
            child: Text(
              'Continue Shopping',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Clear Cart',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all items from your cart?',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.clearCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(
              'Clear',
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
}
