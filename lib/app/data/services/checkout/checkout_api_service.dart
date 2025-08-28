import 'dart:async';
import '../../models/checkout/shipping_method_model.dart';
import '../../models/checkout/payment_method_model.dart';
import '../../models/checkout/order_model.dart';
import '../../models/checkout/address_model.dart';
import '../api_service.dart';
import '../../../core/constants/api_constants.dart';
import 'package:get/get.dart';
import '../../../controllers/cart_controller.dart';

class CheckoutApiService {
  final ApiService _apiService = ApiService();

  // Get available shipping methods
  Future<List<ShippingMethodModel>> getShippingMethods({
    String? country,
    String? region,
    double? weight,
    double? value,
  }) async {
    try {
      print('🚚 Fetching shipping methods...');

      Map<String, String> queryParams = {};
      if (country != null) queryParams['country'] = country;
      if (region != null) queryParams['region'] = region;
      if (weight != null) queryParams['weight'] = weight.toString();
      if (value != null) queryParams['value'] = value.toString();

      final response = await _apiService.get(
        ApiConstants.getShippingMethods,
        queryParameters: queryParams,
      );

      print('🚚 Shipping methods response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        // Handle paginated response: extract 'results' list
        final data = response.data;
        final List<dynamic> methodsData =
            data is List ? data : (data['results'] ?? []);
        return methodsData
            .map((json) => ShippingMethodModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load shipping methods: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Error fetching shipping methods: $e');
      throw Exception('Failed to load shipping methods: $e');
    }
  }

  // Calculate shipping cost
  Future<Map<String, dynamic>> calculateShippingCost({
    required String shippingMethodId,
    required String destinationCountry,
    String? destinationRegion,
    double? weight,
    double? value,
  }) async {
    try {
      print('💰 Calculating shipping cost...');

      Map<String, dynamic> data = {
        'shipping_method_id': shippingMethodId,
        'destination_country': destinationCountry,
        'weight': weight,
        'value': value,
      };

      if (destinationRegion != null) {
        data['destination_region'] = destinationRegion;
      }

      final response = await _apiService.post(
        ApiConstants.calculateShippingCost,
        data: data,
      );

      print('💰 Shipping cost response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        throw Exception(
            'Failed to calculate shipping cost: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Error calculating shipping cost: $e');
      throw Exception('Failed to calculate shipping cost: $e');
    }
  }

  // Create order - simplified version with proper method signature to match controller usage
  Future<OrderModel> createOrder({
    required AddressModel shippingAddress,
    required AddressModel billingAddress,
    required int shippingMethodId,
    required String customerNotes,
    required bool sameAsShipping,
  }) async {
    try {
      print('📦 Creating order...');

      // Get cart items from CartController
      final cartController = Get.find<CartController>();
      final cartItems = cartController.cart.value?.items ?? [];

      // Defensive: ensure cartItems is a List and not a Map
      if (cartItems is! List) {
        throw Exception(
            'cartItems is not a List. Type: \\${cartItems.runtimeType}');
      }

      final items = cartItems
          .map((item) => {
                'artwork_id': item.artwork.id,
                'quantity': item.quantity,
                'unit_price': item.unitPrice,
              })
          .toList();

      print(
          '🛒 DEBUG: items payload type: \\${items.runtimeType}, value: \\${items}');

      Map<String, dynamic> orderData = {
        'shipping_address': shippingAddress.toJson(),
        'billing_address': billingAddress.toJson(),
        'shipping_method_id': shippingMethodId,
        'customer_notes': customerNotes,
        'same_as_shipping': sameAsShipping,
        'items': items,
      };

      print('📦 Order data: $orderData');

      final response = await _apiService.post(
        ApiConstants.createOrder,
        data: orderData,
      );

      print('📦 Create order response: ${response.data}');

      if (response.statusCode == 201 && response.data != null) {
        return OrderModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create order: ${response.statusMessage}');
      }
    } catch (e, s) {
      print('❌ Error creating order: $e');
      print(s);
      throw Exception('Failed to create order: $e');
    }
  }

  // Get available payment methods
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      print('💳 Fetching payment methods...');

      final response = await _apiService.get(ApiConstants.getPaymentMethods);

      print('💳 Payment methods response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> methodsData = response.data;
        return methodsData
            .map((json) => PaymentMethodModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load payment methods: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Error fetching payment methods: $e');
      throw Exception('Failed to load payment methods: $e');
    }
  }

  // Initialize payment - simplified version to match controller usage
  Future<Map<String, dynamic>> initializePayment({
    required String orderId,
    required PaymentMethodModel paymentMethod,
    String? returnUrl,
    String? cancelUrl,
  }) async {
    try {
      print('💳 Initializing payment...');

      Map<String, dynamic> data = {
        'order_id': orderId,
        'payment_method_id': paymentMethod.method,
      };

      if (returnUrl != null) data['return_url'] = returnUrl;
      if (cancelUrl != null) data['cancel_url'] = cancelUrl;

      final response = await _apiService.post(
        ApiConstants.initializePayment,
        data: data,
      );

      print('💳 Payment initialization response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        throw Exception(
            'Failed to initialize payment: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Error initializing payment: $e');
      throw Exception('Failed to initialize payment: $e');
    }
  }

  // Process mobile payment - simplified version to match controller usage
  Future<Map<String, dynamic>> processMobilePayment({
    required String orderId,
    required PaymentMethodModel paymentMethod,
    required String phoneNumber,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      print('📱 Processing mobile payment...');

      Map<String, dynamic> data = {
        'order_id': orderId,
        'payment_method_id': paymentMethod.method,
        'phone_number': phoneNumber,
      };

      if (additionalData != null) {
        data.addAll(additionalData);
      }

      final response = await _apiService.post(
        ApiConstants.processMobilePayment,
        data: data,
      );

      print('📱 Mobile payment response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        throw Exception(
            'Failed to process mobile payment: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Error processing mobile payment: $e');
      throw Exception('Failed to process mobile payment: $e');
    }
  }

  // Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    try {
      print('💳 Checking payment status: $paymentId');

      final response = await _apiService.get(
        '${ApiConstants.checkPaymentStatus}/$paymentId',
      );

      print('💳 Payment status response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        throw Exception(
            'Failed to check payment status: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Error checking payment status: $e');
      throw Exception('Failed to check payment status: $e');
    }
  }

  // Get order details
  Future<OrderModel> getOrderDetails(String orderId) async {
    try {
      print('📄 Fetching order details: $orderId');

      final response = await _apiService.get(
        '${ApiConstants.getOrderDetails}/$orderId/',
      );

      print('📄 Order details response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return OrderModel.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to load order details: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Error fetching order details: $e');
      throw Exception('Failed to load order details: $e');
    }
  }

  // Get user orders
  Future<Map<String, dynamic>> getUserOrders({
    String? status,
    int limit = 20,
    int offset = 0,
    String ordering = '-created_at',
  }) async {
    try {
      print('📋 Fetching user orders...');

      Map<String, String> queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
        'ordering': ordering,
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiService.get(
        ApiConstants.getUserOrders,
        queryParameters: queryParams,
      );

      print('📋 User orders response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        throw Exception('Failed to load orders: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Error fetching user orders: $e');
      throw Exception('Failed to load orders: $e');
    }
  }
}
