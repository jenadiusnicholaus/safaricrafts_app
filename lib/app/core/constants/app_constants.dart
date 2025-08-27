import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'SafariCrafts';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Premium Artwork & Crafts Marketplace';

  // Storage Keys
  static const String storageKey = 'safaricrafts_storage';
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingKey = 'onboarding_completed';
  static const String cartKey = 'cart_items';
  static const String wishlistKey = 'wishlist_items';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image Dimensions
  static const double productImageHeight = 200.0;
  static const double productImageWidth = 150.0;
  static const double bannerImageHeight = 180.0;
  static const double avatarSize = 80.0;
  static const double thumbnailSize = 60.0;

  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 24);

  // Error Messages
  static const String networkError =
      'Network connection error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unexpected error occurred.';
  static const String validationError =
      'Please check your input and try again.';
  static const String authError = 'Authentication failed. Please login again.';

  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String registerSuccess = 'Registration successful!';
  static const String updateSuccess = 'Updated successfully!';
  static const String deleteSuccess = 'Deleted successfully!';
  static const String addToCartSuccess = 'Added to cart!';
  static const String addToWishlistSuccess = 'Added to wishlist!';
  static const String orderPlacedSuccess = 'Order placed successfully!';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 20;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;

  // Currency Configuration
  static const String defaultCurrency =
      'TZS'; // Updated to match the app's primary currency
  static const String secondaryCurrency = 'USD';
  static const String currencySymbol =
      'TZS'; // Updated to match primary currency
  static const String secondaryCurrencySymbol = '\$';

  // Currency formatting
  static const Map<String, String> currencySymbols = {
    'TZS': 'TZS',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
  };

  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Image Placeholders
  static const String placeholderImage = 'assets/images/placeholder.png';
  static const String logoImage = 'assets/images/logo.png';
  static const String avatarPlaceholder =
      'assets/images/avatar_placeholder.png';

  // Social Links
  static const String websiteUrl = 'https://safaricrafts.com';
  static const String supportEmail = 'support@safaricrafts.com';
  static const String privacyPolicyUrl = 'https://safaricrafts.com/privacy';
  static const String termsOfServiceUrl = 'https://safaricrafts.com/terms';
}

class AppSizes {
  // Padding & Margins
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;

  // Icon Sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Button Heights
  static const double buttonHeight = 48.0;
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightLg = 56.0;

  // Input Heights
  static const double inputHeight = 48.0;
  static const double inputHeightSm = 36.0;
  static const double inputHeightLg = 56.0;

  // AppBar Height
  static const double appBarHeight = 56.0;

  // Bottom Navigation Height
  static const double bottomNavHeight = 60.0;

  // Card Heights
  static const double cardHeight = 120.0;
  static const double productCardHeight = 280.0;

  // Image Heights
  static const double bannerHeight = 180.0;
  static const double productImageHeight = 200.0;
}

class AppBreakpoints {
  static const double mobile = 576.0;
  static const double tablet = 768.0;
  static const double desktop = 992.0;
  static const double largeDesktop = 1200.0;
}

enum DeviceType { mobile, tablet, desktop }

class ResponsiveHelper {
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < AppBreakpoints.tablet) {
      return DeviceType.mobile;
    } else if (width < AppBreakpoints.desktop) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  static int getCrossAxisCount(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 2;
      case DeviceType.tablet:
        return 3;
      case DeviceType.desktop:
        return 4;
    }
  }
}
