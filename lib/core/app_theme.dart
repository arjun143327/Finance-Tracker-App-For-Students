import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// ---------------------------------------------------------------------------
// AppTheme
// Typography strategy:
//   • Display / Headline → Cormorant Garamond (serif, luxury brand identity).
//     On desktop (Windows) the google_fonts package fetches this at runtime.
//     With allowRuntimeFetching = false (set in main.dart) it falls back to
//     the system serif gracefully — no crash, no 404.
//   • Body / Label → Lato (BUNDLED inside google_fonts package — no network
//     fetch needed, always available offline and on web).
// ---------------------------------------------------------------------------
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
        // ── Display — serif for large headings ──────────────────────────────
        displayLarge: GoogleFonts.cormorantGaramond(
          color: AppColors.textPrimary,
          fontSize: 48,
          fontWeight: FontWeight.w600,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          color: AppColors.textPrimary,
          fontSize: 36,
          fontWeight: FontWeight.w500,
        ),
        // ── Headlines ───────────────────────────────────────────────────────
        headlineLarge: GoogleFonts.cormorantGaramond(
          color: AppColors.textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: GoogleFonts.cormorantGaramond(
          color: AppColors.textPrimary,
          fontSize: 21,
          fontWeight: FontWeight.w400,
        ),
        // ── Body — Lato is BUNDLED in the google_fonts package (offline safe)
        bodyLarge: GoogleFonts.lato(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w300,
        ),
        bodyMedium: GoogleFonts.lato(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w300,
        ),
        bodySmall: GoogleFonts.lato(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w300,
        ),
        // ── Labels ──────────────────────────────────────────────────────────
        labelLarge: GoogleFonts.lato(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
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
