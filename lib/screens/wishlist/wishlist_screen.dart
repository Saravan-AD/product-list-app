import '../../models/product.dart';

class WishlistManager {
  static List<Product> wishlistProducts = [];
  static Set<int> wishlistProductIds = {}; 

  static void toggleWishlist(Product product) {
    if (wishlistProductIds.contains(product.id)) {
      product.inWishlist = false;
      wishlistProducts.removeWhere((p) => p.id == product.id);
      wishlistProductIds.remove(product.id);
    } else {
      product.inWishlist = true;
      wishlistProducts.add(product);
      wishlistProductIds.add(product.id);
    }
  }

  static bool isInWishlist(int productId) {
    return wishlistProductIds.contains(productId);
  }
}