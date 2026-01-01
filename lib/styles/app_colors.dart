import 'package:flutter/material.dart';

/// App Colors based on Figma designs
/// All colors are extracted from the provided designs and organized by usage
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF3F51B6);
  static const Color primaryDark = Color(0xFF4A5AE8);
  static const Color primaryLight = Color(0xFF7B8CFF);
  static const Color primaryInner = Color(0xFF1976D2);

  // Secondary Colors
  static const Color secondary = Color(0xFF00C896);
  static const Color secondaryDark = Color(0xFF00B085);
  static const Color secondaryLight = Color(0xFF33D4A7);

  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF8F9FA);
  static const Color backgroundTertiary = Color(0xFFF1F3F4);

  // Splash Screen Colors
  static const Color splashBackground = Color(
    0xFFE8E0F5,
  ); // Light lavender/pale purple
  static const Color splashTextColor = Color(
    0xFF6B46C1,
  ); // Dark purple for logo and text

  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceContainer = Color(0xFFFAFAFA);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF747474);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textHint = Color(0xFFB0B0B0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Action Colors
  static const Color success = Color(0xFF00C896);
  static const Color successLight = Color(0xFFE8F8F5);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFF0F29C);
  static const Color warningDark = Color(0xFF908D4B);
  static const Color error = Color(0xFFE53E3E);
  static const Color errorLight = Color(0xFFFEEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color borderDark = Color(0xFFCCCCCC);
  static const Color divider = Color(0xFFEEEEEE);

  // Icon Colors
  static const Color iconPrimary = Color(0xFF1A1A1A);
  static const Color iconSecondary = Color(0xFF666666);
  static const Color iconTertiary = Color(0xFF999999);
  static const Color iconOnPrimary = Color(0xFFFFFFFF);
  static const Color iconOnSecondary = Color(0xFFFFFFFF);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Rating Colors
  static const Color ratingActive = Color(0xFFFFC107);
  static const Color ratingInactive = Color(0xFFE0E0E0);

  // Status Colors for Bookings
  static const Color statusPending = Color(0xFFFFA726);
  static const Color statusCompleted = Color(0xFF00C896);
  static const Color statusCancelled = Color(0xFFE53E3E);
  static const Color statusInProgress = Color(0xFF2196F3);

  // Service Category Colors
  static const Color electricianColor = Color(0xFF5669FF);
  static const Color plumberColor = Color(0xFF00BCD4);
  static const Color acRepairColor = Color(0xFF4CAF50);
  static const Color carpenterColor = Color(0xFFFF9800);

  // Special Colors
  static const Color facebook = Color(0xFF1877F2);
  static const Color google = Color(0xFFDB4437);
  static const Color whatsapp = Color(0xFF25D366);

  // Dark Theme Colors (for future use)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
}
