

/// App Dimensions using ScreenUtil for responsive design
/// All dimensions are responsive and work across all screen sizes including iPad
class AppDimensions {
  AppDimensions._();

  // Padding & Margins
  static double get paddingXS => 4;
  static double get paddingS => 8;
  static double get paddingM => 16;
  static double get paddingL => 24;
  static double get paddingXL => 32;
  static double get paddingXXL => 48;

  // Vertical Spacing
  static double get verticalSpaceXS => 4;
  static double get verticalSpaceS => 8;
  static double get verticalSpaceM => 16;
  static double get verticalSpaceL => 24;
  static double get verticalSpaceXL => 32;
  static double get verticalSpaceXXL => 48;

  // Border Radius
  static double get radiusXS => 4;
  static double get radiusS => 8;
  static double get radiusM => 12;
  static double get radiusL => 16;
  static double get radiusXL => 24;
  static double get radiusXXL => 32;
  static double get radiusRound => 50;

  // Icon Sizes
  static double get iconXS => 12;
  static double get iconS => 16;
  static double get iconM => 24;
  static double get iconL => 32;
  static double get iconXL => 48;
  static double get iconXXL => 64;

  // Button Dimensions
  static double get buttonHeight => 48;
  static double get buttonHeightS => 36;
  static double get buttonHeightL => 56;
  static double get buttonRadius => 12;
  static double get buttonPadding => 16;

  // Input Field Dimensions
  static double get inputHeight => 48;
  static double get inputRadius => 8;
  static double get inputPadding => 16;

  // Card Dimensions
  static double get cardRadius => 12;
  static double get cardPadding => 16;
  static double get cardElevation => 2.0;

  // App Bar
  static double get appBarHeight => 56;
  static double get appBarElevation => 0.0;

  // Bottom Navigation
  static double get bottomNavHeight => 60;
  static double get bottomNavRadius => 16;

  // Avatar Sizes
  static double get avatarS => 32;
  static double get avatarM => 48;
  static double get avatarL => 64;
  static double get avatarXL => 96;

  // Service Provider Card
  static double get serviceCardHeight => 120;
  static double get serviceCardWidth => 280;
  static double get serviceCardRadius => 12;

  // Service Category Icon
  static double get categoryIconSize => 48;
  static double get categoryIconRadius => 12;

  // Rating Star Size
  static double get ratingStarSize => 16;

  // Search Bar
  static double get searchBarHeight => 44;
  static double get searchBarRadius => 22;

  // Banner Dimensions
  static double get bannerHeight => 140;
  static double get bannerRadius => 12;

  // Divider
  static double get dividerThickness => 1.0;
  static double get dividerIndent => 16;

  // Shadow
  static double get shadowBlurRadius => 8.0;
  static double get shadowSpreadRadius => 0.0;
  static double get shadowOffset => 2.0;

  // Snackbar
  static double get snackbarRadius => 8;
  static double get snackbarPadding => 16;
  static double get snackbarMargin => 16;

  // Modal/Dialog
  static double get dialogRadius => 16;
  static double get dialogPadding => 24;
  static double get dialogMaxWidth => 320;

  // List Item
  static double get listItemHeight => 72;
  static double get listItemPadding => 16;

  // Booking Card
  static double get bookingCardHeight => 100;
  static double get bookingCardRadius => 12;

  // Status Indicator
  static double get statusIndicatorSize => 8;
  static double get statusIndicatorRadius => 4;

  // Progress Indicator
  static double get progressIndicatorSize => 24;
  static double get progressIndicatorStroke => 2.0;

  // Tab Bar
  static double get tabBarHeight => 48;
  static double get tabIndicatorHeight => 3;

  // Floating Action Button
  static double get fabSize => 56;
  static double get fabMiniSize => 40;

  // Screen Padding
  static double get screenPaddingHorizontal => 16;
  static double get screenPaddingVertical => 16;
  static double get screenPaddingTop => 22; // Safe area top

  // Responsive Breakpoints
  static double get mobileMaxWidth => 480;
  static double get tabletMaxWidth => 768;
  static double get desktopMinWidth => 1024;

  // Animation Durations (in milliseconds)
  static const int animationDurationFast = 200;
  static const int animationDurationNormal = 300;
  static const int animationDurationSlow = 500;
}
