import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:async';
import '../data/models/checkout/address_model.dart';
import '../data/models/checkout/shipping_method_model.dart';
import '../data/models/checkout/payment_method_model.dart';
import '../data/models/checkout/order_model.dart';
import '../data/services/checkout/checkout_api_service.dart';
import '../core/theme/app_colors.dart';
import 'cart_controller.dart';

enum CheckoutStep {
  addressAndShipping,
  paymentAndReview,
  confirmation,
}

class CheckoutController extends GetxController {
  late CheckoutApiService _checkoutApiService;
  late CartController _cartController;

  // Observable properties
  final currentStep = CheckoutStep.addressAndShipping.obs;
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

  // Mobile payment phone number
  final mobilePaymentPhoneNumber = ''.obs;

  // Observable for order creation
  final isCreatingOrder = false.obs;

  // Observable for user orders
  final isLoadingOrders = false.obs;
  final userOrders = <Map<String, dynamic>>[].obs;

  // Additional observables for payment processing
  final isProcessingPayment = false.obs;
  final selectedMobileMoneyMethod = Rxn<String>();

  // Payment details
  final phoneNumber = ''.obs;
  final bankAccountNumber = ''.obs;
  final bankName = ''.obs;
  final otpCode = ''.obs;
  final paymentInstructions = ''.obs;
  final paymentReference = ''.obs;
  final paymentTimeRemaining = 300.obs; // 5 minutes
  final showOtpInput = false.obs;

  // Address simplification
  final quickAddressMode = true.obs;
  final savedAddresses = <AddressModel>[].obs;

  // Form field observables for reactive UI
  final formFullName = ''.obs;
  final formPhone = ''.obs;
  final formAddress = ''.obs;
  final formCity = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkoutApiService = CheckoutApiService();
    _cartController = Get.find<CartController>();
    loadShippingMethods();
    loadPaymentMethods();
    // Automatically fetch user orders on initialization
    fetchUserOrders();

