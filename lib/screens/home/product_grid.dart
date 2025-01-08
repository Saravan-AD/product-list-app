import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../wishlist/wishlist_screen.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Wishlist'),
      ),
      body: WishlistManager.wishlistProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your wishlist is empty'),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: WishlistManager.wishlistProducts.length,
              itemBuilder: (context, index) {
                return WishlistCard(
                  product: WishlistManager.wishlistProducts[index],
                  onRemove: () {
                    setState(() {
                      WishlistManager.toggleWishlist(
                        WishlistManager.wishlistProducts[index]
                      );
                    });
                  },
                );
              },
            ),
    );
  }
}

class WishlistCard extends StatelessWidget {
  final Product product;
  final VoidCallback onRemove;

  WishlistCard({required this.product, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Image.network(
            product.imageUrl,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹${product.salePrice}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '₹${product.mrp}',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onRemove,
              ),
              if (product.available)
                TextButton(
                  onPressed: () {
                    // Add to cart logic
                  },
                  child: Text('Add to Cart'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}