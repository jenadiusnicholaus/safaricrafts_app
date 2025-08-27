import 'package:get/get.dart';
import '../../data/services/api_service.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/artwork_provider.dart';
import '../../data/providers/cart_provider.dart';
import '../../data/providers/review_provider.dart';
import '../../data/providers/category_provider.dart';
import '../../data/providers/wishlist_provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/artwork_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/review_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../controllers/main_controller.dart';

class DependencyInjection {
  static void init() {
    // Core Services
    Get.put<ApiService>(ApiService(), permanent: true);

    // Data Providers
    Get.put<AuthProvider>(AuthProvider(), permanent: true);
    Get.put<ArtworkProvider>(ArtworkProvider(), permanent: true);
    Get.put<CartProvider>(CartProvider(), permanent: true);
    Get.put<ReviewProvider>(ReviewProvider(), permanent: true);
    Get.put<CategoryProvider>(CategoryProvider(), permanent: true);
    Get.put<WishlistProvider>(WishlistProvider(), permanent: true);

    // Controllers
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<ArtworkController>(ArtworkController(), permanent: true);
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<ReviewController>(ReviewController(), permanent: true);
    Get.put<CategoryController>(CategoryController(), permanent: true);
    Get.put<WishlistController>(WishlistController(), permanent: true);
    Get.put<MainController>(MainController(), permanent: true);
  }
}
