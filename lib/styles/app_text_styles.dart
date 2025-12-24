import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App Text Styles using DM Sans font family with ScreenUtil for responsive design
/// All text styles are responsive and maintain consistency across the app
class AppTextStyles {
  AppTextStyles._();

  // Base DM Sans Text Style
  static TextStyle get _baseDMSans => GoogleFonts.dmSans();

  // Display Styles
  static TextStyle get displayLarge => _baseDMSans.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => _baseDMSans.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle get displaySmall => _baseDMSans.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  // Headline Styles
  static TextStyle get headlineLarge => _baseDMSans.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static TextStyle get headlineMedium => _baseDMSans.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static TextStyle get headlineSmall => _baseDMSans.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  // Title Styles
  static TextStyle get titleLarge => _baseDMSans.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle get titleMedium => _baseDMSans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle get titleSmall => _baseDMSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  // Body Styles
  static TextStyle get bodyLarge => _baseDMSans.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle get bodyMedium => _baseDMSans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle get bodySmall => _baseDMSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  // Label Styles
  static TextStyle get labelLarge => _baseDMSans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => _baseDMSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle get labelSmall => _baseDMSans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  // Button Styles
  static TextStyle get buttonLarge => _baseDMSans.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle get buttonMedium => _baseDMSans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle get buttonSmall => _baseDMSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.3,
  );

  // Input Field Styles
  static TextStyle get inputText => _baseDMSans.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle get inputLabel => _baseDMSans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  static TextStyle get inputHint => _baseDMSans.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textHint,
    letterSpacing: 0.1,
  );

  static TextStyle get inputError => _baseDMSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.error,
    letterSpacing: 0.1,
  );

  // App Bar Styles
  static TextStyle get appBarTitle => _baseDMSans.copyWith(
    fontSize: 26.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  // Navigation Styles
  static TextStyle get navLabel => _baseDMSans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  static TextStyle get navLabelActive => _baseDMSans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.primary,
    letterSpacing: 0.2,
  );

  // Price Styles
  static TextStyle get priceText => _baseDMSans.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.primary,
    letterSpacing: 0,
  );

  static TextStyle get priceTextSmall => _baseDMSans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.primary,
    letterSpacing: 0,
  );

  // Rating Styles
  static TextStyle get ratingText => _baseDMSans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static TextStyle get ratingCount => _baseDMSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.textSecondary,
    letterSpacing: 0,
  );

  // Status Styles
  static TextStyle get statusPending => _baseDMSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.statusPending,
    letterSpacing: 0.2,
  );

  static TextStyle get statusCompleted => _baseDMSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.statusCompleted,
    letterSpacing: 0.2,
  );

  static TextStyle get statusCancelled => _baseDMSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.statusCancelled,
    letterSpacing: 0.2,
  );

  // Snackbar Styles
  static TextStyle get snackbarText => _baseDMSans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.1,
  );

  // Link Styles
  static TextStyle get linkText => _baseDMSans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.primary,
    letterSpacing: 0.1,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primary,
  );

  // Caption Styles
  static TextStyle get caption => _baseDMSans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textTertiary,
    letterSpacing: 0.2,
  );

  // Overline Styles
  static TextStyle get overline => _baseDMSans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  // Service Provider Name
  static TextStyle get providerName => _baseDMSans.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  // Service Category
  static TextStyle get serviceCategory => _baseDMSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  // Time Styles
  static TextStyle get timeText => _baseDMSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  // Distance Styles
  static TextStyle get distanceText => _baseDMSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textTertiary,
    letterSpacing: 0.1,
  );
}
