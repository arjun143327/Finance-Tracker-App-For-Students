import 'package:flutter/material.dart';
import 'welcome_screen.dart';

void main() {
  runApp(const SavetonApp());
}

class SavetonApp extends StatelessWidget {
  const SavetonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saveton',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD700), // Gold
          primary: const Color(0xFFFFD700),
          secondary: const Color(0xFF4A4A4A),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
