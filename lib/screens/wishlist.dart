import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<ProductModel> wishlistProducts = [
      ProductModel(
        id: '1',
        title: 'Product 1',
        description: 'This is a description for Product 1',
        mrp: '\$10',
        discount: '5%',
        ratings: '4',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      ProductModel(
        id: '2',
        title: 'Product 2',
        description: 'This is a description for Product 2',
        mrp: '\$20',
        discount: '10%',
        ratings: '5',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      ProductModel(
        id: '3',
        title: 'Product 3',
        description: 'This is a description for Product 3',
        mrp: '\$30',
        discount: '0%',
        ratings: '3',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      ProductModel(
        id: '4',
        title: 'Product 4',
        description: 'This is a description for Product 4',
        mrp: '\$40',
        discount: '15%',
        ratings: '4',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      ProductModel(
        id: '5',
        title: 'Product 5',
        description: 'This is a description for Product 5',
        mrp: '\$50',
        discount: '20%',
        ratings: '5',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      ProductModel(
        id: '6',
        title: 'Product 6',
        description: 'This is a description for Product 6',
        mrp: '\$60',
        discount: '10%',
        ratings: '3',
        imageUrl: 'https://via.placeholder.com/150',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
        title: const Text(
          "Wishlist",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two cards per row
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 2 / 3, // Aspect ratio for each card
          ),
          itemCount: wishlistProducts.length,
          itemBuilder: (context, index) {
            return ProductCard(product: wishlistProducts[index]);
          },
        ),
      ),
    );
  }
}