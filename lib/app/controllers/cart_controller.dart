import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/models/cart_model.dart';
import '../data/providers/cart_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import 'auth_controller.dart';

// Local cart item for guest users
class LocalCartItem {
  final String artworkId; // Changed from int to String to match UUID format
  final String title;
  final String imageUrl;
  final double price;
  final int quantity;
  final String currency; // Added currency field

  LocalCartItem({
    required this.artworkId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.currency =
        AppConstants.defaultCurrency, // Default to app's primary currency
  });

  factory LocalCartItem.fromJson(Map<String, dynamic> json) => LocalCartItem(
        artworkId: json['artwork_id'].toString(), // Ensure it's a string
        title: json['title'],
        imageUrl: json['image_url'],
        price: double.parse(json['price'].toString()),
        quantity: json['quantity'],
        currency: json['currency'] ?? AppConstants.defaultCurrency,
      );

  Map<String, dynamic> toJson() => {
        'artwork_id': artworkId,
        'title': title,
        'image_url': imageUrl,
        'price': price,
        'quantity': quantity,
        'currency': currency,
      };
}

class CartController extends GetxController {
  final CartProvider _cartProvider = CartProvider();
  late final AuthController _authController;
  final GetStorage _storage = GetStorage();

  // Observable variables
  final Rx<Cart?> cart = Rx<Cart?>(null);
  final RxList<LocalCartItem> localCart = <LocalCartItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Computed properties
  bool get isGuest => !_authController.isAuthenticated.value;

  int get itemCount {
    if (isGuest) {
      return localCart.fold(0, (sum, item) => sum + item.quantity);
    }
    return cart.value?.totalItems ?? 0;
  }

  double get subtotal {
    if (isGuest) {
      return localCart.fold(
          0.0, (sum, item) => sum + (item.price * item.quantity));
    }
    return cart.value?.totalAmount ?? 0.0;
  }

  double get tax => subtotal * 0.1; // 10% tax
  double get total => subtotal + tax;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();
    _loadLocalCart();
    _initializeCart();

