import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome_screen.dart';
import 'budget_setup_screen.dart';
import 'goal_creation_screen.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/local_db/storage_service.dart';
import 'providers/finance_providers.dart';

// Global storage service instance
late StorageService storageService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Initialize storage service
  storageService = StorageService();
  await storageService.init();
  
  runApp(const ProviderScope(child: SavetonApp()));
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
