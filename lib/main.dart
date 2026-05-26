import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/app_theme.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable Google Fonts network fetching.
  // Fonts are resolved from local assets (bundled in pubspec.yaml).
  // This prevents CORS 404 errors when running on Chrome/web.
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(
    const ProviderScope(
      child: BudgetrixApp(),
    ),
  );
}

class BudgetrixApp extends StatelessWidget {
  const BudgetrixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budgetrix',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.luxuryTheme,
      home: const SplashScreen(),
    );
  }
}
