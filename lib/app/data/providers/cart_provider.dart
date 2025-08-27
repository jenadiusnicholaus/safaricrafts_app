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
      print(
          '🛒 CartProvider: Adding to cart - artworkId: $artworkId, quantity: $quantity');
      final response = await _apiService.post(
        ApiConstants.addToCart,
        data: {
          'artwork_id': artworkId,
          'quantity': quantity,
        },
      );
      print('🛒 CartProvider: API Response: ${response.data}');
      final cartItem = CartItem.fromJson(response.data);
      print('🛒 CartProvider: Successfully created CartItem');
      return cartItem;
    } catch (e) {
      print('🛒 CartProvider: Error in addToCart: $e');
      throw Exception('Failed to add item to cart: $e');
    }
  }

  /// Update cart item quantity
  Future<CartItem> updateCartItem(int itemId, int quantity) async {
    try {
      print(
          '🛒 CartProvider: Updating cart item $itemId with quantity $quantity');
      final response = await _apiService.patch(
        '${ApiConstants.updateCartItem}$itemId/',
        data: {'quantity': quantity},
      );
      print('🛒 CartProvider: Update response: ${response.data}');
      return CartItem.fromJson(response.data);
    } catch (e) {
      print('🛒 CartProvider: Error updating cart item: $e');
      throw Exception('Failed to update cart item: $e');
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(int itemId) async {
    try {
      print('🛒 CartProvider: Removing cart item $itemId');
      await _apiService.delete('${ApiConstants.removeFromCart}$itemId/');
      print('🛒 CartProvider: Successfully removed item $itemId');
    } catch (e) {
      print('🛒 CartProvider: Error removing cart item: $e');
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    try {
      print('🛒 CartProvider: Clearing entire cart');
      await _apiService.delete(ApiConstants.clearCart);
      print('🛒 CartProvider: Successfully cleared cart');
    } catch (e) {
      print('🛒 CartProvider: Error clearing cart: $e');
      throw Exception('Failed to clear cart: $e');
    }
  }

  /// Add item to cart using alternative endpoint (with item_id)
  Future<CartItem> addToCartWithId(String artworkId, int itemId,
      {int quantity = 1}) async {
    try {
      print(
          '🛒 CartProvider: Adding to cart with item_id - artworkId: $artworkId, itemId: $itemId, quantity: $quantity');
      final response = await _apiService.post(
        '${ApiConstants.addToCart}$itemId/',
        data: {
          'artwork_id': artworkId,
          'quantity': quantity,
        },
      );
      print('🛒 CartProvider: Add with ID response: ${response.data}');
      return CartItem.fromJson(response.data);
    } catch (e) {
      print('🛒 CartProvider: Error in addToCartWithId: $e');
      throw Exception('Failed to add item to cart: $e');
    }
  }

  /// Update cart item using alternative endpoint (with item_id)
  Future<CartItem> updateCartItemWithId(int itemId, int quantity) async {
    try {
      print(
          '🛒 CartProvider: Updating cart item with ID $itemId, quantity: $quantity');
      final response = await _apiService.patch(
        '${ApiConstants.updateCartItem}$itemId/',
        data: {'quantity': quantity},
      );
      print('🛒 CartProvider: Update with ID response: ${response.data}');
      return CartItem.fromJson(response.data);
    } catch (e) {
      print('🛒 CartProvider: Error updating cart item with ID: $e');
      throw Exception('Failed to update cart item: $e');
    }
  }

  /// Remove item from cart using alternative endpoint (with item_id)
  Future<void> removeFromCartWithId(int itemId) async {
    try {
      print('🛒 CartProvider: Removing cart item with ID $itemId');
      await _apiService.delete('${ApiConstants.removeFromCart}$itemId/');
      print('🛒 CartProvider: Successfully removed item with ID $itemId');
    } catch (e) {
      print('🛒 CartProvider: Error removing cart item with ID: $e');
      throw Exception('Failed to remove item from cart: $e');
    }
  }
}
