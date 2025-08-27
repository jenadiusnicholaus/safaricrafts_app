import 'package:get/get.dart' hide Response;
import '../models/cart_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class OrderProvider {
  final ApiService _apiService = Get.find<ApiService>();

  // Get Orders
  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int limit = 20,
    OrderStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status.name;
      }

      final response = await _apiService.get(
        ApiConstants.orders,
        queryParameters: queryParams,
      );

      final data = response.data['data'];
      final orders =
          (data['items'] as List).map((json) => Order.fromJson(json)).toList();

      return {
        'orders': orders,
        'total': data['total'],
        'page': data['page'],
        'limit': data['limit'],
        'totalPages': data['total_pages'],
      };
    } catch (e) {
      throw Exception('Failed to get orders: ${e.toString()}');
    }
  }

  // Get Order Details
  Future<Order> getOrderDetails(String orderId) async {
    try {
      final response =
          await _apiService.get('${ApiConstants.orderDetails}/$orderId');
      return Order.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get order details: ${e.toString()}');
    }
  }

  // Create Order
  Future<Order> createOrder({
    required Address shippingAddress,
    Address? billingAddress,
    required String paymentMethod,
    String? notes,
    String? couponCode,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.createOrder,
        data: {
          'shipping_address': shippingAddress.toJson(),
          'billing_address': billingAddress?.toJson(),
          'payment_method': paymentMethod,
          'notes': notes,
          'coupon_code': couponCode,
        },
      );

      return Order.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  // Cancel Order
  Future<Order> cancelOrder(String orderId, {String? reason}) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.cancelOrder}/$orderId/cancel',
        data: {
          'reason': reason,
        },
      );

      return Order.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to cancel order: ${e.toString()}');
    }
  }

  // Get Order History
  Future<List<Order>> getOrderHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.orderHistory,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data['data']['items'] as List;
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get order history: ${e.toString()}');
    }
  }

  // Track Order
  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    try {
      final response =
          await _apiService.get('${ApiConstants.orders}/$orderId/track');
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to track order: ${e.toString()}');
    }
  }

  // Return Order
  Future<Map<String, dynamic>> returnOrder({
    required String orderId,
    required List<String> itemIds,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.orders}/$orderId/return',
        data: {
          'item_ids': itemIds,
          'reason': reason,
          'description': description,
        },
      );

      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to return order: ${e.toString()}');
    }
  }

  // Get Invoice
  Future<String> getInvoice(String orderId) async {
    try {
      final response =
          await _apiService.get('${ApiConstants.orders}/$orderId/invoice');
      return response.data['data']['invoice_url'];
    } catch (e) {
      throw Exception('Failed to get invoice: ${e.toString()}');
    }
  }
}
