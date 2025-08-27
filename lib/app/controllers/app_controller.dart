import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/services/api_service.dart';
import '../services/redirect_service.dart';
import '../core/services/flying_cart_animation_service.dart';
import '../data/providers/auth_provider.dart';
import '../data/providers/artwork_provider.dart';
import '../data/providers/cart_provider.dart';
import '../data/providers/review_provider.dart';
import '../data/providers/category_provider.dart';
import '../data/providers/wishlist_provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/artwork_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/cart_animation_controller.dart';
import '../controllers/review_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../core/constants/app_constants.dart';

class AppController extends GetxController {
  static AppController get instance => Get.find();

  final GetStorage _storage = GetStorage();

  // App state
  final RxBool isLoading = false.obs;
  final RxString currentLanguage = 'en'.obs;
  final RxBool isDarkMode = false.obs;
  final RxBool isOnboardingCompleted = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  void _initializeApp() {
    // Initialize storage values
    currentLanguage.value = _storage.read(AppConstants.languageKey) ?? 'en';
    isDarkMode.value = _storage.read(AppConstants.themeKey) ?? false;
    isOnboardingCompleted.value =
        _storage.read(AppConstants.onboardingKey) ?? false;
  }

  // Theme methods
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _storage.write(AppConstants.themeKey, isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void setTheme(bool dark) {
    isDarkMode.value = dark;
    _storage.write(AppConstants.themeKey, dark);
    Get.changeThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
  }

  // Language methods
  void changeLanguage(String languageCode) {
    currentLanguage.value = languageCode;
    _storage.write(AppConstants.languageKey, languageCode);
    Get.updateLocale(Locale(languageCode));
  }

  // Onboarding
  void completeOnboarding() {
    isOnboardingCompleted.value = true;
    _storage.write(AppConstants.onboardingKey, true);
  }

  // Loading state
  void setLoading(bool loading) {
    isLoading.value = loading;
  }

  // Clear app data (on logout)
  void clearAppData() {
    _storage.remove(AppConstants.authTokenKey);
    _storage.remove(AppConstants.userDataKey);
    _storage.remove(AppConstants.cartKey);
    _storage.remove(AppConstants.wishlistKey);
  }
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<RedirectService>(RedirectService(), permanent: true);
    Get.put<FlyingCartAnimationService>(FlyingCartAnimationService(),
        permanent: true);

    // Data Providers
    Get.put<AuthProvider>(AuthProvider(), permanent: true);
    Get.put<ArtworkProvider>(ArtworkProvider(), permanent: true);
    Get.put<CartProvider>(CartProvider(), permanent: true);
    Get.put<ReviewProvider>(ReviewProvider(), permanent: true);
    Get.put<CategoryProvider>(CategoryProvider(), permanent: true);
    Get.put<WishlistProvider>(WishlistProvider(), permanent: true);

    // Controllers
    Get.put<AppController>(AppController(), permanent: true);
    Get.put<MainController>(MainController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<ArtworkController>(ArtworkController(), permanent: true);
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<CartAnimationController>(CartAnimationController(),
        permanent: true);
    Get.put<ReviewController>(ReviewController(), permanent: true);
    Get.put<CategoryController>(CategoryController(), permanent: true);
    Get.put<WishlistController>(WishlistController(), permanent: true);
  }
}
