import 'package:becho/screens/splash.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Becho',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        // colorScheme: ColorScheme.fromSeed(seedColor: const Color(0x202138)),
        useMaterial3: true,
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Colors.black), // For large text elements
          displayMedium: TextStyle(color: Colors.black), // For medium text elements
          displaySmall: TextStyle(color: Colors.black), // For small text elements
          headlineLarge: TextStyle(color: Colors.black), // For large headings
          headlineMedium: TextStyle(color: Colors.black), // For medium headings
          headlineSmall: TextStyle(color: Colors.black), // For small headings
          titleLarge: TextStyle(color: Colors.black), // For large title text
          titleMedium: TextStyle(color: Colors.black), // For medium title text
          titleSmall: TextStyle(color: Colors.black), // For small title text
          bodyLarge: TextStyle(color: Colors.black), // For large body text
          bodyMedium: TextStyle(color: Colors.black), // For medium body text
          bodySmall: TextStyle(color: Colors.black), // For small body text
          labelLarge: TextStyle(color: Colors.black), // For large label text (e.g., buttons)
          labelMedium: TextStyle(color: Colors.black), // For medium label text
          labelSmall: TextStyle(color: Colors.black), // For small label text
        ),
      ),
      home: const SplashScreen(),
    );
  }
}