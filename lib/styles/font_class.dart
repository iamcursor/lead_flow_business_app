import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

// Font Family
const FontNameDefault = 'Roboto';

// Font Size Management
class AppFontSize {
  // Private constructor to prevent instantiation
  AppFontSize._();

  // Platform detection helper
  static bool get isDesktop {
    if (kIsWeb) return true;

    try {
      return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    } catch (e) {
      return false; // Fall back to mobile sizing if platform detection fails
    }
  }

  // Base scaling factors
  static double get scaleFactor => isDesktop ? 1.25 : 1.0;
// Headings
  static double get h1 => 32.0 * scaleFactor;
  static double get h2 => 24.0 * scaleFactor;
  static double get h3 => 20.0 * scaleFactor;
  static double get h4 => 18.0 * scaleFactor;
  static double get h5 => 16.0 * scaleFactor;

  // Body text
  static double get bodyLarge => 16.0 * scaleFactor;
  static double get bodyMedium => 14.0 * scaleFactor;
  static double get bodySmall => 12.0 * scaleFactor;
  static double get bodyMini => 10.0 * scaleFactor;

  // Special cases
  static double get caption => 12.0 * scaleFactor;
  static double get button => 14.0 * scaleFactor;
  static double get overline => 10.0 * scaleFactor;

  // Form fields
  static double get inputText => 16.0 * scaleFactor;
  static double get inputLabel => 14.0 * scaleFactor;
  static double get inputError => 12.0 * scaleFactor;

  // Table text
  static double get tableHeader => 14.0 * scaleFactor;
  static double get tableCell => 14.0 * scaleFactor;
  // Font sizes with automatic desktop scaling
  static double get smallTextSize => 10.0 * scaleFactor;
  static double get bodyTextSize => 14.0 * scaleFactor;
  static double get mediumTextSize => 16.0 * scaleFactor;
  static double get largeTextSize => 18.0 * scaleFactor;
  static double get extraLargeTextSize => 22.0 * scaleFactor;

  // Create TextStyle with platform-aware sizing
  static TextStyle getStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    String fontFamily = FontNameDefault,
    TextOverflow? overflow,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize * scaleFactor,
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily,
      overflow: overflow,
      height: height,
      decoration: decoration,
    );
  }

  // Apply scaling to a TextTheme
  static TextTheme getScaledTextTheme(TextTheme baseTheme) {
    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(fontSize: largeTextSize),
      displayMedium: baseTheme.displayMedium?.copyWith(fontSize: bodyTextSize),
      displaySmall: baseTheme.displaySmall?.copyWith(fontSize: bodyTextSize),
      headlineMedium: baseTheme.headlineMedium?.copyWith(fontSize: mediumTextSize),
      titleSmall: baseTheme.titleSmall?.copyWith(fontSize: bodyTextSize),
      titleLarge: baseTheme.titleLarge?.copyWith(fontSize: largeTextSize),
      titleMedium: baseTheme.titleMedium?.copyWith(fontSize: mediumTextSize),
      bodyLarge: baseTheme.bodyLarge?.copyWith(fontSize: bodyTextSize),
      bodyMedium: baseTheme.bodyMedium?.copyWith(fontSize: bodyTextSize),
      bodySmall: baseTheme.bodySmall?.copyWith(fontSize: smallTextSize),
    );
  }
}