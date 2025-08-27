import 'package:get/get.dart';
import '../../controllers/checkout_controller.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    // Register CheckoutController
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}
