import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();

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
    super.dispose();
  }

  void _showAuthPopup() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * (_isSignUp ? 0.6 : 0.4) ,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSignUp ? 'Sign Up' : 'Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        if (_isSignUp)
                          CupertinoTextField(
                            placeholder: 'Full Name',
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        if (_isSignUp) SizedBox(height: 20),
                        if (_isSignUp)
                          CupertinoTextField(
                            placeholder: 'Phone Number',
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        SizedBox(height: 20),
                        CupertinoTextField(
                          placeholder: 'Email',
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(height: 20),
                        CupertinoTextField(
                          placeholder: 'Password',
                          obscureText: true,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(height: 20),
                        CupertinoButton.filled(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(_isSignUp ? 'Sign Up' : 'Login'),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                            Navigator.pop(context); // Close the current modal
                            _showAuthPopup(); // Reopen the modal with updated state
                          },
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Login'
                                : "Don't Have An Account? Sign Up Now",
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
              decoration: BoxDecoration(
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
                      // fontStyle: FontStyle.italic,
                      color: Colors.white70.withOpacity(1),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Smart, gorgeous & fashionable \n collection makes you cool',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  AnimatedBuilder(
                    animation: _arrowAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _arrowAnimation.value),
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_up,
                          size: 30,
                          color: Colors.white,

                        ),
                        Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}