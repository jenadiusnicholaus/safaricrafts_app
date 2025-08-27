import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../data/models/user_model.dart';
import '../data/providers/auth_provider.dart';
import '../services/redirect_service.dart';

class AuthController extends GetxController {
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  final GetStorage _storage = GetStorage();

  // Reactive variables
  final Rx<User?> user = Rx<User?>(null);
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  void checkAuthStatus() {
    final token = _storage.read('access_token'); // Use consistent key
    final userData = _storage.read('user_data');

    if (kDebugMode) {
      print('🔍 CHECKING AUTH STATUS...');
      print('🔍 Token exists: ${token != null}');
      print('🔍 User data exists: ${userData != null}');
    }

    if (token != null && userData != null) {
      try {
        user.value = User.fromJson(userData);
        currentUser.value = user.value;
        isAuthenticated.value = true;

        if (kDebugMode) {
          print('✅ User authenticated: ${user.value?.email}');
          print('✅ isAuthenticated.value: ${isAuthenticated.value}');
        }
      } catch (e) {
        // Invalid stored data, clear it
        if (kDebugMode) {
          print('❌ Invalid stored auth data, clearing...');
        }
        logout();
      }
    } else {
      if (kDebugMode) {
        print('❌ No stored auth data found');
        print('❌ isAuthenticated.value: ${isAuthenticated.value}');
      }
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _authProvider.login(email, password);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Store tokens securely - use consistent key names with API service
        final accessToken = data['tokens']['access'];
        final refreshToken = data['tokens']['refresh'];

        await _storage.write(
            'access_token', accessToken); // Match API service key
        await _storage.write('refresh_token', refreshToken);
        await _storage.write(
            'auth_token', accessToken); // Keep for compatibility

        // Store user data securely
        final userData = data['user'];
        await _storage.write('user_data', userData);
        await _storage.write('user_id', userData['id']);

        // Update reactive variables
        try {
          user.value = User.fromJson(userData);
          currentUser.value = user.value;
          isAuthenticated.value = true;

          if (kDebugMode) {
            print('✅ User model created successfully');
            print('✅ User ID: ${user.value?.id}');
            print('✅ User email: ${user.value?.email}');
          }
        } catch (userModelError) {
          if (kDebugMode) {
            print('❌ Error creating User model: $userModelError');
            print('❌ User data: $userData');
          }
          throw userModelError;
        }

        if (kDebugMode) {
          print('🔍 LOGIN SUCCESS - About to check redirect...');
          final redirectValue = _storage.read('login_redirect');
          print('🔍 Current redirect value: "$redirectValue"');
          print('🔍 Is it checkout? ${redirectValue == '/checkout'}');
        }

        _safeSnackbar('Success', 'Welcome back!');

        if (kDebugMode) {
          print('🚀 ABOUT TO CALL REDIRECT SERVICE');
        }

        // Handle post-login navigation using redirect service
        try {
          RedirectService.instance.handlePostLoginNavigation();

          if (kDebugMode) {
            print('🚀 REDIRECT SERVICE CALL COMPLETED');
          }
        } catch (redirectError) {
          if (kDebugMode) {
            print('❌ REDIRECT SERVICE ERROR: $redirectError');
          }
          developer.log('Redirect service failed',
              name: 'AuthController', error: redirectError);

          // Fallback navigation
          Get.offAllNamed('/main');
        }
      } else {
        error.value = 'Login failed';
        _safeSnackbar('Error', error.value, isError: true);
      }
    } catch (e) {
      error.value = e.toString();

      // Log the error with full details
      if (kDebugMode) {
        print('❌ LOGIN ERROR: $e');
        print('❌ Error type: ${e.runtimeType}');
        if (e is Error) {
          print('❌ Stack trace: ${e.stackTrace}');
        }
      }

      developer.log('Login failed', name: 'AuthController', error: e);
      _safeSnackbar('Error', error.value, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Handle post-login redirect securely - simplified approach
  Future<void> _handlePostLoginRedirect() async {
    if (kDebugMode) {
      print('🔍 === POST-LOGIN REDIRECT START ===');
      print('🔍 Current authentication state: ${isAuthenticated.value}');
      print('🔍 Current route: ${Get.currentRoute}');
    }

    // Give the UI a moment to update
    await Future.delayed(const Duration(milliseconds: 100));

    // Check for redirect destination
    final redirectRoute = _storage.read('login_redirect');

    if (kDebugMode) {
      print('🔍 Stored redirect route: "$redirectRoute"');
    }

    if (redirectRoute != null &&
        redirectRoute.isNotEmpty &&
        redirectRoute == '/checkout') {
      // Clear the redirect immediately
      await _storage.remove('login_redirect');

      if (kDebugMode) {
        print('� REDIRECTING TO CHECKOUT!');
        print('🚀 Clearing navigation stack and going to checkout...');
      }

      // Navigate directly to checkout, clearing the navigation stack
      Get.offAllNamed('/checkout');

      if (kDebugMode) {
        print('✅ === REDIRECT COMPLETE ===');
      }
    } else {
      if (kDebugMode) {
        print('🏠 No checkout redirect, going to main page');
        print('🏠 Redirect value was: $redirectRoute');
      }
      Get.offAllNamed('/main');
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _authProvider.register(userData);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Store token if registration includes auto-login
        if (data['access_token'] != null) {
          await _storage.write('auth_token', data['access_token']);
          await _storage.write('refresh_token', data['refresh_token']);

          final userInfo = data['user'] ?? data;
          await _storage.write('user_data', userInfo);

          user.value = User.fromJson(userInfo);
          isAuthenticated.value = true;

          Get.offAllNamed('/dashboard');
        } else {
          // Registration successful but needs verification
          Get.offAllNamed('/login');
        }

        Get.snackbar(
          'Success',
          'Registration successful!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        error.value = 'Registration failed';
        Get.snackbar(
          'Error',
          error.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Call API logout if authenticated
      if (isAuthenticated.value) {
        await _authProvider.logout();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    } finally {
      // Clear all stored authentication data
      await _clearAuthData();

      // Reset controller state
      user.value = null;
      currentUser.value = null;
      isAuthenticated.value = false;
      isLoading.value = false;

      // Navigate to login page
      Get.offAllNamed('/login');

      if (kDebugMode) {
        print('🚪 User logged out successfully');
      }
    }
  }

  // Clear all authentication data securely
  Future<void> _clearAuthData() async {
    await _storage.remove('access_token');
    await _storage.remove('auth_token');
    await _storage.remove('refresh_token');
    await _storage.remove('user_data');
    await _storage.remove('user_id');
    await _storage.remove('login_redirect'); // Clear any pending redirects
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _authProvider.getProfile();

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data as Map<String, dynamic>;
        user.value = User.fromJson(userData);
        await _storage.write('user_data', userData);
      } else {
        error.value = 'Failed to fetch profile';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _authProvider.updateProfile(data);

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data as Map<String, dynamic>;
        user.value = User.fromJson(userData);
        await _storage.write('user_data', userData);

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        error.value = 'Failed to update profile';
        Get.snackbar(
          'Error',
          error.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // UI Helper methods
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Helper getters
  String get userName => user.value?.firstName ?? '';
  String get userEmail => user.value?.email ?? '';
  String? get userAvatar => user.value?.avatar;
  bool get isEmailVerified => user.value?.isVerified ?? false;

  // Helper method to safely show snackbars
  void _safeSnackbar(String title, String message, {bool isError = false}) {
    try {
      // Check if GetX context is available
      if (Get.context != null && Get.isRegistered<GetMaterialController>()) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: isError ? Colors.red[100] : null,
          colorText: isError ? Colors.red[800] : null,
        );

        if (kDebugMode) {
          print('✅ Snackbar shown: $title - $message');
        }
      } else {
        // Navigation not ready, just log the message
        if (kDebugMode) {
          print('⚠️ Navigation not ready, logging message: $title - $message');
        }
        developer.log('$title: $message', name: 'AuthController');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Snackbar error: $e');
        print('⚠️ Fallback logging: $title - $message');
      }
      developer.log('Snackbar failed: $title - $message',
          name: 'AuthController', error: e);
    }
  }

  // Debug method to test redirect functionality
  void debugRedirectFlow() {
    if (kDebugMode) {
      print('🔍 Debug: Current auth status: ${isAuthenticated.value}');
      print('🔍 Debug: Current user: ${user.value?.email ?? 'null'}');
      print('🔍 Debug: Current route: ${Get.currentRoute}');

      final storedRedirect = _storage.read('login_redirect');
      print('🔍 Debug: Stored redirect: $storedRedirect');

      // Test storage
      _storage.write('test_key', 'test_value');
      final testValue = _storage.read('test_key');
      print('🔍 Debug: Storage test - wrote: test_value, read: $testValue');
      _storage.remove('test_key');
    }
  }

  // Test method to manually trigger checkout redirect
  void testCheckoutRedirect() {
    if (kDebugMode) {
      print('🧪 === TESTING CHECKOUT REDIRECT ===');

      // Force logout first
      isAuthenticated.value = false;
      user.value = null;
      currentUser.value = null;

      // Store checkout redirect
      _storage.write('login_redirect', '/checkout');
      final stored = _storage.read('login_redirect');
      print('🧪 Stored redirect: $stored');

      // Simulate login success
      isAuthenticated.value = true;

      // Check redirect logic
      final pendingRedirect = _storage.read('login_redirect');
      print('🧪 Pending redirect: $pendingRedirect');

      if (pendingRedirect != null && pendingRedirect == '/checkout') {
        _storage.remove('login_redirect');
        print('🧪 Would redirect to checkout now!');
        Get.offAllNamed('/checkout');
      } else {
        print('🧪 No redirect found - would go to main');
        Get.offAllNamed('/main');
      }
    }
  }

  // Test method to manually set redirect and test login
  void testRedirectManually() {
    if (kDebugMode) {
      print('🧪 === MANUAL REDIRECT TEST ===');

      // Manually store the redirect
      _storage.write('login_redirect', '/checkout');
      final stored = _storage.read('login_redirect');
      print('🧪 Manually stored redirect: "$stored"');

      // Force show what happens in login redirect check
      final shouldGoToCheckout = _storage.read('login_redirect') == '/checkout';
      print('🧪 Should go to checkout: $shouldGoToCheckout');

      if (shouldGoToCheckout) {
        print('🧪 TEST: Would redirect to checkout!');
        _storage.remove('login_redirect');
        Get.offAllNamed('/checkout');
      } else {
        print('🧪 TEST: Would go to main page');
        Get.offAllNamed('/main');
      }
    }
  }

  // Force logout for testing
  void forceLogout() {
    if (kDebugMode) {
      print('🧪 === FORCE LOGOUT FOR TESTING ===');
    }

    // Clear all stored authentication data
    _storage.remove('access_token');
    _storage.remove('auth_token');
    _storage.remove('refresh_token');
    _storage.remove('user_data');
    _storage.remove('user_id');

    // Reset controller state
    user.value = null;
    currentUser.value = null;
    isAuthenticated.value = false;
    isLoading.value = false;

    if (kDebugMode) {
      print(
          '🧪 Force logout complete - isAuthenticated: ${isAuthenticated.value}');
    }
  }

  // Debug method to check current authentication state
  void debugAuthState() {
    if (kDebugMode) {
      print('🔍 === AUTH STATE DEBUG ===');
      print('🔍 isAuthenticated.value: ${isAuthenticated.value}');
      print('🔍 user.value: ${user.value?.email ?? 'null'}');

      final token = _storage.read('access_token');
      final userData = _storage.read('user_data');

      print('🔍 Stored token exists: ${token != null}');
      print('🔍 Stored user data exists: ${userData != null}');

      if (token != null) {
        print('🔍 Token preview: ${token.toString().substring(0, 50)}...');
      }

      print('🔍 === END AUTH DEBUG ===');
    }
  }

  // Manual test for redirect functionality
  void testRedirectAfterLogin() {
    if (kDebugMode) {
      print('🧪 === MANUAL REDIRECT TEST ===');
      print('🧪 Current auth state: ${isAuthenticated.value}');
    }

    // Manually call the redirect service
    RedirectService.instance.handlePostLoginNavigation();

    if (kDebugMode) {
      print('🧪 Manual redirect test completed');
    }
  }
}
