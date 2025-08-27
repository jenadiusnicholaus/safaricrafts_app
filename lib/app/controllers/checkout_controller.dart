import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/checkout/address_model.dart';
import '../data/models/checkout/shipping_method_model.dart';
import '../data/models/checkout/payment_method_model.dart';
import '../data/models/checkout/order_model.dart';
import '../data/services/checkout/checkout_api_service.dart';
import '../core/theme/app_colors.dart';
import 'cart_controller.dart';

enum CheckoutStep {
  shippingAddress,
  shippingMethod,
  billingAddress,
  paymentMethod,
  orderReview,
  payment,
  confirmation,
}

class CheckoutController extends GetxController {
  late CheckoutApiService _checkoutApiService;
  late CartController _cartController;

  // Observable properties
  final currentStep = CheckoutStep.shippingAddress.obs;
  final isLoading = false.obs;
  final error = RxnString();

  // Checkout data
  final shippingAddress = Rxn<AddressModel>();
  final billingAddress = Rxn<AddressModel>();
  final selectedShippingMethod = Rxn<ShippingMethodModel>();
  final selectedPaymentMethod = Rxn<PaymentMethodModel>();
  final currentOrder = Rxn<OrderModel>();
  final sameAsShipping = true.obs;

  // Available options
  final availableShippingMethods = <ShippingMethodModel>[].obs;
  final availablePaymentMethods = <PaymentMethodModel>[].obs;

  // Payment processing
  final paymentInProgress = false.obs;
  final paymentCompleted = false.obs;
  final paymentError = RxnString();
  final paymentStatus = 'pending'.obs;

  // Observable for order creation
  final isCreatingOrder = false.obs;

  // Additional observables for payment processing
  final isProcessingPayment = false.obs;
  final selectedMobileMoneyMethod = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _checkoutApiService = CheckoutApiService();
    _cartController = Get.find<CartController>();

