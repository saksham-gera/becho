import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

class ProductScreen extends StatefulWidget {
  final String productId;

  ProductScreen({required this.productId});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  Map<String, dynamic>? productDetails;
  bool isLoading = true;
  bool hasError = false;
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    final userId = await storage.read(key: 'userID');
    if (userId == null) {
      throw Exception('User ID not found');
    }
    final url = 'https://bechoserver.vercel.app/products/${widget.productId}?userId=$userId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          productDetails = jsonResponse['product'];
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Widget buildLoadingUI() {
    return Column(
      children: [
        // Back button at the top left
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Handle back button action (e.g., pop the screen)
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        // Shimmer effect for the image container
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Center(
            child: Container(
              width: 250,
              height: 250,
              color: Colors.grey.shade300,
            ),
          ),
        ),
        SizedBox(height: 16),
        // Shimmer effect for the row of texts
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 150,
                height: 20,
                color: Colors.grey.shade300,
              ),
            ),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 70,
                height: 20,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        // Shimmer effect for the row with star and thumbs up
        Row(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Icon(Icons.star, color: Colors.grey.shade300, size: 20),
            ),
            SizedBox(width: 4),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 40,
                height: 20,
                color: Colors.grey.shade300,
              ),
            ),
            SizedBox(width: 16),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Icon(Icons.thumb_up, color: Colors.grey.shade300, size: 20),
            ),
            SizedBox(width: 4),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 40,
                height: 20,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Shimmer effect for the description container
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: double.infinity,
            height: 80,
            color: Colors.grey.shade300,
          ),
        ),
        SizedBox(height: 16),
        // Shimmer effect for the row with text below the description
        Center(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 150,
              height: 20,
              color: Colors.grey.shade300,
            ),
          ),
        ),
        SizedBox(height: 16),
        // Shimmer effect for the final row with two containers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 80,
                height: 20,
                color: Colors.grey.shade300,
              ),
            ),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 120,
                height: 20,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Future<void> addToWishlist() async {
    final userId = await storage.read(key: 'userID');
    if (userId == null || productDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to wishlist. Missing data.')),
      );
      return;
    }

    final newId = productDetails?['new_id'];
    if (newId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid product details.')),
      );
      return;
    }

    final url = 'https://bechoserver.vercel.app/wishlist/handle';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'new_id': newId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        fetchProductDetails();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? buildLoadingUI()
            : hasError
            ? Center(child: Text('Failed to load product details'))
            : Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.favorite_border),
                            color: productDetails?['in_wishlist'] ?? false
                                ? Colors.red
                                : Colors.black,
                            onPressed: addToWishlist,
                          ),
                        ],
                      ),
                      Center(
                        child: Image.network(
                          productDetails?['image_link'] ?? '',
                          width: 250,
                          height: 250,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 250,
                                height: 250,
                                color: Colors.grey.shade200,
                                child: Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey),
                              ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            productDetails?['title'] ?? 'Product Title',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (productDetails?['onSale'] == true)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                'On sale',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          SizedBox(width: 4),
                          Text('${productDetails?['ratings'] ?? 'N/A'}'),
                          SizedBox(width: 16),
                          Icon(Icons.thumb_up, color: Colors.green, size: 20),
                          SizedBox(width: 4),
                          Text(
                            '(${productDetails?['reviews'] ?? 0} reviews)',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        productDetails?['description'] ??
                            'Product description not available.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Hurry! Limited Stock Available.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (productDetails?['price'] != null)
                        (() {
                          final price = double.tryParse(
                              productDetails?['price']?.toString() ?? '0') ??
                              0;
                          final discount = double.tryParse(
                              productDetails?['discount']?.toString() ?? '0') ??
                              0;

                          if (discount > 0) {
                            final discountedPrice = price - (price * discount / 100);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\$${price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                Text(
                                  '\$${discountedPrice.toStringAsFixed(2)} (${discount.toStringAsFixed(0)}% off)',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            );
                          }
                        })(),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Handle Buy action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: Text(
                          'Buy',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Handle Sell action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: Text(
                          'Sell',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}