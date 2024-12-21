import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'home.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool _isSignUp = false;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    _arrowAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _arrowAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _arrowAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _storeToken(String? token) async {
    if (token == null) {
      print('No token to store.');
      return;
    }

    try {
      const String secretKey = 'becho';
      final jwt = JWT.verify(token, SecretKey(secretKey));
      final userID = jwt.payload['id'];
      if (jwt.payload['exp'] != null && DateTime.now().millisecondsSinceEpoch >= jwt.payload['exp'] * 1000) {
        print('Token has expired');
      }
      print("$userID");
      if (userID != null) {
        await _secureStorage.write(key: 'authToken', value: token);
        await _secureStorage.write(key: 'userID', value: "$userID");
        print('Token and userID stored securely.');
      } else {
        print('Failed to extract userID from JWT.');
      }
    } catch (e) {
      print('Unexpected error occurred: $e');
    }
  }

  Future<void> _authenticate({
    required BuildContext context,
    required String url,
    required Map<String, String> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final authToken = responseData['token'] as String?;
        if (authToken != null) {
          await _storeToken(authToken);
          Navigator.pop(context); // Close the modal sheet
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
        } else {
          print('Authentication failed: Token is missing in the response.');
        }
      } else {
        print('Authentication failed: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('An error occurred during authentication: $e');
    }
  }

  void _showAuthPopup() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * (_isSignUp ? 0.6 : 0.4),
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSignUp ? 'Sign Up' : 'Login',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        if (_isSignUp)
                          CupertinoTextField(
                            controller: usernameController,
                            placeholder: 'Full Name',
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        if (_isSignUp) const SizedBox(height: 20),
                        CupertinoTextField(
                          controller: emailController,
                          placeholder: 'Email',
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CupertinoTextField(
                          controller: passwordController,
                          placeholder: 'Password',
                          obscureText: true,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CupertinoButton.filled(
                          onPressed: () {
                            if (_isSignUp) {
                              _authenticate(
                                context: context,
                                url: 'https://bechoserver.vercel.app/auth/register',
                                body: {
                                  'username': usernameController.text,
                                  'email': emailController.text,
                                  'password': passwordController.text,
                                },
                              );
                            } else {
                              _authenticate(
                                context: context,
                                url: 'https://bechoserver.vercel.app/auth/login',
                                body: {
                                  'email': emailController.text,
                                  'password': passwordController.text,
                                },
                              );
                            }
                          },
                          child: Text(_isSignUp ? 'Sign Up' : 'Login'),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                            Navigator.pop(context); // Close the current modal
                            _showAuthPopup(); // Reopen with updated state
                          },
                          child: Text(
                            _isSignUp ? 'Already have an account? Login' : "Don't have an account? Sign Up Now",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dy < 0) {
            _showAuthPopup();
          }
        },
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Becho \n Khreeeedo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70.withOpacity(1),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Smart, gorgeous & fashionable \n collection makes you cool',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  AnimatedBuilder(
                    animation: _arrowAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _arrowAnimation.value),
                        child: child,
                      );
                    },
                    child: Column(
                      children: const [
                        Icon(Icons.keyboard_arrow_up, size: 30, color: Colors.white),
                        Text(
                          'Get Started',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
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