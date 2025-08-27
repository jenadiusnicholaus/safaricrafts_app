import 'package:get/get.dart';

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxInt cartItemCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _updateCartCount();
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void _updateCartCount() {
    // This would be connected to your cart controller
    // For now, using a placeholder
    cartItemCount.value = 0;
  }

  void updateCartCount(int count) {
    cartItemCount.value = count;
  }
}
