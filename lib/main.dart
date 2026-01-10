import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome_screen.dart';
import 'budget_setup_screen.dart';
import 'goal_creation_screen.dart';

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
          seedColor: const Color(0xFFFF6B35), // Orange
          primary: const Color(0xFFFF6B35),
          secondary: const Color(0xFF4DABF7),
          surface: const Color(0xFFFFF8F0),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8F0),
        useMaterial3: true,
        // Using GoogleFonts properly to avoid missing font errors
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
