import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/models/cart_model.dart';
import '../data/models/artwork_model.dart';
import '../data/providers/cart_provider.dart';
import '../core/theme/app_colors.dart';
import '../services/redirect_service.dart';
import 'auth_controller.dart';

// Local cart item model for guest users
class LocalCartItem {
  final String artworkId;
  final int quantity;
  final double unitPrice;
  final String artworkTitle;
  final String artworkImage;
  final String artistName;

  LocalCartItem({
    required this.artworkId,
    required this.quantity,
    required this.unitPrice,
    required this.artworkTitle,
    required this.artworkImage,
    required this.artistName,
  });

  Map<String, dynamic> toJson() => {
        'artworkId': artworkId,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'artworkTitle': artworkTitle,
        'artworkImage': artworkImage,
        'artistName': artistName,
      };

  factory LocalCartItem.fromJson(Map<String, dynamic> json) => LocalCartItem(
        artworkId: json['artworkId'],
        quantity: json['quantity'],
        unitPrice: json['unitPrice'].toDouble(),
        artworkTitle: json['artworkTitle'],
        artworkImage: json['artworkImage'],
        artistName: json['artistName'],
      );
}

class CartController extends GetxController {
  final CartProvider _cartProvider = CartProvider();
  final GetStorage _storage = GetStorage();
  late final AuthController _authController;

  // Observable variables
  final Rx<Cart?> cart = Rx<Cart?>(null);
  final RxList<LocalCartItem> localCart = <LocalCartItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isGuest = true.obs;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();
    _initializeCart();

