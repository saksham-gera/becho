import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

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
    print(url);
    try {
      final response = await http.get(Uri.parse(url));
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);
      if (response.statusCode == 200) {
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

    final id = productDetails?['id'];
    if (id == null) {
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
        body: json.encode({'userId': userId, 'id': id}),
      );
      print(json.decode(response.body));
      if (response.statusCode == 201 || response.statusCode == 200) {
        fetchProductDetails();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred.')),
      );
    }
  }

  Future<String> createRedirectionURL(String redirectUrl) async {
    final userId = await storage.read(key: 'userID');
    print('User ID: $userId');
    if (userId == null) {
      throw Exception('Failed to create redirection URL. Missing userID.');
    }

    final apiUrl = 'https://bechoserver.vercel.app/commissions/createUserToken/$userId';
    final response = await http.get(Uri.parse(apiUrl));
    print('API Response: ${response.body}');
    print('Response Status Code: ${response.statusCode}');

    try {
      print(json.decode(response.body));
    } catch (e) {
      print('Error decoding JSON: $e');
    }

    final userToken = json.decode(response.body)['token'];
    print('User Token: $userToken');
    if (userToken.isEmpty) {
      throw Exception('User token is empty.');
    }

    String finalUrl =
        'https://becho-redirect.vercel.app/$userToken?redirectUrl=${Uri.encodeComponent(redirectUrl)}';
    print('Final URL: $finalUrl');
    return finalUrl;
  }

  void openRedirectionURL(BuildContext context, String redirectUrl) async {
    try {
      final redirectionUrl = await createRedirectionURL(redirectUrl);
      final Uri uri = Uri.parse(redirectionUrl);
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        print('Launched $redirectionUrl');
      } else {
        throw Exception('Could not launch $redirectionUrl');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open URL: $e')),
      );
    }
  }

  void shareProductDetails() async {
    try {
      final redirectionURL = await createRedirectionURL(productDetails?['link']);
      final productTitle = productDetails?['title'] ?? 'Check out this product!';
      final productImage = productDetails?['image_link'] ?? '';
      final shareText = '$productTitle\n\n$redirectionURL\n\n';

      if (productImage.isNotEmpty) {
        final uri = Uri.parse(productImage);
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/product_image.png');
          await tempFile.writeAsBytes(response.bodyBytes);

          Share.shareXFiles(
            [XFile(tempFile.path)],
            text: shareText,
            subject: 'Product Recommendation',
          );

          // Delay deletion or ensure sharing completes
          await Future.delayed(Duration(seconds: 2));
          tempFile.delete();
        } else {
          throw Exception('Failed to download image. Status: ${response.statusCode}');
        }
      } else {
        Share.share(
          shareText,
          subject: 'Product Recommendation',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share product details: $e')),
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
                          Flexible(
                            child: Text(
                              productDetails?['title'] ?? 'Product Title',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 5, // Adjust the max lines to avoid excessive height.
                              overflow: TextOverflow.ellipsis,
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
                        // onPressed: (){},
                        onPressed: () => openRedirectionURL(context, productDetails?['link']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: Text(
                          'Buy',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        // onPressed: (){},
                        onPressed: shareProductDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: Text(
                          'Sell',
                          style: TextStyle(color: Colors.white, fontSize: 18),
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