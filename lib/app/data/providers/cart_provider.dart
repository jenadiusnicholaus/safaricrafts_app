import 'package:get/get.dart' hide Response;
import '../models/cart_model.dart';
import '../../core/constants/api_constants.dart';
import '../services/api_service.dart';

class CartProvider {
  final ApiService _apiService = Get.find<ApiService>();

  /// Get current user's cart
  Future<Cart> getCart() async {
    try {
      final response = await _apiService.get(ApiConstants.cart);
      return Cart.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  /// Add an artwork to cart
  Future<CartItem> addToCart(String artworkId, {int quantity = 1}) async {
    try {
      final response = await _apiService.post(
        ApiConstants.addToCart,
        data: {
          'artwork_id': artworkId,
          'quantity': quantity,
        },
      );
      return CartItem.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  /// Update cart item quantity
  Future<void> updateCartItem(int itemId, int quantity) async {
    try {
      await _apiService.patch(
        '${ApiConstants.updateCartItem}$itemId/',
        data: {'quantity': quantity},
      );
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(int itemId) async {
    try {
      await _apiService.delete('${ApiConstants.removeFromCart}$itemId/');
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    try {
      await _apiService.delete(ApiConstants.cart);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}
