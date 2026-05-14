import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get luxuryTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.bgGradientEnd,
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontFamily: 'Georgia',
          color: AppColors.textPrimary,
          fontSize: 48,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: const TextStyle(
          fontFamily: 'Georgia',
          color: AppColors.textPrimary,
          fontSize: 36,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: const TextStyle(
          fontFamily: 'Georgia',
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'Georgia',
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: const TextStyle(
          fontFamily: 'Arial',
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: const TextStyle(
          fontFamily: 'Arial',
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        labelLarge: const TextStyle(
          fontFamily: 'Arial',
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static BoxDecoration get backgroundGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.bgGradientStart,
          AppColors.bgGradientEnd,
        ],
      ),
    );
  }
}
