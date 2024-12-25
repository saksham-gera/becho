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
    "sales_generated": "0.00",
    "clicks": 0,
    "email": "Loading..."
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data on initialization
  }

  Future<void> _loadUserData() async {
    try {
      final userId = await secureStorage.read(key: 'userID');
      if (userId == null) {
        throw Exception('User ID not found');
      }
      final url = 'https://bechoserver.vercel.app/profile/$userId';
      final response = await http.get(Uri.parse(url));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.headers['content-type']?.contains('application/json') ?? false) {
          var apiData = jsonDecode(response.body);
          setState(() {
            userData['name'] = apiData['profile']['username'] ?? "No Name";
            userData['designation'] = apiData['profile']['role'] ?? 'User';
            userData['sales_generated'] = apiData['profile']['sales_generated'] ?? "0.00";
            userData['clicks'] = apiData['profile']['clicks'] ?? 0;
            userData['email'] = apiData['profile']['email'] ?? "No email";
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to fetch user data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

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
                      radius: 50,
                      backgroundImage: AssetImage('assets/profile_placeholder.png'),
                      onBackgroundImageError: (_, __) {
                        print('Error loading profile image');
                      },
                      child: Icon(Icons.person, size: 40), // Fallback icon
                    ),
                    SizedBox(width: 25),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${userData['name']}",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

                // Email
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${userData['email']}",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Wallet and Clicks Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    borderedInfoCard("\$${userData['sales_generated']}", "Sales"),
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

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text("Log out",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget borderedInfoCard(String value, String title) {
    return Container(
      width: 170,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey.shade50, width: 2),
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.shade200.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 15, color: Colors.blueGrey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget optionItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: () {
        print("$title tapped");
      },
    );
  }
}