    print('🛒 CheckoutController initialized');
  }

  @override
  void onReady() {
    super.onReady();
    // Load initial data if needed
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

      final OrderModel order = await _checkoutApiService.createOrder(
        shippingAddress: shippingAddress.value!,
        billingAddress: billingAddress.value!,
        shippingMethodId: selectedShippingMethod.value!.id,
        customerNotes: '', // You can add a notes field later
        sameAsShipping: sameAsShipping.value,
      );

      currentOrder.value = order;
      goToStep(CheckoutStep.confirmation);

      print('📦 Order created: ${order.orderNumber}');
    } catch (e, s) {
      error.value = e.toString();
      print('❌ Error creating order: $e');
      print(s);
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
    // Get phone number for mobile payments
    String? phoneNumber;
    if (paymentMethod.isMobilePayment) {
      // Use mobile payment phone number if provided, otherwise fall back to shipping address
      phoneNumber = mobilePaymentPhoneNumber.value.isNotEmpty
          ? mobilePaymentPhoneNumber.value
          : shippingAddress.value?.phone;

      // Validate phone number for mobile payments
      if (phoneNumber == null || phoneNumber.isEmpty) {
        throw Exception(
            'Phone number is required for mobile money payments. Please enter your mobile money phone number.');
      }

      // Ensure phone number is in correct format (starts with +255 for Tanzania)
      if (!phoneNumber.startsWith('+')) {
        if (phoneNumber.startsWith('0')) {
          phoneNumber = '+255${phoneNumber.substring(1)}';
        } else if (phoneNumber.startsWith('255')) {
          phoneNumber = '+$phoneNumber';
        } else {
          phoneNumber = '+255$phoneNumber';
        }
      }
    }

    final response = await _checkoutApiService.initializePayment(
      orderId: orderId,
      paymentMethod: paymentMethod,
      phoneNumber: phoneNumber,
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

      // Get phone number for mobile payments
      String? phoneNumber;
      if (selectedPaymentMethod.value!.isMobilePayment) {
        phoneNumber = shippingAddress.value?.phone;

        // Validate phone number for mobile payments
        if (phoneNumber == null || phoneNumber.isEmpty) {
          throw Exception(
              'Phone number is required for mobile money payments. Please update your shipping address.');
        }

        // Ensure phone number is in correct format (starts with +255 for Tanzania)
        if (!phoneNumber.startsWith('+')) {
          if (phoneNumber.startsWith('0')) {
            phoneNumber = '+255${phoneNumber.substring(1)}';
          } else if (phoneNumber.startsWith('255')) {
            phoneNumber = '+$phoneNumber';
          } else {
            phoneNumber = '+255$phoneNumber';
          }
        }
      }

      final paymentResult = await _checkoutApiService.initializePayment(
        orderId: currentOrder.value!.id,
        paymentMethod: selectedPaymentMethod.value!,
        phoneNumber: phoneNumber,
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

      // Get phone number for mobile payments
      String? phoneNumber;
      if (selectedPaymentMethod.value!.isMobilePayment) {
        phoneNumber = shippingAddress.value?.phone;

        // Validate phone number for mobile payments
        if (phoneNumber == null || phoneNumber.isEmpty) {
          throw Exception(
              'Phone number is required for mobile money payments. Please update your shipping address.');
        }

        // Ensure phone number is in correct format (starts with +255 for Tanzania)
        if (!phoneNumber.startsWith('+')) {
          if (phoneNumber.startsWith('0')) {
            phoneNumber = '+255${phoneNumber.substring(1)}';
          } else if (phoneNumber.startsWith('255')) {
            phoneNumber = '+$phoneNumber';
          } else {
            phoneNumber = '+255$phoneNumber';
          }
        }
      }

      final paymentResult = await _checkoutApiService.initializePayment(
        orderId: currentOrder.value!.id,
        paymentMethod: selectedPaymentMethod.value!,
        phoneNumber: phoneNumber,
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
    currentStep.value = CheckoutStep.addressAndShipping;
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

  // Enhanced payment methods with streamlined flow
  // Format phone number to international format
  String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('0')) {
      cleaned = '255' + cleaned.substring(1);
    }
    return '+' + cleaned;
  }

  // Enhanced payment status polling with real-time updates
  void _startEnhancedPaymentStatusPolling(String paymentId) {
    int attempts = 0;
    const maxAttempts = 60; // 5 minutes with 5-second intervals
    const interval = Duration(seconds: 5);

    Timer.periodic(interval, (timer) async {
      attempts++;

      try {
        final status = await _checkoutApiService.checkPaymentStatus(paymentId);
        final currentStatus = status['status'];

        paymentStatus.value = currentStatus ?? 'unknown';

        if (currentStatus == 'completed') {
          timer.cancel();
          paymentCompleted.value = true;
          goToStep(CheckoutStep.confirmation);

          // Clear cart after successful payment
          await _cartController.clearCart();

          Get.snackbar(
            'Payment Successful!',
            'Your order has been confirmed. Receipt: ${status['provider_ref'] ?? ''}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            duration: const Duration(seconds: 10),
          );
        } else if (currentStatus == 'failed') {
          timer.cancel();
          final failureReason = status['failure_reason'] ?? 'Payment failed';
          final canRetry = status['retry_allowed'] ?? false;

          paymentError.value = failureReason;
          paymentStatus.value = 'failed';

          Get.snackbar(
            'Payment Failed',
            '$failureReason${canRetry ? ' - You can try again' : ''}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 8),
          );
        } else if (attempts >= maxAttempts) {
          timer.cancel();
          paymentError.value =
              'Payment is taking longer than expected. Please check your order status later.';

          Get.snackbar(
            'Payment Timeout',
            'Payment is taking longer than expected. Please check your order status.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print('Error checking payment status: $e');
        // Continue polling on error unless max attempts reached
        if (attempts >= maxAttempts) {
          timer.cancel();
          paymentError.value =
              'Unable to check payment status. Please contact support.';
        }
      }
    });
  }

  // Payment countdown timer
  void _startPaymentCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (paymentTimeRemaining.value > 0) {
        paymentTimeRemaining.value--;
      } else {
        timer.cancel();
      }

      // Stop countdown if payment is completed or failed
      if (['completed', 'failed'].contains(paymentStatus.value)) {
        timer.cancel();
      }
    });
  }

  // Utility methods
  AddressModel createQuickAddress({
    required String fullName,
    required String phone,
    required String address,
    required String city,
    String region = 'Dar es Salaam',
  }) {
    return AddressModel(
      firstName: fullName.split(' ').first,
      lastName: fullName.split(' ').length > 1
          ? fullName.split(' ').skip(1).join(' ')
          : '',
      phone: formatPhoneNumber(phone),
      addressLine1: address,
      addressLine2: '',
      city: city,
      region: region,
      postalCode: '',
      country: 'Tanzania',
    );
  }

  // Phone number validation
  bool isValidPhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('255')) {
      return cleanPhone.length == 12;
    } else if (cleanPhone.startsWith('0')) {
      return cleanPhone.length == 10;
    } else if (cleanPhone.length == 9) {
      return true;
    }
    return false;
  }

  // Set payment details
  void setPaymentDetails({
    String? phone,
    String? bank,
    String? bankAccount,
  }) {
    if (phone != null) phoneNumber.value = phone;
    if (bank != null) bankName.value = bank;
    if (bankAccount != null) bankAccountNumber.value = bankAccount;
  }

  // Complete address and shipping step
  void completeAddressAndShipping({
    required String fullName,
    required String phone,
    required String address,
    required String city,
    String region = 'Dar es Salaam',
    ShippingMethodModel? selectedShipping,
  }) {
    final quickAddress = createQuickAddress(
      fullName: fullName,
      phone: phone,
      address: address,
      city: city,
      region: region,
    );

    setShippingAddress(quickAddress);
    if (sameAsShipping.value) setBillingAddress(quickAddress);
    if (selectedShipping != null) selectShippingMethod(selectedShipping);
    goToStep(CheckoutStep.paymentAndReview);
  }

  // Complete payment and review step
  Future<void> completePaymentAndReview() async {
    try {
      isLoading.value = true;
      error.value = '';

      await createOrder();
      if (currentOrder.value == null) {
        error.value = 'Failed to create order';
        return;
      }

      goToStep(CheckoutStep.confirmation);

      final selectedMethod = selectedPaymentMethod.value;
      if (selectedMethod?.isMobilePayment == true) {
        await processEnhancedMobilePayment();
      } else if (selectedMethod?.isBankTransfer == true) {
        await requestBankOTP();
      } else if (selectedMethod?.isPayPal == true) {
        await processPayPalPayment();
      }
    } catch (e) {
      error.value = 'Failed to process payment: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Enhanced mobile payment processing
  Future<void> processEnhancedMobilePayment() async {
    print(phoneNumber.value);
    if (mobilePaymentPhoneNumber.value.isEmpty ||
        !isValidPhoneNumber(mobilePaymentPhoneNumber.value)) {
      error.value = 'Invalid phone number';
      return;
    }

    try {
      isProcessingPayment.value = true;
      paymentStatus.value = 'processing';

      // Get phone number for mobile payments
      String? phoneNumber;
      if (selectedPaymentMethod.value!.isMobilePayment) {
        // Use mobile payment phone number if provided, otherwise fall back to shipping address
        phoneNumber = mobilePaymentPhoneNumber.value.isNotEmpty
            ? mobilePaymentPhoneNumber.value
            : shippingAddress.value?.phone;

        // Validate phone number for mobile payments
        if (phoneNumber == null || phoneNumber.isEmpty) {
          throw Exception(
              'Phone number is required for mobile money payments. Please enter your mobile money phone number.');
        }

        // Ensure phone number is in correct format (starts with +255 for Tanzania)
        if (!phoneNumber.startsWith('+')) {
          if (phoneNumber.startsWith('0')) {
            phoneNumber = '+255${phoneNumber.substring(1)}';
          } else if (phoneNumber.startsWith('255')) {
            phoneNumber = '+$phoneNumber';
          } else {
            phoneNumber = '+255$phoneNumber';
          }
        }

        print('📱 Using phone number for mobile payment: $phoneNumber');
      }

      print('🚀 About to call initializePayment with:');
      print('🚀 - orderId: ${currentOrder.value?.id ?? ''}');
      print('🚀 - paymentMethod: ${selectedPaymentMethod.value!.toJson()}');
      print('🚀 - phoneNumber: $phoneNumber');

      final paymentResult = await _checkoutApiService.initializePayment(
        orderId: currentOrder.value?.id ?? '',
        paymentMethod: selectedPaymentMethod.value!,
        phoneNumber: phoneNumber,
      );

      print('🎯 Payment result received: $paymentResult');

      print('💳 Controller received payment result: $paymentResult');
      print('💳 Payment result type: ${paymentResult.runtimeType}');

      try {
        if (paymentResult['success'] == true) {
          _startPaymentCountdown();
          _startEnhancedPaymentStatusPolling(paymentResult['payment_id']);
        } else {
          paymentStatus.value = 'failed';
          error.value = paymentResult['message'] ?? 'Payment failed';
        }
      } catch (e) {
        print('💳 Error accessing payment result: $e');
        paymentStatus.value = 'failed';
        error.value = 'Payment initialization failed';
      }
    } catch (e) {
      paymentStatus.value = 'failed';
      error.value = 'Payment processing failed: $e';
    } finally {
      isProcessingPayment.value = false;
    }
  }

  // Request bank OTP
  Future<void> requestBankOTP() async {
    if (bankName.value.isEmpty || bankAccountNumber.value.isEmpty) {
      error.value = 'Please provide bank details';
      return;
    }

    try {
      isProcessingPayment.value = true;
      paymentStatus.value = 'otp_required';

      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'OTP Sent',
        'Please check your phone for the OTP code',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      paymentStatus.value = 'failed';
      error.value = 'Failed to request OTP: $e';
    } finally {
      isProcessingPayment.value = false;
    }
  }

  // Process bank payment with OTP
  Future<void> processBankPaymentWithOTP() async {
    void confirmOtp() async {
      if (otpCode.value.isEmpty) {
        error.value = 'Please enter OTP';
        return;
      }

      try {
        isProcessingPayment.value = true;
        paymentStatus.value = 'processing';

        await Future.delayed(const Duration(seconds: 3));

        final success = otpCode.value != '000000';

        if (success) {
          paymentStatus.value = 'completed';
          goToStep(CheckoutStep.confirmation);
        } else {
          paymentStatus.value = 'failed';
          error.value = 'Invalid OTP or payment failed';
        }
      } catch (e) {
        paymentStatus.value = 'failed';
        error.value = 'Payment processing failed: $e';
      } finally {
        isProcessingPayment.value = false;
      }
    }
  }

  // Fetch user orders
  Future<void> fetchUserOrders({String? status}) async {
    try {
      isLoadingOrders.value = true;
      error.value = null;

      final ordersData = await _checkoutApiService.getUserOrders(
        status: status,
        limit: 50,
      );

      userOrders.value =
          List<Map<String, dynamic>>.from(ordersData['results'] ?? []);
      print('📋 Fetched ${userOrders.length} orders');
    } catch (e) {
      error.value = 'Failed to fetch orders: $e';
      print('❌ Error fetching orders: $e');
    } finally {
      isLoadingOrders.value = false;
    }
  }

  // Determine which checkout step to navigate to based on order completion
  Future<CheckoutStep> determineCheckoutStep(String orderId) async {
    try {
      final completionStatus =
          await _checkoutApiService.getOrderCompletionStatus(orderId);

      print('🔍 Order completion status: $completionStatus');

      // If order is completed, go to confirmation
      if (completionStatus['is_completed'] == true) {
        return CheckoutStep.confirmation;
      }

      // If payment is missing or pending, go to payment step
      if (!completionStatus['has_payment_method'] ||
          completionStatus['payment_status'] == null ||
          completionStatus['payment_status'] == 'pending') {
        return CheckoutStep.paymentAndReview;
      }

      // If shipping address is missing, go to address step
      if (!completionStatus['has_shipping_address']) {
        return CheckoutStep.addressAndShipping;
      }

      // Default to confirmation if everything seems complete
      return CheckoutStep.confirmation;
    } catch (e) {
      print('❌ Error determining checkout step: $e');
      // Default to address step if we can't determine
      return CheckoutStep.addressAndShipping;
    }
  }

  // Resume checkout for an existing order
  Future<void> resumeCheckoutForOrder(String orderId) async {
    try {
      isLoading.value = true;
      error.value = null;

      // Get the order details first
      final orderDetails = await _checkoutApiService.getOrderDetails(orderId);
      currentOrder.value = orderDetails;

      // Determine which step to go to
      final targetStep = await determineCheckoutStep(orderId);

      // Navigate to the appropriate step
      goToStep(targetStep);

      Get.snackbar(
        'Order Resumed',
        'Continuing checkout for order ${orderDetails.orderNumber}',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = 'Failed to resume checkout: $e';
      print('❌ Error resuming checkout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get pending orders (orders that need completion)
  Future<List<Map<String, dynamic>>> getPendingOrders() async {
    await fetchUserOrders(status: 'pending');
    return userOrders
        .where((order) =>
            order['status'] == 'pending' &&
            (order['payment_status'] == null ||
                order['payment_status'] == 'pending'))
        .toList();
  }

  // Get payment method icon
  IconData getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'mpesa':
      case 'airtel_money':
      case 'tigo_pesa':
        return Iconsax.mobile;
      case 'bank_transfer':
      case 'bank':
        return Iconsax.bank;
      case 'paypal':
        return Iconsax.global;
      default:
        return Iconsax.card;
    }
  }

  // Format time remaining for display
  String get formattedTimeRemaining {
    final minutes = paymentTimeRemaining.value ~/ 60;
    final seconds = paymentTimeRemaining.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    // Clean up any timers or listeners
    super.onClose();
  }
}
