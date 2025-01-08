import '../../models/product.dart';

class WishlistManager {
  static List<Product> wishlistProducts = [];
  static Set<int> wishlistProductIds = {}; // Keep track of product IDs in wishlist

  static void toggleWishlist(Product product) {
    if (wishlistProductIds.contains(product.id)) {
      // Remove from wishlist
      product.inWishlist = false;
      wishlistProducts.removeWhere((p) => p.id == product.id);
      wishlistProductIds.remove(product.id);
    } else {
      // Add to wishlist
      product.inWishlist = true;
      wishlistProducts.add(product);
      wishlistProductIds.add(product.id);
    }
  }

  static bool isInWishlist(int productId) {
    return wishlistProductIds.contains(productId);
  }
}