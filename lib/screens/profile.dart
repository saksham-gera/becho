import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'welcome.dart'; // Import your Welcome screen

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Map<String, dynamic> userData = {
    "name": "Loading...",
    "designation": "Loading...",
    "wallet": "0.00",
    "clicks": 0,
    "mobile": "Loading...",
    "email": "Loading..."
  };
  bool isLoading = true; // Loading state indicator

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data on initialization
  }

  // Fetch user data using the stored JWT token
  Future<void> _loadUserData() async {
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

      const String url = 'https://bechoserver.vercel.app/users/verify';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var apiData = jsonDecode(response.body);
        setState(() {
          userData['name'] = apiData['user']['username'] ?? "No Name";
          userData['designation'] = "Fashion Model";
          userData['wallet'] = apiData['wallet'] ?? "0.00";
          userData['clicks'] = apiData['clicks'] ?? 0;
          userData['mobile'] = apiData['user']['mobile'] ?? '+91-7383992229' ;
          userData['email'] = apiData['user']['email'] ?? "No email";
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
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
          : Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Profile Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                      AssetImage('assets/profile_placeholder.png'),
                    ),
                    SizedBox(width: 25),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${userData['name']}",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${userData['designation']}",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 20),

                // Mobile and Email below the Profile Box
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${userData['mobile']}",
                        style: TextStyle(color: Colors.grey.shade600,
                            fontSize: 15),
                      ),
                      Text(
                        "${userData['email']}",
                        style: TextStyle(color: Colors.grey.shade600,
                            fontSize: 15),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Wallet and Clicks
                // Wallet and Clicks Section with Borders
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    borderedInfoCard("\$${userData['wallet']}", "Wallet"),
                    SizedBox(width: 10),
                    borderedInfoCard("${userData['clicks']}", "Clicks"),
                  ],
                ),

                SizedBox(height: 30),

                // Options List
                optionItem(Icons.favorite_border, "Your Favorites"),
                optionItem(Icons.payment, "Transactions"),
                optionItem(Icons.person_add, "Invite a Friend"),
                optionItem(Icons.local_offer, "Promotions"),
                optionItem(Icons.settings, "Settings"),
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

  // Info Card for Wallet and Clicks
  Widget infoCard(String value, String title) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  // Options ListTile Widget
  Widget optionItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: () {
        print("$title tapped");
      },
    );
  }

  // Bordered Info Card for Wallet and Clicks
  Widget borderedInfoCard(String value, String title,
      {bool removeRightBorder = false, bool removeLeftBorder = false}) {
    return Container(
      width: 170, // Fixed width for symmetry
      height: 100, // Fixed height to center the content
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.blueGrey.shade50, width: 2),
          bottom: BorderSide(color: Colors.blueGrey.shade50, width: 2),
          left: removeLeftBorder
              ? BorderSide.none
              : BorderSide(color: Colors.blueGrey.shade50, width: 2),
          right: removeRightBorder
              ? BorderSide.none
              : BorderSide(color: Colors.blueGrey.shade50, width: 2),
        ),
        color: Colors.white, // Card background
        borderRadius: BorderRadius.circular(40), // Added border radius
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.shade200.withOpacity(0.2), // Soft shadow
            spreadRadius: 1,
            blurRadius: 2,
          ),
        ],
      ),
      child: Center( // Ensures content is centered
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8), // Spacing between value and title
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: Colors.blueGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
