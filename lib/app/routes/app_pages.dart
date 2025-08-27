import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../controllers/artwork_controller.dart';
import '../modules/splash/splash_view.dart';
import '../modules/main/main_view.dart';
import '../modules/home/home_view.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/register_view.dart';
import '../modules/categories/categories_view.dart';
import '../modules/cart/cart_view.dart';
import '../modules/profile/profile_view.dart';
import '../modules/artworks/artwork_details_view.dart';
import '../modules/artworks/artwork_search_view.dart';
import '../modules/artworks/artworks_by_category_view.dart';
import '../modules/wishlist/wishlist_view.dart';
import '../modules/test/navigation_test_view.dart';
import '../modules/checkout/new_checkout_view.dart';
import '../modules/checkout/checkout_binding.dart';

// Placeholder views for missing modules
class PlaceholderView extends StatelessWidget {
  final String title;

  const PlaceholderView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This page is under construction',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppPages {
  static final List<GetPage> pages = [
    // Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),

    // Authentication Routes
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const PlaceholderView(title: 'Forgot Password'),
    ),

    // Main Navigation
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
    ),

    // Artwork Routes
    GetPage(
      name: AppRoutes.artworks,
      page: () => const PlaceholderView(title: 'Artworks'),
    ),
    GetPage(
      name: AppRoutes.artworkDetails,
      page: () => const ArtworkDetailsView(),
    ),
    GetPage(
      name: AppRoutes.artworkSearch,
      page: () => const ArtworkSearchView(),
    ),
    GetPage(
      name: AppRoutes.featured,
      page: () => const PlaceholderView(title: 'Featured Artworks'),
    ),
    GetPage(
      name: AppRoutes.trending,
      page: () => const PlaceholderView(title: 'Trending Artworks'),
    ),
    GetPage(
      name: AppRoutes.newArrivals,
      page: () => const PlaceholderView(title: 'New Arrivals'),
    ),

    // Category Routes
    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoriesView(),
    ),
    GetPage(
      name: AppRoutes.artworksByCategory,
      page: () => const ArtworksByCategory(),
    ),
    GetPage(
      name: AppRoutes.tribes,
      page: () => const PlaceholderView(title: 'Tribes'),
    ),
    GetPage(
      name: AppRoutes.artworksByTribe,
      page: () => const PlaceholderView(title: 'Tribe Artworks'),
    ),
    GetPage(
      name: AppRoutes.collections,
      page: () => const PlaceholderView(title: 'Collections'),
    ),
    GetPage(
      name: AppRoutes.artworksByCollection,
      page: () => const PlaceholderView(title: 'Collection Artworks'),
    ),

    // Artist Routes
    GetPage(
      name: AppRoutes.artists,
      page: () => const PlaceholderView(title: 'Artists'),
    ),
    GetPage(
      name: AppRoutes.artistProfile,
      page: () => const PlaceholderView(title: 'Artist Profile'),
    ),
    GetPage(
      name: AppRoutes.favoriteArtists,
      page: () => const PlaceholderView(title: 'Favorite Artists'),
    ),

    // Shopping Routes
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartView(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const NewCheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.payment,
      page: () => const PlaceholderView(title: 'Payment'),
    ),
    GetPage(
      name: AppRoutes.orderSuccess,
      page: () => const PlaceholderView(title: 'Order Success'),
    ),

    // Order Routes
    GetPage(
      name: AppRoutes.orders,
      page: () => const PlaceholderView(title: 'My Orders'),
    ),
    GetPage(
      name: AppRoutes.orderDetails,
      page: () => const PlaceholderView(title: 'Order Details'),
    ),
    GetPage(
      name: AppRoutes.trackOrder,
      page: () => const PlaceholderView(title: 'Track Order'),
    ),

    // User Profile Routes
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const PlaceholderView(title: 'Edit Profile'),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const PlaceholderView(title: 'Change Password'),
    ),
    GetPage(
      name: AppRoutes.addresses,
      page: () => const PlaceholderView(title: 'Addresses'),
    ),
    GetPage(
      name: AppRoutes.addAddress,
      page: () => const PlaceholderView(title: 'Add Address'),
    ),
    GetPage(
      name: AppRoutes.editAddress,
      page: () => const PlaceholderView(title: 'Edit Address'),
    ),

    // Wishlist & Reviews
    GetPage(
      name: AppRoutes.wishlist,
      page: () => const WishlistView(),
      binding: BindingsBuilder(() {
        // Ensure ArtworkController is available for WishlistView
        if (!Get.isRegistered<ArtworkController>()) {
          Get.put<ArtworkController>(ArtworkController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.reviews,
      page: () => const PlaceholderView(title: 'Reviews'),
    ),
    GetPage(
      name: AppRoutes.writeReview,
      page: () => const PlaceholderView(title: 'Write Review'),
    ),

    // Settings & Support
    GetPage(
      name: AppRoutes.settings,
      page: () => const PlaceholderView(title: 'Settings'),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const PlaceholderView(title: 'Notifications'),
    ),
    GetPage(
      name: AppRoutes.help,
      page: () => const PlaceholderView(title: 'Help'),
    ),
    GetPage(
      name: AppRoutes.support,
      page: () => const PlaceholderView(title: 'Support'),
    ),
    GetPage(
      name: AppRoutes.contactUs,
      page: () => const PlaceholderView(title: 'Contact Us'),
    ),
    GetPage(
      name: AppRoutes.faq,
      page: () => const PlaceholderView(title: 'FAQ'),
    ),
    GetPage(
      name: AppRoutes.about,
      page: () => const PlaceholderView(title: 'About'),
    ),
    GetPage(
      name: AppRoutes.privacy,
      page: () => const PlaceholderView(title: 'Privacy Policy'),
    ),
    GetPage(
      name: AppRoutes.terms,
      page: () => const PlaceholderView(title: 'Terms & Conditions'),
    ),

    // Onboarding
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const PlaceholderView(title: 'Onboarding'),
    ),

    // Test Navigation
    GetPage(
      name: AppRoutes.navigationTest,
      page: () => const NavigationTestView(),
    ),
  ];
}
