import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/product_model.dart';
import '../widgets/product_card.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  List<ProductModel> wishlistProducts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchWishlistProducts();
  }

  Future<void> fetchWishlistProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userId = await secureStorage.read(key: 'userID');
      if (userId == null) {
        throw Exception('User ID not found');
      }
      final url = 'https://bechoserver.vercel.app/wishlist/$userId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body)['wishlist'];
        setState(() {
          wishlistProducts = productsJson.map((json) => ProductModel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch wishlist products');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load wishlist products';
        isLoading = false;
      });
      print('Error fetching wishlist products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : wishlistProducts.isEmpty
          ? const Center(
        child: Text(
          'Your wishlist is empty',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : Padding(
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
            return ProductCard(
              product: wishlistProducts[index],
              refresh: fetchWishlistProducts,
            );
          },
        ),
      ),
    );
  }
}