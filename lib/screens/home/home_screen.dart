import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:product_listing_app/api/banner_service.dart';
import '../../api/product_service.dart';
import '../../models/product.dart';
import '../wishlist/wishlist_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _productFuture;
  late Future<List<String>> _bannerFuture;

  TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _message = '';

Future<void> _searchProducts(String query) async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    if (query.isEmpty) {
      setState(() {
        _filteredProducts = _products;
        _message = '';
      });
      return;
    }

    final response = await http.post(
      Uri.parse('https://admin.kushinirestaurant.com/api/search/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'query': query}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List && data.isNotEmpty) {
        setState(() {
          _filteredProducts = data
              .map((productJson) => Product.fromJson(productJson)) 
              .toList();
          _message = '';
        });
      } else {
        setState(() {
          _filteredProducts = [];
          _message = 'No products found';
        });
      }
    } else {
      setState(() {
        _filteredProducts = [];
        _message = 'Error fetching products';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }
  @override
  void initState() {
    super.initState();
    _productFuture = ProductService().fetchProducts();
    _bannerFuture = BannerService().fetchBanners();
    _searchController.addListener(() {
      _searchProducts(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70), // Adjust the height as needed
          child: AppBar(
            backgroundColor: Colors.white, // Make AppBar background transparent
            elevation: 0, // Remove the AppBar shadow
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SearchBar(
                controller: _searchController,
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                elevation: WidgetStatePropertyAll(2),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // Elliptical shape
                  ),
                ),
                hintText: 'Search products...',
                leading: Icon(Icons.search), // Add search icon
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    _searchProducts(query);
                  }
                },
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FutureBuilder<List<String>>(
                  future: _bannerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 150,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return Container(
                        height: 150,
                        child: Center(
                          child: Text('Failed to load banners'),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        height: 150,
                        child: Center(
                          child: Text('No banners available'),
                        ),
                      );
                    } else {
                      final banners = snapshot.data!;
                      return Container(
                        height: 150,
                        child: PageView(
                          children: banners.map((imageUrl) {
                            return Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(child: Icon(Icons.error));
                              },
                            );
                          }).toList(),
                        ),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popolar Products',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              FutureBuilder<List<Product>>(
                future: _productFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Failed to load products'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No products available'));
                  }

                  // Save all products for later use in search
                  _products = snapshot.data!;

                  // If search results are available, show them, otherwise show all products
                  List<Product> displayedProducts = _filteredProducts.isEmpty
                      ? _products
                      : _filteredProducts;

                  // Update isSelected based on wishlist status
                  for (var product in displayedProducts) {
                    product.inWishlist =
                        WishlistManager.isInWishlist(product.id);
                  }

                  // final displayedProducts = snapshot.data!.take(6).toList();

                  // Update isSelected based on wishlist status
                  for (var product in displayedProducts) {
                    product.inWishlist =
                        WishlistManager.isInWishlist(product.id);
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: displayedProducts.length,
                    itemBuilder: (context, index) {
                      return HomeProductCard(
                        product: displayedProducts[index],
                        onWishlistToggle: () {
                          setState(() {
                            WishlistManager.toggleWishlist(
                                displayedProducts[index]);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(displayedProducts[index].inWishlist
                                  ? 'Added to wishlist'
                                  : 'Removed from wishlist'),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class HomeProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onWishlistToggle;

  HomeProductCard({
    required this.product,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Column(
        children: [
          Stack(
            children: [
              Image.network(
                product.imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                right: 4,
                top: 4,
                child: IconButton(
                  icon: Icon(
                    product.inWishlist ? Icons.favorite : Icons.favorite_border,
                    color: product.inWishlist ? Colors.red : Colors.grey,
                  ),
                  onPressed: onWishlistToggle,
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.salePrice}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '₹${product.mrp}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  if (product.available)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 4),
                      height: 28,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text(
                          'Add to Cart',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
