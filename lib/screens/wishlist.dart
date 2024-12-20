import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'welcome.dart'; // Import your Welcome screen

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  List<Map<String, dynamic>> wishlistData = [];
  bool isLoading = true; // Loading state indicator
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWishlistData(); // Load wishlist data on initialization
  }

  // Fetch wishlist data using the stored JWT token
  Future<void> _loadWishlistData() async {
    try {
      String? token = await secureStorage.read(key: 'authToken');

      // If token is null, redirect to Welcome screen
      if (token == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
        return;
      }

      // Decode token to extract userId (assuming JWT contains userId)
      String? userId = await _getUserIdFromToken(token);

      if (userId == null) {
        throw Exception('User ID not found');
      }

      final String url = 'https://bechoserver.vercel.app/wishlist/$userId';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var apiData = jsonDecode(response.body);

        // Check if the response contains a list (not a map)
        if (apiData is List) {
          setState(() {
            wishlistData = List<Map<String, dynamic>>.from(apiData);
            isLoading = false;
          });
        } else {
          throw Exception('Expected a list in the response');
        }
      } else {
        throw Exception('Failed to fetch wishlist data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
        errorMessage = e.toString(); // Display error message
      });
    }
  }


  // Extract userId from the JWT token (if it's encoded in the token)
  Future<String?> _getUserIdFromToken(String token) async {
    try {
      var parts = token.split('.');
      if (parts.length != 3) {
        return null; // Invalid token
      }

      var payload = parts[1];
      var decodedPayload = _decodeBase64Url(payload);

      var decodedData = jsonDecode(decodedPayload);

      // Convert the 'id' (which is an int) to String
      return decodedData['id'].toString();  // Ensure it's returned as a String
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }




  // Helper function to decode base64 URL encoded string
  String _decodeBase64Url(String base64Url) {
    String padding = '=' * (4 - base64Url.length % 4);
    String base64 = base64Url.replaceAll('-', '+').replaceAll('_', '/');
    return utf8.decode(base64Decode(base64 + padding));
  }

  // Logout function
  Future<void> _logout() async {
    await secureStorage.delete(key: 'authToken');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text('Error: $errorMessage'))
          : Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Wishlist Header
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      color: Colors.red,
                      size: 40,
                    ),
                    SizedBox(width: 25),
                    Text(
                      "Your Wishlist",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Wishlist Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two cards per row
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 2 / 3, // Aspect ratio for each card
                  ),
                  itemCount: wishlistData.length,
                  itemBuilder: (context, index) {
                    return _buildWishlistCard(wishlistData[index]);
                  },
                ),
              ],
            ),
          ),

          // Logout Button at Bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text("Log out",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Wishlist Card widget
  Widget _buildWishlistCard(Map<String, dynamic> product) {
    return Card(
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            product['imageUrl'] ?? 'https://via.placeholder.com/150',
            height: 120.0,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title'] ?? "No Title",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  product['description'] ?? "No Description",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Price: \$${product['price'] ?? '0.00'}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
