import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

class RedirectService extends GetxService {
  static RedirectService get instance => Get.find();

  final GetStorage _storage = GetStorage();
  static const String _redirectKey = 'login_redirect';

  /// Store the intended destination before redirecting to login
  void setRedirectDestination(String route) {
    if (kDebugMode) {
      print('🔄 REDIRECT SERVICE: Storing destination -> $route');
    }
    _storage.write(_redirectKey, route);
  }

  /// Get the stored redirect destination
  String? getRedirectDestination() {
    final destination = _storage.read(_redirectKey);
    if (kDebugMode) {
      print('🔄 REDIRECT SERVICE: Retrieved destination -> $destination');
    }
    return destination;
  }

  /// Clear the stored redirect destination
  void clearRedirectDestination() {
    if (kDebugMode) {
      print('🔄 REDIRECT SERVICE: Clearing stored destination');
    }
    _storage.remove(_redirectKey);
  }

  /// Handle post-login navigation
  void handlePostLoginNavigation() {
    try {
      if (kDebugMode) {
        print('🔄 REDIRECT SERVICE: handlePostLoginNavigation called');
      }

      final destination = getRedirectDestination();

      if (destination != null && destination.isNotEmpty) {
        if (kDebugMode) {
          print(
              '🔄 REDIRECT SERVICE: Navigating to stored destination -> $destination');
        }

        // Clear the destination first
        clearRedirectDestination();

        // Check if navigation is available
        if (Get.context != null) {
          // Navigate to the intended destination
          Get.offAllNamed(destination);

          if (kDebugMode) {
            print('✅ REDIRECT SERVICE: Successfully navigated to $destination');
          }
        } else {
          if (kDebugMode) {
            print('❌ REDIRECT SERVICE: Navigation context not available');
          }
          developer.log('Navigation context not available for redirect',
              name: 'RedirectService');
        }
      } else {
        if (kDebugMode) {
          print('🔄 REDIRECT SERVICE: No stored destination, going to main');
        }

        // Default navigation to main page
        if (Get.context != null) {
          Get.offAllNamed('/main');
        } else {
          if (kDebugMode) {
            print(
                '❌ REDIRECT SERVICE: Navigation context not available for main');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ REDIRECT SERVICE ERROR: $e');
        print('❌ Error type: ${e.runtimeType}');
      }
      developer.log('Redirect service navigation failed',
          name: 'RedirectService', error: e);

      // Try fallback navigation
      try {
        if (Get.context != null) {
          Get.offAllNamed('/main');
        }
      } catch (fallbackError) {
        if (kDebugMode) {
          print(
              '❌ REDIRECT SERVICE: Even fallback navigation failed: $fallbackError');
        }
      }
    }
  }

  /// Check if user is trying to access a protected route and redirect to login
  void requireLogin(String intendedRoute) {
    if (kDebugMode) {
      print('🔄 REDIRECT SERVICE: Login required for -> $intendedRoute');
    }

    setRedirectDestination(intendedRoute);
    Get.toNamed('/login');
  }
}
