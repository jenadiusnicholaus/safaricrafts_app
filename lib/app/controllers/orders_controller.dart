import 'package:get/get.dart';
import '../data/services/checkout/checkout_api_service.dart';
import '../controllers/checkout_controller.dart';
import '../routes/app_routes.dart';

class OrdersController extends GetxController {
  final CheckoutApiService _checkoutApiService = CheckoutApiService();

  // Observables
  final isLoading = false.obs;
  final orders = <Map<String, dynamic>>[].obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  // Fetch all user orders
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      error.value = null;

      final ordersData = await _checkoutApiService.getUserOrders(limit: 100);
      orders.value =
          List<Map<String, dynamic>>.from(ordersData['results'] ?? []);

      print('📋 Fetched ${orders.length} orders');
    } catch (e) {
      error.value = 'Failed to fetch orders: $e';
      print('❌ Error fetching orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get order status color
  String getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FF9800'; // Orange
      case 'confirmed':
        return '#2196F3'; // Blue
      case 'processing':
        return '#9C27B0'; // Purple
      case 'shipped':
        return '#00BCD4'; // Cyan
      case 'delivered':
        return '#4CAF50'; // Green
      case 'completed':
        return '#4CAF50'; // Green
      case 'cancelled':
        return '#F44336'; // Red
      case 'refunded':
        return '#FF5722'; // Deep Orange
      default:
        return '#757575'; // Grey
    }
  }

  // Get payment status color
  String getPaymentStatusColor(String? paymentStatus) {
    if (paymentStatus == null) return '#FF9800'; // Orange for pending

    switch (paymentStatus.toLowerCase()) {
      case 'pending':
        return '#FF9800'; // Orange
      case 'processing':
        return '#2196F3'; // Blue
      case 'completed':
      case 'paid':
        return '#4CAF50'; // Green
      case 'failed':
        return '#F44336'; // Red
      case 'cancelled':
        return '#757575'; // Grey
      default:
        return '#FF9800'; // Orange
    }
  }

  // Check if order can be continued (incomplete)
  bool canContinueOrder(Map<String, dynamic> order) {
    final status = order['status']?.toString().toLowerCase();
    final paymentStatus = order['payment_status']?.toString().toLowerCase();

    // Order can be continued if it's pending and payment is not completed
    return status == 'pending' &&
        (paymentStatus == null ||
            paymentStatus == 'pending' ||
            paymentStatus == 'failed');
  }

  // Continue checkout for an order
  Future<void> continueCheckout(String orderId) async {
    try {
      print('🔄 Starting checkout continuation for order: $orderId');
      
      // Check if CheckoutController is registered
      if (!Get.isRegistered<CheckoutController>()) {
        print('❌ CheckoutController not registered, creating new instance');
        Get.put<CheckoutController>(CheckoutController());
      }
      
      // Get checkout controller
      final checkoutController = Get.find<CheckoutController>();
      print('✅ CheckoutController found');

      // Resume checkout for this order
      print('🔄 Resuming checkout for order: $orderId');
      await checkoutController.resumeCheckoutForOrder(orderId);
      print('✅ Checkout resumed successfully');

      // Navigate to checkout
      print('🔄 Navigating to checkout page');
      Get.toNamed(AppRoutes.checkout);
      print('✅ Navigation completed');
      
    } catch (e, s) {
      print('❌ Error in continueCheckout: $e');
      print('❌ Stack trace: $s');
      Get.snackbar(
        'Error',
        'Failed to continue checkout: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // View order details
  void viewOrderDetails(String orderId) {
    Get.toNamed(AppRoutes.orderDetails, arguments: {'orderId': orderId});
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await fetchOrders();
  }
}