    // Listen to auth state changes
    ever(_authController.isAuthenticated, (isAuth) {
      if (isAuth) {
        _syncLocalCartToServer();
      }
    });
  }

  // Initialize cart based on authentication status
  void _initializeCart() {
    if (_authController.isAuthenticated.value) {
      isGuest.value = false;
      loadCart();
    } else {
      isGuest.value = true;
      _loadLocalCart();
    }
  }

  // Load local cart from storage
  void _loadLocalCart() {
    try {
      final localCartData = _storage.read('local_cart');
      if (localCartData != null) {
        final List<dynamic> cartList = localCartData;
        localCart.value =
            cartList.map((item) => LocalCartItem.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading local cart: $e');
      localCart.clear();
    }
  }

  // Save local cart to storage
  void _saveLocalCart() {
    _storage.write(
        'local_cart', localCart.map((item) => item.toJson()).toList());
  }

  // Sync local cart to server when user logs in
  Future<void> _syncLocalCartToServer() async {
    if (localCart.isEmpty) return;

    try {
      isLoading.value = true;

      // Add each local cart item to the server cart
      for (final localItem in localCart.toList()) {
        await _cartProvider.addToCart(localItem.artworkId,
            quantity: localItem.quantity);
      }

      // Clear local cart after successful sync
      localCart.clear();
      _storage.remove('local_cart');

      // Load the updated server cart
      await loadCart();

      Get.snackbar(
        'Success',
        'Your cart items have been synced successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Warning',
        'Some cart items couldn\'t be synced. Please add them manually.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load cart data
  Future<void> loadCart() async {
    try {
      isLoading.value = true;
      error.value = '';

      final cartData = await _cartProvider.getCart();
      cart.value = cartData;
    } catch (e) {
      error.value = e.toString();
      print('Error loading cart: $e');
      // Initialize empty cart on error
      cart.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  // Add item to cart (handles both authenticated and guest users)
  Future<void> addToCart(String artworkId, {int quantity = 1}) async {
    try {
      isLoading.value = true;
      error.value = '';

      if (_authController.isAuthenticated.value) {
        // Authenticated user - add to server cart
        final cartItem = await _cartProvider.addToCart(artworkId, quantity: quantity);
        
        // Update cart state optimistically
        if (cart.value != null) {
          // Check if item already exists
          final existingItemIndex = cart.value!.items.indexWhere(
            (item) => item.artwork.id == artworkId,
          );
          
          if (existingItemIndex != -1) {
            // Update existing item
            final updatedItems = List<CartItem>.from(cart.value!.items);
            updatedItems[existingItemIndex] = cartItem;
            cart.value = cart.value!.copyWith(
              items: updatedItems,
              totalItems: updatedItems.fold(0, (sum, item) => sum + item.quantity),
              totalAmount: updatedItems.fold(0.0, (sum, item) => sum + item.totalPrice),
            );
          } else {
            // Add new item
            final updatedItems = List<CartItem>.from(cart.value!.items)..add(cartItem);
            cart.value = cart.value!.copyWith(
              items: updatedItems,
              totalItems: updatedItems.fold(0, (sum, item) => sum + item.quantity),
              totalAmount: updatedItems.fold(0.0, (sum, item) => sum + item.totalPrice),
            );
          }
        } else {
          // Reload cart if we don't have current state
          await loadCart();
        }
        
        Get.snackbar(
          'Success',
          'Item added to cart!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.accent,
          colorText: Colors.white,
        );
      } else {
        // Guest user - add to local cart
        await _addToLocalCart(artworkId, quantity);
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to add item to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add to local cart for guest users
  Future<void> _addToLocalCart(String artworkId, int quantity) async {
    // This would require artwork data to create local cart item
    // For now, we'll redirect to login
    Get.snackbar(
      'Login Required',
      'Please log in to add items to your cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      mainButton: TextButton(
        onPressed: () => RedirectService.toLogin(),
        child: Text('Login', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Update cart item quantity
  Future<void> updateCartItemQuantity(int itemId, int quantity) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _cartProvider.updateCartItem(itemId, quantity);
      
      // Update local state optimistically
      if (cart.value != null) {
        final updatedItems = cart.value!.items.map((item) {
          if (item.id == itemId) {
            return item.copyWith(
              quantity: quantity,
              totalPrice: item.unitPrice * quantity,
            );
          }
          return item;
        }).toList();
        
        cart.value = cart.value!.copyWith(
          items: updatedItems,
          totalItems: updatedItems.fold(0, (sum, item) => sum + item.quantity),
          totalAmount: updatedItems.fold(0.0, (sum, item) => sum + item.totalPrice),
        );
      }
      
      Get.snackbar(
        'Success',
        'Cart updated!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update cart item',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Reload cart to get correct state
      await loadCart();
    } finally {
      isLoading.value = false;
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(int itemId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _cartProvider.removeFromCart(itemId);
      
      // Update local state optimistically
      if (cart.value != null) {
        final updatedItems = cart.value!.items.where((item) => item.id != itemId).toList();
        
        cart.value = cart.value!.copyWith(
          items: updatedItems,
          totalItems: updatedItems.fold(0, (sum, item) => sum + item.quantity),
          totalAmount: updatedItems.fold(0.0, (sum, item) => sum + item.totalPrice),
        );
      }
      
      Get.snackbar(
        'Success',
        'Item removed from cart!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to remove item from cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Reload cart to get correct state
      await loadCart();
    } finally {
      isLoading.value = false;
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    try {
      isLoading.value = true;
      error.value = '';

      await _cartProvider.clearCart();
      
      // Update local state
      cart.value = cart.value?.copyWith(
        items: [],
        totalItems: 0,
        totalAmount: 0.0,
      );
      
      Get.snackbar(
        'Success',
        'Cart cleared!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to clear cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check if artwork is in cart
  bool isInCart(String artworkId) {
    if (cart.value == null) return false;
    return cart.value!.items.any((item) => item.artwork.id == artworkId);
  }

  // Get cart item count
  int get cartItemCount {
    return cart.value?.totalItems ?? 0;
  }

  // Get total cart amount
  double get cartTotalAmount {
    return cart.value?.totalAmount ?? 0.0;
  }

  // Get cart currency
  String get cartCurrency {
    return cart.value?.currency ?? 'TZS';
  }

  // Get cart item by artwork ID
  CartItem? getCartItem(String artworkId) {
    if (cart.value == null) return null;
    try {
      return cart.value!.items.firstWhere(
        (item) => item.artwork.id == artworkId,
      );
    } catch (e) {
      return null;
    }
  }

  // Format price with currency
  String formatPrice(double price, String currency) {
    if (currency == 'TZS') {
      final formatter = price.toStringAsFixed(0);
      final priceStr = formatter.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return 'TZS $priceStr';
    } else {
      return '$currency ${price.toStringAsFixed(0)}';
    }
  }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load cart: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add item to cart (works for both guest and authenticated users)
  Future<void> addToCart(String artworkId,
      {int quantity = 1, ArtworkList? artwork}) async {
    try {
      isLoading.value = true;
      error.value = '';

      if (isGuest.value || !_authController.isAuthenticated.value) {
        // Guest user - add to local cart
        await _addToLocalCart(artworkId, quantity: quantity, artwork: artwork);
      } else {
        // Authenticated user - add to server cart
        await _cartProvider.addToCart(artworkId, quantity: quantity);
        await loadCart(); // Refresh cart after adding item
      }

      Get.snackbar(
        'Success',
        'Item added to cart successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to add item to cart: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add item to local cart for guest users
  Future<void> _addToLocalCart(String artworkId,
      {int quantity = 1, ArtworkList? artwork}) async {
    // Check if item already exists in local cart
    final existingIndex =
        localCart.indexWhere((item) => item.artworkId == artworkId);

    if (existingIndex >= 0) {
      // Update quantity if item exists
      final existingItem = localCart[existingIndex];
      localCart[existingIndex] = LocalCartItem(
        artworkId: existingItem.artworkId,
        quantity: existingItem.quantity + quantity,
        unitPrice: existingItem.unitPrice,
        artworkTitle: existingItem.artworkTitle,
        artworkImage: existingItem.artworkImage,
        artistName: existingItem.artistName,
      );
    } else {
      // Add new item to local cart
      if (artwork != null) {
        localCart.add(LocalCartItem(
          artworkId: artworkId,
          quantity: quantity,
          unitPrice: artwork.price,
          artworkTitle: artwork.title,
          artworkImage: artwork.getImageUrl(),
          artistName: artwork.artistName,
        ));
      } else {
        throw Exception('Artwork details required for guest cart');
      }
    }

    _saveLocalCart();
  }

  // Update item quantity
  Future<void> updateItemQuantity(int itemId, int quantity) async {
    try {
      isLoading.value = true;
      error.value = '';

      if (isGuest.value || !_authController.isAuthenticated.value) {
        // For local cart, itemId is actually the index
        await _updateLocalCartQuantity(itemId, quantity);
      } else {
        await _cartProvider.updateCartItem(itemId, quantity);
        await loadCart(); // Refresh cart after updating
      }

      Get.snackbar(
        'Success',
        'Quantity updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update quantity: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update local cart item quantity
  Future<void> _updateLocalCartQuantity(int index, int quantity) async {
    if (index >= 0 && index < localCart.length) {
      if (quantity <= 0) {
        localCart.removeAt(index);
      } else {
        final item = localCart[index];
        localCart[index] = LocalCartItem(
          artworkId: item.artworkId,
          quantity: quantity,
          unitPrice: item.unitPrice,
          artworkTitle: item.artworkTitle,
          artworkImage: item.artworkImage,
          artistName: item.artistName,
        );
      }
      _saveLocalCart();
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(int itemId) async {
    try {
      isLoading.value = true;
      error.value = '';

      if (isGuest.value || !_authController.isAuthenticated.value) {
        // For local cart, itemId is actually the index
        await _removeFromLocalCart(itemId);
      } else {
        await _cartProvider.removeFromCart(itemId);
        await loadCart(); // Refresh cart after removing item
      }

      Get.snackbar(
        'Success',
        'Item removed from cart',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to remove item: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Remove item from local cart
  Future<void> _removeFromLocalCart(int index) async {
    if (index >= 0 && index < localCart.length) {
      localCart.removeAt(index);
      _saveLocalCart();
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    try {
      isLoading.value = true;
      error.value = '';

      if (isGuest.value || !_authController.isAuthenticated.value) {
        localCart.clear();
        _storage.remove('local_cart');
      } else {
        await _cartProvider.clearCart();
        await loadCart(); // Refresh cart after clearing
      }

      Get.snackbar(
        'Success',
        'Cart cleared successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to clear cart: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Computed properties
  int get itemCount {
    if (isGuest.value || !_authController.isAuthenticated.value) {
      return localCart.fold(0, (sum, item) => sum + item.quantity);
    }
    if (cart.value == null) return 0;
    return cart.value!.items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    if (isGuest.value || !_authController.isAuthenticated.value) {
      return localCart.fold(
          0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
    }
    if (cart.value == null) return 0.0;
    return cart.value!.items.fold(0.0, (sum, item) {
      return sum + item.totalPrice;
    });
  }

  double get total {
    if (isGuest.value || !_authController.isAuthenticated.value) {
      return subtotal + shipping + tax;
    }
    if (cart.value == null) return 0.0;
    return cart.value!.totalAmount;
  }

  double get shipping {
    // Free shipping for now
    return 0.0;
  }

  double get tax {
    // Calculate tax as 8% of subtotal
    return subtotal * 0.08;
  }

  // Check if cart is empty
  bool get isEmpty {
    if (isGuest.value || !_authController.isAuthenticated.value) {
      return localCart.isEmpty;
    }
    return cart.value == null || cart.value!.items.isEmpty;
  }

  // Check if artwork is in cart
  bool isInCart(String artworkId) {
    if (isGuest.value || !_authController.isAuthenticated.value) {
      return localCart.any((item) => item.artworkId == artworkId);
    }
    return getItemByArtworkId(artworkId) != null;
  }

  // Get quantity of specific artwork in cart
  int getQuantityInCart(String artworkId) {
    if (isGuest.value || !_authController.isAuthenticated.value) {
      final item =
          localCart.firstWhereOrNull((item) => item.artworkId == artworkId);
      return item?.quantity ?? 0;
    }
    final item = getItemByArtworkId(artworkId);
    return item?.quantity ?? 0;
  }

  // Get cart item by artwork ID (for authenticated users)
  CartItem? getItemByArtworkId(String artworkId) {
    if (cart.value == null) return null;

    try {
      return cart.value!.items.firstWhere(
        (item) => item.artwork.id == artworkId,
      );
    } catch (e) {
      return null;
    }
  }

  // Increment item quantity
  Future<void> incrementQuantity(int itemId) async {
    if (isGuest.value || !_authController.isAuthenticated.value) {
      // For local cart, itemId is the index
      if (itemId >= 0 && itemId < localCart.length) {
        await _updateLocalCartQuantity(itemId, localCart[itemId].quantity + 1);
      }
    } else {
      final item = cart.value?.items.firstWhere((item) => item.id == itemId);
      if (item != null) {
        await updateItemQuantity(itemId, item.quantity + 1);
      }
    }
  }

  // Decrement item quantity
  Future<void> decrementQuantity(int itemId) async {
    if (isGuest.value || !_authController.isAuthenticated.value) {
      // For local cart, itemId is the index
      if (itemId >= 0 && itemId < localCart.length) {
        final currentQuantity = localCart[itemId].quantity;
        if (currentQuantity > 1) {
          await _updateLocalCartQuantity(itemId, currentQuantity - 1);
        } else {
          await _removeFromLocalCart(itemId);
        }
      }
    } else {
      final item = cart.value?.items.firstWhere((item) => item.id == itemId);
      if (item != null) {
        if (item.quantity > 1) {
          await updateItemQuantity(itemId, item.quantity - 1);
        } else {
          await removeFromCart(itemId);
        }
      }
    }
  }

  // Method to handle checkout - ensures user is logged in and cart is synced
  Future<bool> prepareForCheckout() async {
    try {
      if (kDebugMode) {
        print('🛒 PREPARE FOR CHECKOUT');
        print(
            '🛒 User authenticated: ${_authController.isAuthenticated.value}');
      }

      // TEMPORARY TEST: Always store redirect to test the flow
      if (kDebugMode) {
        print('🧪 TESTING: Always storing redirect for testing');
        RedirectService.instance.setRedirectDestination('/checkout');
      }

      // Check authentication status
      if (!_authController.isAuthenticated.value) {
        if (kDebugMode) {
          print('🔒 User NOT authenticated - redirecting to login');
        }

        Get.snackbar(
          'Login Required',
          'Please login to continue with checkout',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Use redirect service to handle the redirect
        RedirectService.instance.requireLogin('/checkout');
        return false;
      } else {
        if (kDebugMode) {
          print('✅ User IS authenticated - proceeding to checkout');
        }
      }

      // If user is authenticated and has local cart items, sync them
      if (localCart.isNotEmpty) {
        isLoading.value = true;
        await _syncLocalCartToServer();
        isLoading.value = false;
      }

      // Validate that cart is not empty before checkout
      if (isEmpty) {
        Get.snackbar(
          'Cart Empty',
          'Please add some items to your cart before checkout',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
        );
        return false;
      }

      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to prepare checkout: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Debug method to test redirect service
  void testRedirectFlow() {
    if (kDebugMode) {
      print('🧪 TESTING REDIRECT FLOW');

      // Store a redirect destination
      RedirectService.instance.setRedirectDestination('/checkout');
      print('🧪 Stored redirect destination: /checkout');

      // Retrieve the destination
      final destination = RedirectService.instance.getRedirectDestination();
      print('🧪 Retrieved destination: $destination');

      // Test the navigation
      RedirectService.instance.handlePostLoginNavigation();
      print('🧪 Called handlePostLoginNavigation()');
    }
  }

  // Refresh cart data
  @override
  Future<void> refresh() async {
    if (isGuest.value || !_authController.isAuthenticated.value) {
      _loadLocalCart();
    } else {
      await loadCart();
    }
  }
}
