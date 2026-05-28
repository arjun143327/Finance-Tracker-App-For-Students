import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/app_theme.dart';
import 'presentation/screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/sms_listener_service.dart';
import 'services/database/database_service.dart';
// ── Background SMS handler (top-level, required by telephony isolate) ────────
// Re-exported here so the telephony plugin can find it via @pragma entry-point.
// The actual implementation lives in sms_listener_service.dart.
// ignore: unused_import
import 'services/sms_listener_service.dart' show onBackgroundSms;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable Google Fonts network fetching.
  // Fonts are resolved from local assets (bundled in pubspec.yaml).
  // This prevents CORS 404 errors when running on Chrome/web.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize Web Database Persistence
  if (kIsWeb) {
    await DatabaseService().initWeb();
  }

  // ── Initialize services (Android-only; no-op on other platforms) ────────
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await NotificationService.instance.initialize();
    await SmsListenerService.instance.initialize();
  }

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
