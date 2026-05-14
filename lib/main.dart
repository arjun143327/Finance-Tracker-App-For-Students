import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_theme.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
