import 'package:get/get.dart';
import 'cart_controller.dart';

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxInt cartItemCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupCartListener();
  }

  @override
  void onReady() {
    super.onReady();
    // Ensure cart listener is set up when all controllers are ready
    _setupCartListener();
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void _setupCartListener() {
    try {
      final cartController = Get.find<CartController>();

      // Listen to local cart changes (for guest users)
      ever(cartController.localCart, (_) {
        _updateCartCount();
      });

      // Listen to authenticated cart changes
      ever(cartController.cart, (_) {
        _updateCartCount();
      });

      // Initial count update
      _updateCartCount();
    } catch (e) {
      print('CartController not found in MainController: $e');
      cartItemCount.value = 0;

      // Retry after a delay
      Future.delayed(Duration(milliseconds: 500), () {
        _setupCartListener();
      });
    }
  }

  void _updateCartCount() {
    try {
      final cartController = Get.find<CartController>();
      cartItemCount.value = cartController.itemCount;
    } catch (e) {
      cartItemCount.value = 0;
    }
  }

  void updateCartCount(int count) {
    cartItemCount.value = count;
  }

  // Method to manually refresh cart count
  void refreshCartCount() {
    _updateCartCount();
  }
}
