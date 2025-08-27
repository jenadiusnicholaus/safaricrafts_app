import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/flying_cart_animation_service.dart';

class CartAnimationController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController _cartBounceController;
  late Animation<double> _cartBounceAnimation;

  final RxBool isAnimating = false.obs;
  final RxDouble cartBadgeScale = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _cartBounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cartBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(CurvedAnimation(
      parent: _cartBounceController,
      curve: Curves.elasticOut,
    ));

    _cartBounceAnimation.addListener(() {
      cartBadgeScale.value = _cartBounceAnimation.value;
    });
  }

  /// Triggers the flying cart animation and cart icon bounce
  void triggerAddToCartAnimation({
    required BuildContext context,
    required GlobalKey sourceKey,
    required GlobalKey cartKey,
    required String imageUrl,
    VoidCallback? onComplete,
  }) {
    if (isAnimating.value) return;

    isAnimating.value = true;

    final flyingService = Get.find<FlyingCartAnimationService>();

    flyingService.startFlyingAnimation(
      context: context,
      sourceKey: sourceKey,
      targetKey: cartKey,
      imageUrl: imageUrl,
      onAnimationComplete: () {
        _bounceCartIcon();
        _showSuccessEffect();
        isAnimating.value = false;
        onComplete?.call();
      },
    );
  }

  void _bounceCartIcon() {
    _cartBounceController.forward().then((_) {
      _cartBounceController.reverse();
    });
  }

  void _showSuccessEffect() {
    Get.snackbar(
      '✅ Added to Cart',
      'Item successfully added to your cart',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      animationDuration: const Duration(milliseconds: 500),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
    );
  }

  /// Quick pulse animation for immediate feedback
  void pulseCartIcon() {
    _cartBounceController.forward(from: 0).then((_) {
      _cartBounceController.reverse();
    });
  }

  @override
  void onClose() {
    _cartBounceController.dispose();
    super.onClose();
  }
}
