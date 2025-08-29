import 'dart:async';
import '../../models/checkout/shipping_method_model.dart';
import '../../models/checkout/payment_method_model.dart';
import '../../models/checkout/order_model.dart';
import '../../models/checkout/address_model.dart';
import '../api_service.dart';
import '../../../core/constants/api_constants.dart';
import 'package:dio/dio.dart' as dio;
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
      if (cartItems.isEmpty) {
        throw Exception('Cart is empty');
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
    String? phoneNumber,
    String? returnUrl,
    String? cancelUrl,
  }) async {
    try {
      print('💳 Initializing payment...');
      print('💳 Payment method object: $paymentMethod');
      print('💳 Payment method toJson: ${paymentMethod.toJson()}');
      print('💳 Payment method type: ${paymentMethod.runtimeType}');
      print('💳 Phone number provided: $phoneNumber');
      print('💳 Is mobile payment: ${paymentMethod.isMobilePayment}');

      final paymentMethodJson = paymentMethod.toJson();
      print('💳 Payment method JSON type: ${paymentMethodJson.runtimeType}');
      print('💳 Payment method JSON content: $paymentMethodJson');

      Map<String, dynamic> data = {
        'order_id': orderId,
        'payment_method': paymentMethodJson,
      };

      // Add phone number for mobile money payments
      if (paymentMethod.isMobilePayment && phoneNumber != null) {
        data['phone_number'] = phoneNumber;
        print('💳 Added phone number to request: $phoneNumber');
      } else {
        print('💳 Phone number not added - isMobile: ${paymentMethod.isMobilePayment}, phone: $phoneNumber');
      }
      
      print('💳 Full request data: $data');
      print('💳 Data types: ${data.map((k, v) => MapEntry(k, '${v.runtimeType}'))}');

      if (returnUrl != null) data['return_url'] = returnUrl;
      if (cancelUrl != null) data['cancel_url'] = cancelUrl;

      print('💳 Making API call to: ${ApiConstants.initializePayment}');
      print('💳 Request payload: $data');

      final response = await _apiService.post(
        ApiConstants.initializePayment,
        data: data,
      );

      print('💳 Payment initialization response: ${response.data}');
      print('💳 Response status code: ${response.statusCode}');
      print('💳 Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200 && response.data != null) {
        // Ensure we return a proper Map<String, dynamic>
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        } else {
          print('💳 Converting response data to Map<String, dynamic>');
          return Map<String, dynamic>.from(response.data);
        }
      } else {
        throw Exception(
            'Failed to initialize payment: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Error initializing payment: $e');
      print('❌ Error type: ${e.runtimeType}');
      
      // Handle DioException specifically
      if (e is dio.DioException) {
        print('💳 DioException status code: ${e.response?.statusCode}');
        print('💳 DioException response data: ${e.response?.data}');
        
        // Check for existing payment error
        if (e.response?.statusCode == 400 && 
            e.response?.data != null &&
            e.response!.data.toString().contains('Payment already exists')) {
          print('💳 Payment already exists, treating as success');
          return {
            'success': true,
            'message': 'Payment already exists',
            'status': 'pending',
            'payment_id': 'existing',
          };
        }
      }
      
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
  }) async {
    try {
      print('📋 Fetching user orders...');

      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiService.get(
        ApiConstants.orders,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        print('📋 Orders fetched successfully: ${response.data['count']} orders');
        return response.data;
      } else {
        throw Exception('Failed to fetch orders: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Error fetching orders: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Get specific order details to determine completion status
  Future<Map<String, dynamic>> getOrderCompletionStatus(String orderId) async {
    try {
      print('🔍 Checking order completion status: $orderId');

      final response = await _apiService.get('${ApiConstants.orders}$orderId/');

      if (response.statusCode == 200) {
        final orderData = response.data;
        print('📄 Order data: $orderData');
        
        return {
          'has_shipping_address': orderData['shipping_address'] != null,
          'has_payment_method': orderData['payment_status'] != null && orderData['payment_status'] != 'pending',
          'is_completed': orderData['status'] == 'completed',
          'payment_status': orderData['payment_status'],
          'shipment_status': orderData['shipment_status'],
          'order': orderData,
        };
      } else {
        throw Exception('Failed to fetch order details: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Error checking order completion: $e');
      throw Exception('Failed to check order completion: $e');
    }
  }
}