    // Listen to auth state changes
    ever(_authController.isAuthenticated, (isAuth) {
      if (isAuth) {
        loadCart();
      } else {
        // Clear API cart when logging out
        cart.value = null;
      }
    });
  }

  // Load local cart from storage
  void _loadLocalCart() {
    final cartData = _storage.read('local_cart');
    if (cartData != null) {
      try {
        final cartList = List<Map<String, dynamic>>.from(cartData);
        localCart.value =
            cartList.map((item) => LocalCartItem.fromJson(item)).toList();
      } catch (e) {
        print('Error loading local cart: $e');
        localCart.clear();
      }
    }
  }

  // Save local cart to storage
  void _saveLocalCart() {
    _storage.write(
        'local_cart', localCart.map((item) => item.toJson()).toList());
  }

  // Initialize cart based on authentication status
  void _initializeCart() {
    if (_authController.isAuthenticated.value) {
      loadCart();
    }
  }

  // Load cart data from server
  Future<void> loadCart() async {
    if (!_authController.isAuthenticated.value) return;

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

  // Add item to cart (now supports both guest and authenticated users)
  Future<void> addToCart(
    String artworkId, {
    int quantity = 1,
    String? title,
    String? imageUrl,
    double? price,
    String? currency, // Added currency parameter
  }) async {
    print('🛒 addToCart called with: artworkId=$artworkId, quantity=$quantity');
    print('🛒 isGuest: $isGuest');
    print(
        '🛒 title: $title, imageUrl: $imageUrl, price: $price, currency: $currency');
    print('🛒 imageUrl length: ${imageUrl?.length ?? 0}');
    print('🛒 imageUrl isEmpty: ${imageUrl?.isEmpty ?? true}');

    if (isGuest) {
      // Guest user - add to local cart
      print('🛒 Adding to guest cart');
      if (title == null || imageUrl == null || price == null) {
        print('🛒 Missing artwork information for guest cart');
        print('🛒 title is null: ${title == null}');
        print('🛒 imageUrl is null: ${imageUrl == null}');
        print('🛒 price is null: ${price == null}');
        Get.snackbar(
          'Error',
          'Missing artwork information for guest cart',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      try {
        addToLocalCart(
          artworkId: artworkId, // Now artworkId is already a string
          title: title,
          imageUrl: imageUrl,
          price: price,
          quantity: quantity,
          currency: currency, // Pass currency to local cart
        );
        print('🛒 Successfully added to local cart');
      } catch (e) {
        print('🛒 Error adding to local cart: $e');
        Get.snackbar(
          'Error',
          'Failed to add to local cart: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return;
    }
    print('🛒 Adding to server cart');
    try {
      isLoading.value = true;
      error.value = '';

      // Add to server cart
      final cartItem =
          await _cartProvider.addToCart(artworkId, quantity: quantity);
      print('🛒 Server response: ${cartItem.toString()}');

      // Optimistically update the cart state
      if (cart.value != null) {
        final existingItemIndex = cart.value!.items.indexWhere(
          (item) => item.artwork.id == artworkId,
        );

        List<CartItem> updatedItems;
        if (existingItemIndex != -1) {
          // Update existing item
          updatedItems = List<CartItem>.from(cart.value!.items);
          updatedItems[existingItemIndex] = cartItem;
        } else {
          // Add new item
          updatedItems = List<CartItem>.from(cart.value!.items)..add(cartItem);
        }

        cart.value = cart.value!.copyWith(
          items: updatedItems,
          totalItems:
              updatedItems.fold<int>(0, (sum, item) => sum + item.quantity),
          totalAmount: updatedItems.fold<double>(
              0.0, (sum, item) => sum + item.totalPrice),
        );
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
    } catch (e) {
      error.value = e.toString();
      print('🛒 Add to cart error: $e');
      print('🛒 Error type: ${e.runtimeType}');
      print('🛒 Is guest: $isGuest');
      print('🛒 Artwork ID: $artworkId');
      print('🛒 Title: $title, ImageUrl: $imageUrl, Price: $price');

      String errorMessage = 'Failed to add item to cart';

      // Provide more specific error messages
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        errorMessage = 'Please log in to add items to cart';
      } else if (e.toString().contains('404') ||
          e.toString().contains('Not Found')) {
        errorMessage = 'Artwork not found';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Alternative method to add item using item ID endpoint
  Future<void> addToCartWithItemId(
    String artworkId,
    int itemId, {
    int quantity = 1,
  }) async {
    if (isGuest) {
      throw Exception('This method is only for authenticated users');
    }

    try {
      isLoading.value = true;
      error.value = '';

      print(
          '🛒 Adding to cart with item ID: artworkId=$artworkId, itemId=$itemId');

      final cartItem = await _cartProvider.addToCartWithId(artworkId, itemId,
          quantity: quantity);

      // Update local state
      if (cart.value != null) {
        final existingItemIndex = cart.value!.items.indexWhere(
          (item) => item.id == itemId,
        );

        List<CartItem> updatedItems;
        if (existingItemIndex != -1) {
          updatedItems = List<CartItem>.from(cart.value!.items);
          updatedItems[existingItemIndex] = cartItem;
        } else {
          updatedItems = List<CartItem>.from(cart.value!.items)..add(cartItem);
        }

        cart.value = cart.value!.copyWith(
          items: updatedItems,
          totalItems:
              updatedItems.fold<int>(0, (sum, item) => sum + item.quantity),
          totalAmount: updatedItems.fold<double>(
              0.0, (sum, item) => sum + item.totalPrice),
        );
      }

      Get.snackbar(
        'Success',
        'Item added to cart!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      print('🛒 Error adding to cart with item ID: $e');
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

  // Update cart item quantity
  Future<void> updateCartItemQuantity(int itemId, int quantity) async {
    try {
      // Get the current item for optimistic update
      CartItem? currentItem;
      if (cart.value != null) {
        currentItem = cart.value!.items.firstWhere((item) => item.id == itemId);
      }

      if (currentItem == null) return;

      // 1. OPTIMISTIC UPDATE - Update UI immediately
      final optimisticItems = cart.value!.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(
            quantity: quantity,
            totalPrice: item.artwork.price * quantity,
          );
        }
        return item;
      }).toList();

      // Update UI immediately (optimistic)
      cart.value = cart.value!.copyWith(
        items: optimisticItems,
        totalItems:
            optimisticItems.fold<int>(0, (sum, item) => sum + item.quantity),
        totalAmount: optimisticItems.fold<double>(
            0.0, (sum, item) => sum + item.totalPrice),
      );

      print(
          '🛒 Optimistic update applied for itemId=$itemId, quantity=$quantity');

      // 2. SERVER UPDATE - Call API in background
      final updatedCartItem =
          await _cartProvider.updateCartItem(itemId, quantity);
      print('🛒 Server update completed: ${updatedCartItem.id}');

      // 3. SYNC UPDATE - Ensure UI matches server response
      if (cart.value != null) {
        final syncedItems = cart.value!.items.map((item) {
          if (item.id == itemId) {
            return updatedCartItem; // Use server response
          }
          return item;
        }).toList();

        cart.value = cart.value!.copyWith(
          items: syncedItems,
          totalItems:
              syncedItems.fold<int>(0, (sum, item) => sum + item.quantity),
          totalAmount: syncedItems.fold<double>(
              0.0, (sum, item) => sum + item.totalPrice),
        );
      }

      print('🛒 Cart synced with server successfully');
    } catch (e) {
      // 4. ROLLBACK - Revert optimistic update on error
      print('🛒 Error updating cart item, rolling back: $e');

      // Revert to previous state
      await loadCart(); // Refresh from server to get accurate state

      Get.snackbar(
        'Error',
        'Failed to update cart. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  // Alternative method to update cart item using item ID endpoint
  Future<void> updateCartItemWithId(int itemId, int quantity) async {
    if (isGuest) {
      throw Exception('This method is only for authenticated users');
    }

    try {
      isLoading.value = true;
      error.value = '';

      print(
          '🛒 Updating cart item with ID: itemId=$itemId, quantity=$quantity');

      final updatedCartItem =
          await _cartProvider.updateCartItemWithId(itemId, quantity);

      // Update local state
      if (cart.value != null) {
        final updatedItems = cart.value!.items.map((item) {
          if (item.id == itemId) {
            return updatedCartItem;
          }
          return item;
        }).toList();

        cart.value = cart.value!.copyWith(
          items: updatedItems,
          totalItems:
              updatedItems.fold<int>(0, (sum, item) => sum + item.quantity),
          totalAmount: updatedItems.fold<double>(
              0.0, (sum, item) => sum + item.totalPrice),
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
      print('🛒 Error updating cart item with ID: $e');
      Get.snackbar(
        'Error',
        'Failed to update cart item',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      await loadCart(); // Reload to get correct state
    } finally {
      isLoading.value = false;
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(dynamic itemId) async {
    if (isGuest) {
      // For guest users, itemId should be the artwork ID (string)
      final artworkId = itemId.toString(); // Ensure it's a string
      localCart.removeWhere((item) => item.artworkId == artworkId);
      _saveLocalCart();

      Get.snackbar(
        'Success',
        'Item removed from cart!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      // For authenticated users, itemId should be the cart item ID (int)
      final cartItemId = itemId as int;
      await _cartProvider.removeFromCart(cartItemId);

      // Optimistically update local state
      if (cart.value != null) {
        final updatedItems =
            cart.value!.items.where((item) => item.id != itemId).toList();

        cart.value = cart.value!.copyWith(
          items: updatedItems,
          totalItems:
              updatedItems.fold<int>(0, (sum, item) => sum + item.quantity),
          totalAmount: updatedItems.fold<double>(
              0.0, (sum, item) => sum + item.totalPrice),
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

  // Alternative method to remove cart item using item ID endpoint
  Future<void> removeFromCartWithId(int itemId) async {
    if (isGuest) {
      throw Exception('This method is only for authenticated users');
    }

    try {
      isLoading.value = true;
      error.value = '';

      print('🛒 Removing cart item with ID: itemId=$itemId');

      await _cartProvider.removeFromCartWithId(itemId);

      // Update local state
      if (cart.value != null) {
        final updatedItems =
            cart.value!.items.where((item) => item.id != itemId).toList();

        cart.value = cart.value!.copyWith(
          items: updatedItems,
          totalItems:
              updatedItems.fold<int>(0, (sum, item) => sum + item.quantity),
          totalAmount: updatedItems.fold<double>(
              0.0, (sum, item) => sum + item.totalPrice),
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
      await loadCart(); // Reload to get correct state
    } finally {
      isLoading.value = false;
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    if (isGuest) {
      // Clear local cart
      localCart.clear();
      _saveLocalCart();

      Get.snackbar(
        'Success',
        'Cart cleared!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
      return;
    }

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
    if (isGuest) {
      // For guest users, use the default currency from app settings
      return AppConstants.defaultCurrency;
    }
    return cart.value?.currency ?? AppConstants.defaultCurrency;
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
    final symbol = AppConstants.currencySymbols[currency] ?? currency;

    // Use whole number formatting for TZS (Tanzanian Shilling)
    if (currency == AppConstants.defaultCurrency) {
      final formatter = price.toStringAsFixed(0);
      final priceStr = formatter.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return '$symbol $priceStr';
    } else {
      return '$symbol ${price.toStringAsFixed(2)}';
    }
  }

  // Refresh cart (reload from server)
  Future<void> refreshCart() async {
    await loadCart();
  }

  // Check if cart is empty
  bool get isEmpty {
    return cart.value?.isEmpty ?? true;
  }

  // Check if cart is not empty
  bool get isNotEmpty {
    return !isEmpty;
  }

  // Update item quantity (for guest users with artwork ID)
  Future<void> updateLocalItemQuantity(
      String artworkId, int newQuantity) async {
    if (!isGuest) {
      throw Exception('This method is only for guest users');
    }

    // Find the item index
    final index = localCart.indexWhere((item) => item.artworkId == artworkId);
    if (index == -1) return;

    // Store original item for potential rollback
    final originalItem = localCart[index];

    try {
      // 1. IMMEDIATE UI UPDATE (Optimistic)
      if (newQuantity <= 0) {
        localCart.removeAt(index);
      } else {
        localCart[index] = LocalCartItem(
          artworkId: originalItem.artworkId,
          title: originalItem.title,
          imageUrl: originalItem.imageUrl,
          price: originalItem.price,
          quantity: newQuantity,
          currency: originalItem.currency,
        );
      }

      // 2. PERSIST TO STORAGE (Background)
      await Future.delayed(Duration.zero); // Allow UI to update first
      _saveLocalCart();

      print('🛒 Local cart updated smoothly for $artworkId');
    } catch (e) {
      // 3. ROLLBACK on error
      print('🛒 Error updating local cart, rolling back: $e');

      if (newQuantity <= 0) {
        // Restore the removed item
        localCart.insert(index, originalItem);
      } else {
        // Restore the original quantity
        localCart[index] = originalItem;
      }

      Get.snackbar(
        'Error',
        'Failed to update cart. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  // Prepare for checkout
  Map<String, dynamic> prepareForCheckout() {
    if (isGuest) {
      return {
        'items': localCart
            .map((item) => {
                  'artwork_id': item.artworkId,
                  'quantity': item.quantity,
                  'price': item.price,
                  'currency': item.currency,
                })
            .toList(),
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'currency': cartCurrency,
      };
    } else {
      return {
        'cart_id': cart.value?.id,
        'items': cart.value?.items
            .map((item) => {
                  'artwork_id': item.artwork.id,
                  'quantity': item.quantity,
                  'price': item.artwork.price,
                  'currency': item.artwork.currency,
                })
            .toList(),
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'currency': cartCurrency,
      };
    }
  }

  // Add to local cart (for guest users)
  void addToLocalCart({
    required String artworkId, // Changed from int to String
    required String title,
    required String imageUrl,
    required double price,
    int quantity = 1,
    String? currency, // Added currency parameter
  }) {
    print('🛒 addToLocalCart called with: artworkId=$artworkId, title=$title');
    print('🛒 Current localCart length: ${localCart.length}');

    final itemCurrency = currency ??
        AppConstants.defaultCurrency; // Use provided currency or default

    try {
      final existingIndex =
          localCart.indexWhere((item) => item.artworkId == artworkId);
      print('🛒 Existing index: $existingIndex');

      if (existingIndex != -1) {
        // Update existing item
        print('🛒 Updating existing item');
        final existingItem = localCart[existingIndex];
        localCart[existingIndex] = LocalCartItem(
          artworkId: existingItem.artworkId,
          title: existingItem.title,
          imageUrl: existingItem.imageUrl,
          price: existingItem.price,
          quantity: existingItem.quantity + quantity,
          currency: existingItem.currency, // Keep existing currency
        );
      } else {
        // Add new item
        print('🛒 Adding new item');
        localCart.add(LocalCartItem(
          artworkId: artworkId,
          title: title,
          imageUrl: imageUrl,
          price: price,
          quantity: quantity,
          currency: itemCurrency,
        ));
      }

      _saveLocalCart();
      print('🛒 Local cart saved. New length: ${localCart.length}');

      Get.snackbar(
        'Success',
        'Added to cart!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
    } catch (e) {
      print('🛒 Error in addToLocalCart: $e');
      throw e;
    }
  }

  // Method to get cart statistics
  Map<String, dynamic> getCartStatistics() {
    if (isGuest) {
      return {
        'total_items': localCart.length,
        'total_quantity': localCart.fold(0, (sum, item) => sum + item.quantity),
        'total_amount': subtotal,
        'unique_artworks': localCart.length,
        'currency': cartCurrency, // Use dynamic currency
        'is_guest': true,
      };
    }

    if (cart.value == null) {
      return {
        'total_items': 0,
        'total_quantity': 0,
        'total_amount': 0.0,
        'unique_artworks': 0,
        'currency': cartCurrency, // Use dynamic currency
        'is_guest': false,
      };
    }

    return {
      'total_items': cart.value!.items.length,
      'total_quantity': cart.value!.totalItems,
      'total_amount': cart.value!.totalAmount,
      'unique_artworks': cart.value!.items.length,
      'currency': cart.value!.currency, // Use actual cart currency
      'is_guest': false,
    };
  }

  // Method to validate cart before checkout
  Future<Map<String, dynamic>> validateCartForCheckout() async {
    if (isGuest && localCart.isEmpty) {
      return {
        'is_valid': false,
        'errors': ['Cart is empty'],
      };
    }

    if (!isGuest && (cart.value == null || cart.value!.isEmpty)) {
      return {
        'is_valid': false,
        'errors': ['Cart is empty'],
      };
    }

    // Additional validation logic can be added here
    // e.g., check if items are still available, prices haven't changed, etc.

    return {
      'is_valid': true,
      'errors': [],
    };
  }

  // Method to sync local cart with server cart (for when user logs in)
  Future<void> syncLocalCartWithServer() async {
    if (isGuest || localCart.isEmpty) return;

    try {
      isLoading.value = true;
      print('🔄 Syncing local cart with server...');

      for (final localItem in localCart) {
        try {
          await addToCart(
            localItem.artworkId, // artworkId is already a string
            quantity: localItem.quantity,
            title: localItem.title,
            imageUrl: localItem.imageUrl,
            price: localItem.price,
            currency: localItem.currency, // Pass currency information
          );
        } catch (e) {
          print('🔄 Failed to sync item ${localItem.artworkId}: $e');
        }
      }

      // Clear local cart after successful sync
      localCart.clear();
      _saveLocalCart();

      // Reload server cart
      await loadCart();

      Get.snackbar(
        'Success',
        'Cart synced successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
    } catch (e) {
      print('🔄 Error syncing cart: $e');
      Get.snackbar(
        'Error',
        'Failed to sync cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
