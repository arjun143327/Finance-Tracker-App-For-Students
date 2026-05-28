import 'package:flutter/material.dart';

/// Centralized constants for UI layout and animation to ensure consistency
/// and prevent hardcoded values across the app.
class AppSizes {
  // Page level padding
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 24, vertical: 60);
  
  // Component paddings
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(16);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(24);
  
  static const EdgeInsets contentPaddingHorizontal = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets contentPaddingVertical = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets contentPaddingAll = EdgeInsets.all(12);

  // Border Radii
  static final BorderRadius radiusSmall = BorderRadius.circular(12);
  static final BorderRadius radiusMedium = BorderRadius.circular(18);
  static final BorderRadius radiusLarge = BorderRadius.circular(20);
  static final BorderRadius radiusExtraLarge = BorderRadius.circular(24);
  
  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconHuge = 56.0;

  // Spacing gaps (Vertical)
  static const SizedBox gapTiny = SizedBox(height: 8);
  static const SizedBox gapSmall = SizedBox(height: 16);
  static const SizedBox gapMedium = SizedBox(height: 24);
  static const SizedBox gapLarge = SizedBox(height: 40);
  
  // Spacing gaps (Horizontal)
  static const SizedBox gapWidthTiny = SizedBox(width: 8);
  static const SizedBox gapWidthSmall = SizedBox(width: 16);
  static const SizedBox gapWidthMedium = SizedBox(width: 24);
}

class AppDurations {
  // Animation durations
  static const Duration fast = Duration(milliseconds: 280);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 850);
  static const Duration breathing = Duration(milliseconds: 1800);
}
