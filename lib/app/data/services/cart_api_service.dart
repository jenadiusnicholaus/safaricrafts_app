import 'package:get/get.dart' hide Response;
import '../models/cart_model.dart';
import '../../core/constants/api_constants.dart';
import '../services/api_service.dart';

/// Comprehensive Cart API Service
/// Handles all cart operations including CRUD operations with various endpoint patterns
class CartApiService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Get current user's cart
  /// GET /api/v1/catalog/cart/
  Future<Cart> getCart() async {
    try {
      print('🛒 API: Getting cart...');
      final response = await _apiService.get(ApiConstants.cart);
      print('🛒 API: Cart response: ${response.data}');
      return Cart.fromJson(response.data);
    } catch (e) {
      print('🛒 API: Error getting cart: $e');
      throw Exception('Failed to fetch cart: $e');
    }
  }

  /// Add artwork to cart (basic endpoint)
  /// POST /api/v1/catalog/cart/items/
  Future<CartItem> addToCart(String artworkId, {int quantity = 1}) async {
    try {
      print(
          '🛒 API: Adding to cart - artworkId: $artworkId, quantity: $quantity');
      final response = await _apiService.post(
        ApiConstants.addToCart,
        data: {
          'artwork_id': artworkId,
          'quantity': quantity,
        },
      );
      print('🛒 API: Add to cart response: ${response.data}');
      return CartItem.fromJson(response.data);
    } catch (e) {
      print('🛒 API: Error adding to cart: $e');
      throw Exception('Failed to add item to cart: $e');
    }
  }

  /// Add artwork to cart with specific item ID
  /// POST /api/v1/catalog/cart/items/{item_id}/
  Future<CartItem> addToCartWithItemId(String artworkId, int itemId,
      {int quantity = 1}) async {
    try {
      print(
          '🛒 API: Adding to cart with item ID - artworkId: $artworkId, itemId: $itemId, quantity: $quantity');
      final response = await _apiService.post(
        '${ApiConstants.addToCart}$itemId/',
        data: {
          'artwork_id': artworkId,
          'quantity': quantity,
        },
      );
      print('🛒 API: Add to cart with ID response: ${response.data}');
      return CartItem.fromJson(response.data);
    } catch (e) {
      print('🛒 API: Error adding to cart with item ID: $e');
      throw Exception('Failed to add item to cart: $e');
    }
  }

  /// Update cart item quantity (bulk endpoint)
  /// PATCH /api/v1/catalog/cart/items/
  Future<Cart> updateCartItems(List<Map<String, dynamic>> items) async {
    try {
      print('🛒 API: Bulk updating cart items: $items');
      final response = await _apiService.patch(
        ApiConstants.updateCartItem,
        data: {'items': items},
      );
      print('🛒 API: Bulk update response: ${response.data}');
      return Cart.fromJson(response.data);
    } catch (e) {
      print('🛒 API: Error bulk updating cart items: $e');
      throw Exception('Failed to update cart items: $e');
    }
  }

  /// Update specific cart item quantity
  /// PATCH /api/v1/catalog/cart/items/{item_id}/
  Future<CartItem> updateCartItem(int itemId, int quantity) async {
    try {
      print('🛒 API: Updating cart item $itemId with quantity $quantity');
      final response = await _apiService.patch(
        '${ApiConstants.updateCartItem}$itemId/',
        data: {'quantity': quantity},
      );
      print('🛒 API: Update item response: ${response.data}');
      return CartItem.fromJson(response.data);
    } catch (e) {
      print('🛒 API: Error updating cart item: $e');
      throw Exception('Failed to update cart item: $e');
    }
  }

  /// Remove all items from cart (bulk endpoint)
  /// DELETE /api/v1/catalog/cart/items/
  Future<void> removeAllCartItems() async {
    try {
      print('🛒 API: Removing all cart items...');
      await _apiService.delete(ApiConstants.removeFromCart);
      print('🛒 API: Successfully removed all cart items');
    } catch (e) {
      print('🛒 API: Error removing all cart items: $e');
      throw Exception('Failed to remove all cart items: $e');
    }
  }

  /// Remove specific item from cart
  /// DELETE /api/v1/catalog/cart/items/{item_id}/
  Future<void> removeFromCart(int itemId) async {
    try {
      print('🛒 API: Removing cart item $itemId');
      await _apiService.delete('${ApiConstants.removeFromCart}$itemId/');
      print('🛒 API: Successfully removed item $itemId');
    } catch (e) {
      print('🛒 API: Error removing cart item: $e');
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  /// Clear entire cart
  /// DELETE /api/v1/catalog/cart/
  Future<void> clearCart() async {
    try {
      print('🛒 API: Clearing entire cart...');
      await _apiService.delete(ApiConstants.clearCart);
      print('🛒 API: Successfully cleared cart');
    } catch (e) {
      print('🛒 API: Error clearing cart: $e');
      throw Exception('Failed to clear cart: $e');
    }
  }

  /// Get cart summary/statistics
  Future<Map<String, dynamic>> getCartSummary() async {
    try {
      print('🛒 API: Getting cart summary...');
      final cart = await getCart();

      return {
        'id': cart.id,
        'total_items': cart.items.length,
        'total_quantity': cart.totalItems,
        'total_amount': cart.totalAmount,
        'currency': cart.currency,
        'last_updated': cart.updatedAt,
        'items_summary': cart.items
            .map((item) => {
                  'id': item.id,
                  'artwork_id': item.artwork.id,
                  'title': item.artwork.title,
                  'quantity': item.quantity,
                  'unit_price': item.unitPrice,
                  'total_price': item.totalPrice,
                })
            .toList(),
      };
    } catch (e) {
      print('🛒 API: Error getting cart summary: $e');
      throw Exception('Failed to get cart summary: $e');
    }
  }

  /// Validate cart before checkout
  Future<Map<String, dynamic>> validateCart() async {
    try {
      print('🛒 API: Validating cart...');
      final cart = await getCart();

      List<String> errors = [];

      if (cart.isEmpty) {
        errors.add('Cart is empty');
      }

      if (cart.totalAmount <= 0) {
        errors.add('Cart total must be greater than zero');
      }

      // Check for any invalid items
      for (final item in cart.items) {
        if (item.quantity <= 0) {
          errors.add('Item "${item.artwork.title}" has invalid quantity');
        }
        if (item.unitPrice <= 0) {
          errors.add('Item "${item.artwork.title}" has invalid price');
        }
      }

      return {
        'is_valid': errors.isEmpty,
        'errors': errors,
        'cart_summary': {
          'total_items': cart.items.length,
          'total_quantity': cart.totalItems,
          'total_amount': cart.totalAmount,
          'currency': cart.currency,
        }
      };
    } catch (e) {
      print('🛒 API: Error validating cart: $e');
      return {
        'is_valid': false,
        'errors': ['Failed to validate cart: $e'],
      };
    }
  }

  /// Sync local cart items with server
  Future<Cart> syncLocalCart(List<Map<String, dynamic>> localItems) async {
    try {
      print('🛒 API: Syncing local cart with server...');

      // First clear the existing cart
      await clearCart();

      // Add each local item to server cart
      for (final localItem in localItems) {
        await addToCart(
          localItem['artwork_id'].toString(),
          quantity: localItem['quantity'] ?? 1,
        );
      }

      // Return the updated cart
      final updatedCart = await getCart();
      print('🛒 API: Cart sync completed');
      return updatedCart;
    } catch (e) {
      print('🛒 API: Error syncing local cart: $e');
      throw Exception('Failed to sync local cart: $e');
    }
  }
}
