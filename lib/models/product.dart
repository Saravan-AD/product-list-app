class Product {
  final int id;
  final String name;
  final String description;
  final String featuredImage;
  final double salePrice;
  final double mrp;
  final String productType;
  final String imageUrl;
  final bool available;
  bool inWishlist;
  final List<ProductAddon> addons;
  
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.featuredImage,
    required this.salePrice,
    required this.mrp,
    required this.productType,
    required this.imageUrl,
    required this.available,
    required this.inWishlist,
    required this.addons,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      featuredImage: json['featured_image'],
      salePrice: json['sale_price'].toDouble(),
      mrp: json['mrp'].toDouble(),
      productType: json['product_type'],
      imageUrl: json['images'][0],
      available: json['available'],
      inWishlist: json['in_wishlist'],
      addons: (json['addons'] as List)
          .map((addon) => ProductAddon.fromJson(addon))
          .toList(),
    );
  }
}

class ProductAddon {
  final int id;
  final String name;
  final String description;
  final double price;
  final String featuredImage;

  ProductAddon({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.featuredImage,
  });

  factory ProductAddon.fromJson(Map<String, dynamic> json) {
    return ProductAddon(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      featuredImage: json['featured_image'],
    );
  }
}