    print('🛒 CheckoutController initialized');
  }

  @override
  void onReady() {
    super.onReady();
    // Load initial data if needed
    loadPaymentMethods();
  }

  // Navigation methods
  void goToStep(CheckoutStep step) {
    currentStep.value = step;
    error.value = null;
  }

  void nextStep() {
    final steps = CheckoutStep.values;
    final currentIndex = steps.indexOf(currentStep.value);
    if (currentIndex < steps.length - 1) {
      currentStep.value = steps[currentIndex + 1];
    }
  }

  void previousStep() {
    final steps = CheckoutStep.values;
    final currentIndex = steps.indexOf(currentStep.value);
    if (currentIndex > 0) {
      currentStep.value = steps[currentIndex - 1];
    }
  }

  // Address methods
  void setShippingAddress(AddressModel address) {
    shippingAddress.value = address;

    // If same as shipping is enabled, copy to billing address
    if (sameAsShipping.value) {
      billingAddress.value = address;
    }

    // Clear previous shipping methods when address changes
    availableShippingMethods.clear();
    selectedShippingMethod.value = null;

    print('📍 Shipping address set: ${address.city}, ${address.country}');
  }

  void setBillingAddress(AddressModel address) {
    billingAddress.value = address;
    print('📍 Billing address set: ${address.city}, ${address.country}');
  }

  void toggleSameAsShipping(bool value) {
    sameAsShipping.value = value;
    if (value && shippingAddress.value != null) {
      billingAddress.value = shippingAddress.value;
    } else if (!value) {
      billingAddress.value = null;
    }
  }

  // Shipping methods
  Future<void> loadShippingMethods() async {
    if (shippingAddress.value == null) {
      error.value = 'Please set shipping address first';
      return;
    }

    try {
      isLoading.value = true;
      error.value = null;

      // Calculate total weight from cart (simplified - you might want to add weight to artwork model)
      final cartWeight = (_cartController.cart.value?.items.length ?? 0) *
          0.5; // 0.5kg per item assumption

      final methods = await _checkoutApiService.getShippingMethods(
        country: shippingAddress.value!.country,
        weight: cartWeight,
      );

      availableShippingMethods.value = methods;

      // Auto-select first available method
      if (methods.isNotEmpty) {
        selectedShippingMethod.value = methods.first;
      }

      print('🚚 Loaded ${methods.length} shipping methods');
    } catch (e) {
      error.value = e.toString();
      print('❌ Error loading shipping methods: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectShippingMethod(ShippingMethodModel method) {
    selectedShippingMethod.value = method;
    print(
        '🚚 Selected shipping method: ${method.name} - ${method.formattedCost}');
  }

  // Payment methods
  Future<void> loadPaymentMethods() async {
    try {
      isLoading.value = true;
      error.value = null;

      final methods = await _checkoutApiService.getPaymentMethods();
      availablePaymentMethods.value = methods;

      print('💳 Loaded ${methods.length} payment methods');
    } catch (e) {
      error.value = e.toString();
      print('❌ Error loading payment methods: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectPaymentMethod(PaymentMethodModel method) {
    selectedPaymentMethod.value = method;
    print('💳 Selected payment method: ${method.displayName}');
  }

  // Order creation
  Future<void> createOrder() async {
    if (!_validateOrderData()) {
      return;
    }

    try {
      isLoading.value = true;
      error.value = null;

      final order = await _checkoutApiService.createOrder(
        shippingAddress: shippingAddress.value!,
        billingAddress: billingAddress.value!,
        shippingMethodId: selectedShippingMethod.value!.id.toString(),
        customerNotes: '', // You can add a notes field later
        sameAsShipping: sameAsShipping.value,
      );

      currentOrder.value = order;
      goToStep(CheckoutStep.payment);

      print('📦 Order created: ${order.orderNumber}');
    } catch (e) {
      error.value = e.toString();
      print('❌ Error creating order: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Payment processing
  Future<void> processPayment() async {
    if (currentOrder.value == null || selectedPaymentMethod.value == null) {
      error.value = 'Missing order or payment method';
      return;
    }

    try {
      paymentInProgress.value = true;
      paymentError.value = null;

      final paymentMethod = selectedPaymentMethod.value!;
      final order = currentOrder.value!;

      if (paymentMethod.isMobilePayment) {
        await _processMobilePayment(order.id, paymentMethod);
      } else if (paymentMethod.isPayPal) {
        await _processPayPalPayment(order.id, paymentMethod);
      } else {
        throw Exception('Unsupported payment method: ${paymentMethod.method}');
      }
    } catch (e) {
      paymentError.value = e.toString();
      print('❌ Error processing payment: $e');
    } finally {
      paymentInProgress.value = false;
    }
  }

  Future<void> _processMobilePayment(
      String orderId, PaymentMethodModel paymentMethod) async {
    // Get phone number from user
    final phoneNumber = await _getPhoneNumberFromUser();
    if (phoneNumber == null || phoneNumber.isEmpty) {
      throw Exception('Phone number is required for mobile payment');
    }

    final response = await _checkoutApiService.processMobilePayment(
      orderId: orderId,
      paymentMethod: paymentMethod,
      phoneNumber: phoneNumber,
    );

    // Show payment instructions to user
    Get.snackbar(
      'Payment Instructions',
      response['message'] ??
          'Please check your phone and enter your PIN to complete payment',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 10),
    );

    // Start polling for payment status
    _startPaymentStatusPolling(response['payment_id']);
  }

  Future<void> _processPayPalPayment(
      String orderId, PaymentMethodModel paymentMethod) async {
    final response = await _checkoutApiService.initializePayment(
      orderId: orderId,
      paymentMethod: paymentMethod,
      returnUrl: 'safaricrafts://payment/success',
      cancelUrl: 'safaricrafts://payment/cancel',
    );

    // Open PayPal URL in browser
    final paymentUrl = response['payment_url'];
    if (paymentUrl != null) {
      // In a real app, you'd open this in a web view or external browser
      Get.snackbar(
        'Redirecting to PayPal',
        'You will be redirected to PayPal to complete your payment',
        snackPosition: SnackPosition.BOTTOM,
      );

      // For now, just start polling (in real implementation, handle the return URL)
      _startPaymentStatusPolling(response['payment_id']);
    }
  }

  void _startPaymentStatusPolling(String paymentId) {
    // Poll every 3 seconds for payment status
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final status = await _checkoutApiService.checkPaymentStatus(paymentId);

        if (status['status'] == 'completed') {
          timer.cancel();
          paymentCompleted.value = true;
          goToStep(CheckoutStep.confirmation);

          // Clear cart after successful payment
          await _cartController.clearCart();

          Get.snackbar(
            'Payment Successful!',
            'Your order has been confirmed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else if (status['status'] == 'failed') {
          timer.cancel();
          paymentError.value = status['failure_reason'] ?? 'Payment failed';
        }
      } catch (e) {
        // Continue polling on error
        print('Error checking payment status: $e');
      }
    });

    // Stop polling after 10 minutes
    Timer(const Duration(minutes: 10), () {
      if (paymentInProgress.value) {
        paymentError.value = 'Payment timeout. Please check your order status.';
        paymentInProgress.value = false;
      }
    });
  }

  Future<String?> _getPhoneNumberFromUser() async {
    // This should show a dialog to get phone number from user
    // For now, return a placeholder - you'll need to implement the dialog
    return Get.dialog<String>(
      AlertDialog(
        title: const Text('Enter Phone Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your phone number for mobile payment:'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                hintText: '+255712345678',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) => Get.back(result: value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: '+255712345678'), // Placeholder
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // Validation
  bool _validateOrderData() {
    if (shippingAddress.value == null) {
      error.value = 'Please set shipping address';
      return false;
    }

    if (billingAddress.value == null) {
      error.value = 'Please set billing address';
      return false;
    }

    if (selectedShippingMethod.value == null) {
      error.value = 'Please select shipping method';
      return false;
    }

    if (selectedPaymentMethod.value == null) {
      error.value = 'Please select payment method';
      return false;
    }

    if (_cartController.cart.value?.items.isEmpty ?? true) {
      error.value = 'Cart is empty';
      return false;
    }

    return true;
  }

  // Helper methods
  double get cartTotal {
    final items = _cartController.cart.value?.items ?? [];
    return items.fold(
        0.0, (sum, item) => sum + (item.artwork.price * item.quantity));
  }

  double get shippingCost {
    return selectedShippingMethod.value?.calculatedCost ?? 0.0;
  }

  double get totalAmount {
    return cartTotal + shippingCost;
  }

  // Mobile money method selection
  void selectMobileMoneyMethod(String method) {
    selectedMobileMoneyMethod.value = method;
    print('📱 Mobile money method selected: $method');
  }

  // Payment processing methods
  Future<void> processMobilePayment(String phoneNumber, String method) async {
    if (currentOrder.value == null || selectedPaymentMethod.value == null) {
      error.value = 'Order or payment method not found';
      return;
    }

    try {
      isProcessingPayment.value = true;
      error.value = null;

      print('📱 Processing mobile payment: $method for $phoneNumber');

      final paymentResult = await _checkoutApiService.processMobilePayment(
        orderId: currentOrder.value!.id,
        paymentMethod: selectedPaymentMethod.value!,
        phoneNumber: phoneNumber,
      );

      if (paymentResult['success'] == true) {
        paymentStatus.value = paymentResult['status'] ?? 'pending';

        // Start polling for payment status
        if (paymentStatus.value == 'pending') {
          _startPaymentStatusPolling(paymentResult['payment_id'] ?? '');
        }

        nextStep(); // Go to confirmation

        Get.snackbar(
          'Payment Initiated',
          'Please complete the payment on your mobile device',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        error.value = paymentResult['message'] ?? 'Payment failed';
        paymentStatus.value = 'failed';
      }
    } catch (e) {
      error.value = 'Failed to process payment: $e';
      paymentStatus.value = 'failed';
      print('❌ Mobile payment error: $e');
    } finally {
      isProcessingPayment.value = false;
    }
  }

  Future<void> processPayPalPayment() async {
    if (currentOrder.value == null || selectedPaymentMethod.value == null) {
      error.value = 'Order or payment method not found';
      return;
    }

    try {
      isProcessingPayment.value = true;
      error.value = null;

      print('💳 Processing PayPal payment');

      final paymentResult = await _checkoutApiService.initializePayment(
        orderId: currentOrder.value!.id,
        paymentMethod: selectedPaymentMethod.value!,
        returnUrl: 'safaricrafts://payment/success',
        cancelUrl: 'safaricrafts://payment/cancel',
      );

      if (paymentResult['success'] == true) {
        final paymentUrl = paymentResult['payment_url'];
        if (paymentUrl != null) {
          // Open PayPal payment URL (you might want to use url_launcher)
          // For now, we'll simulate the process
          paymentStatus.value = 'processing';
          nextStep(); // Go to confirmation

          // Simulate payment processing
          await Future.delayed(Duration(seconds: 3));
          paymentStatus.value = 'completed';

          Get.snackbar(
            'Payment Processing',
            'Redirecting to PayPal...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primary,
            colorText: Colors.white,
          );
        }
      } else {
        error.value = paymentResult['message'] ?? 'PayPal payment failed';
        paymentStatus.value = 'failed';
      }
    } catch (e) {
      error.value = 'Failed to process PayPal payment: $e';
      paymentStatus.value = 'failed';
      print('❌ PayPal payment error: $e');
    } finally {
      isProcessingPayment.value = false;
    }
  }

  Future<void> processGenericPayment() async {
    if (currentOrder.value == null || selectedPaymentMethod.value == null) {
      error.value = 'Order or payment method not found';
      return;
    }

    try {
      isProcessingPayment.value = true;
      error.value = null;

      print('💳 Processing generic payment');

      final paymentResult = await _checkoutApiService.initializePayment(
        orderId: currentOrder.value!.id,
        paymentMethod: selectedPaymentMethod.value!,
      );

      if (paymentResult['success'] == true) {
        paymentStatus.value = paymentResult['status'] ?? 'processing';
        nextStep(); // Go to confirmation

        // Simulate payment processing
        await Future.delayed(Duration(seconds: 2));
        paymentStatus.value = 'completed';

        Get.snackbar(
          'Payment Processed',
          'Your payment has been processed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        error.value = paymentResult['message'] ?? 'Payment failed';
        paymentStatus.value = 'failed';
      }
    } catch (e) {
      error.value = 'Failed to process payment: $e';
      paymentStatus.value = 'failed';
      print('❌ Generic payment error: $e');
    } finally {
      isProcessingPayment.value = false;
    }
  }

  Future<void> checkPaymentStatus() async {
    if (currentOrder.value == null) return;

    try {
      isLoading.value = true;

      final status = await _checkoutApiService.checkPaymentStatus(
        currentOrder.value!.id,
      );

      paymentStatus.value = status['status'] ?? 'unknown';

      if (paymentStatus.value == 'completed') {
        paymentCompleted.value = true;
        Get.snackbar(
          'Payment Confirmed',
          'Your payment has been confirmed!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error checking payment status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void goToStepByIndex(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < CheckoutStep.values.length) {
      currentStep.value = CheckoutStep.values[stepIndex];
    }
  }

  String get formattedCartTotal {
    return 'TZS ${cartTotal.toStringAsFixed(0)}';
  }

  String get formattedShippingCost {
    return 'TZS ${shippingCost.toStringAsFixed(0)}';
  }

  String get formattedTotalAmount {
    return 'TZS ${totalAmount.toStringAsFixed(0)}';
  }

  void resetCheckout() {
    currentStep.value = CheckoutStep.shippingAddress;
    isLoading.value = false;
    error.value = null;
    shippingAddress.value = null;
    billingAddress.value = null;
    selectedShippingMethod.value = null;
    selectedPaymentMethod.value = null;
    currentOrder.value = null;
    sameAsShipping.value = true;
    availableShippingMethods.clear();
    paymentInProgress.value = false;
    paymentCompleted.value = false;
    paymentError.value = null;

    print('🔄 Checkout reset');
  }

  @override
  void onClose() {
    // Clean up any timers or listeners
    super.onClose();
  }
}
