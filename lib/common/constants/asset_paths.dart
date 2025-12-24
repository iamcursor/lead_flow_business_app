// // /// Asset paths for images, icons, and other resources
// // /// Centralizes all asset references for easy maintenance
// // class AssetPaths {
// //   AssetPaths._();
// //
// //   // Base paths
// //   static const String _images = 'assets/images';
// //   static const String _icons = 'assets/icons';
// //   static const String _animations = 'assets/animations';
// //   static const String _fonts = 'assets/fonts';
// //
// //   // App Logo and Branding
// //   static const String appLogo = '$_images/logo.png';
//   static const String appLogoWhite = '$_images/app_logo_white.png';
// //   static const String appIcon = '$_icons/app_icon.png';
// //   static const String splashLogo = '$_images/logo.png';
// //
// //   // Onboarding Images
// //   static const String onboarding1 = '$_images/onboarding_1.png';
// //   static const String onboarding2 = '$_images/onboarding_2.png';
// //   static const String onboarding3 = '$_images/onboarding_3.png';
// //
// //   // Welcome and Auth Images
// //   static const String welcomeIllustration = '$_images/welcome_illustration.png';
// //   static const String loginIllustration = '$_images/login_illustration.png';
// //   static const String registerIllustration =
// //       '$_images/register_illustration.png';
// //   static const String forgotPasswordIllustration =
// //       '$_images/forgot_password_illustration.png';
// //
// //   // Service Category Icons
// //   static const String electricianIcon = '$_icons/electrician.png';
// //   static const String plumberIcon = '$_icons/plumber.png';
// //   static const String acRepairIcon = '$_icons/ac_repair.png';
// //   static const String carpenterIcon = '$_icons/carpenter.png';
// //   static const String cleanerIcon = '$_icons/cleaner.png';
// //   static const String painterIcon = '$_icons/painter.png';
// //   static const String mechanicIcon = '$_icons/mechanic.png';
// //   static const String beautyIcon = '$_icons/beauty.png';
// //
// //   // Navigation Icons
// //   static const String homeIcon = '$_icons/home.png';
// //   static const String exploreIcon = '$_icons/explore.png';
// //   static const String bookingsIcon = '$_icons/bookings.png';
// //   static const String chatIcon = '$_icons/chat.png';
// //   static const String profileIcon = '$_icons/profile.png';
// //
// //   // Common Icons
// //   static const String searchIcon = '$_icons/search.png';
// //   static const String filterIcon = '$_icons/filter.png';
// //   static const String locationIcon = '$_icons/location.png';
// //   static const String starIcon = '$_icons/star.png';
// //   static const String heartIcon = '$_icons/heart.png';
// //   static const String shareIcon = '$_icons/share.png';
// //   static const String callIcon = '$_icons/call.png';
// //   static const String messageIcon = '$_icons/message.png';
// //   static const String calendarIcon = '$_icons/calendar.png';
// //   static const String timeIcon = '$_icons/time.png';
// //   static const String notificationIcon = '$_icons/notification.png';
// //   static const String settingsIcon = '$_icons/settings.png';
// //   static const String helpIcon = '$_icons/help.png';
// //   static const String logoutIcon = '$_icons/logout.png';
// //
// //   // Payment Icons
// //   static const String cardIcon = '$_icons/card.png';
// //   static const String cashIcon = '$_icons/cash.png';
// //   static const String walletIcon = '$_icons/wallet.png';
// //   static const String upiIcon = '$_icons/upi.png';
// //
// //   // Social Media Icons
// //   static const String googleIcon = '$_images/google.png';
// //   static const String facebookIcon = '$_icons/facebook.png';
// //   static const String appleIcon = '$_images/apple.png';
// //   static const String whatsappIcon = '$_icons/whatsapp.png';
// //
// //   // Status Icons
// //   static const String successIcon = '$_icons/success.png';
// //   static const String errorIcon = '$_icons/error.png';
// //   static const String warningIcon = '$_icons/warning.png';
// //   static const String infoIcon = '$_icons/info.png';
// //
// //   // Empty State Illustrations
// //   static const String emptyBookings = '$_images/empty_bookings.png';
// //   static const String emptyNotifications = '$_images/empty_notifications.png';
// //   static const String emptySearch = '$_images/empty_search.png';
// //   static const String emptyFavorites = '$_images/empty_favorites.png';
// //   static const String noInternet = '$_images/no_internet.png';
// //
// //   // Placeholder Images
// //   static const String userPlaceholder = '$_images/user_placeholder.png';
// //   static const String servicePlaceholder = '$_images/service_placeholder.png';
// //   static const String imagePlaceholder = '$_images/image_placeholder.png';
// //
// //   // Background Images
// //   static const String authBackground = '$_images/auth_background.png';
// //   static const String homeBackground = '$_images/home_background.png';
// //   static const String profileBackground = '$_images/profile_background.png';
// //
// //   // Banner Images
// //   static const String promoBanner1 = '$_images/promo_banner_1.png';
// //   static const String promoBanner2 = '$_images/promo_banner_2.png';
// //   static const String promoBanner3 = '$_images/promo_banner_3.png';
// //
// //   // Booking Status Icons
// //   static const String pendingIcon = '$_icons/pending.png';
// //   static const String confirmedIcon = '$_icons/confirmed.png';
// //   static const String inProgressIcon = '$_icons/in_progress.png';
// //   static const String completedIcon = '$_icons/completed.png';
// //   static const String cancelledIcon = '$_icons/cancelled.png';
// //
// //   // Rating Icons
// //   static const String starFilledIcon = '$_icons/star_filled.png';
// //   static const String starEmptyIcon = '$_icons/star_empty.png';
// //   static const String starHalfIcon = '$_icons/star_half.png';
// //
// //   // Feature Icons
// //   static const String verifiedIcon = '$_icons/verified.png';
// //   static const String premiumIcon = '$_icons/premium.png';
// //   static const String badgeIcon = '$_icons/badge.png';
// //   static const String shieldIcon = '$_icons/shield.png';
// //
// //   // Navigation Arrows
// //   static const String arrowLeftIcon = '$_icons/arrow_left.png';
// //   static const String arrowRightIcon = '$_icons/arrow_right.png';
// //   static const String arrowUpIcon = '$_icons/arrow_up.png';
// //   static const String arrowDownIcon = '$_icons/arrow_down.png';
// //
// //   // Action Icons
// //   static const String addIcon = '$_icons/add.png';
// //   static const String editIcon = '$_icons/edit.png';
// //   static const String deleteIcon = '$_icons/delete.png';
// //   static const String copyIcon = '$_icons/copy.png';
// //   static const String downloadIcon = '$_icons/download.png';
// //   static const String uploadIcon = '$_icons/upload.png';
// //
// //   // Animations (Lottie files)
// //   static const String loadingAnimation = '$_animations/loading.json';
// //   static const String successAnimation = '$_animations/success.json';
// //   static const String errorAnimation = '$_animations/error.json';
// //   static const String emptyAnimation = '$_animations/empty.json';
// //   static const String noInternetAnimation = '$_animations/no_internet.json';
// //
// //   // Fonts (if using custom fonts)
// //   static const String dmSansRegular = '$_fonts/DMSans-Regular.ttf';
// //   static const String dmSansMedium = '$_fonts/DMSans-Medium.ttf';
// //   static const String dmSansSemiBold = '$_fonts/DMSans-SemiBold.ttf';
// //   static const String dmSansBold = '$_fonts/DMSans-Bold.ttf';
// //
// //   // Provider Images (sample/demo images)
// //   static const String provider1 = '$_images/provider_1.jpg';
// //   static const String provider2 = '$_images/provider_2.jpg';
// //   static const String provider3 = '$_images/provider_3.jpg';
// //   static const String provider4 = '$_images/provider_4.jpg';
// //
// //   // Service Images
// //   static const String electricalService = '$_images/electrical_service.jpg';
// //   static const String plumbingService = '$_images/plumbing_service.jpg';
// //   static const String acService = '$_images/ac_service.jpg';
// //   static const String carpentryService = '$_images/carpentry_service.jpg';
// //
// //   // Utility Methods
// //
// //   /// Get service category icon by name
// //   static String getServiceCategoryIcon(String categoryName) {
// //     switch (categoryName.toLowerCase()) {
// //       case 'electrician':
// //         return electricianIcon;
// //       case 'plumber':
// //         return plumberIcon;
// //       case 'ac repair':
// //         return acRepairIcon;
// //       case 'carpenter':
// //         return carpenterIcon;
// //       case 'cleaner':
// //         return cleanerIcon;
// //       case 'painter':
// //         return painterIcon;
// //       case 'mechanic':
// //         return mechanicIcon;
// //       case 'beauty':
// //         return beautyIcon;
// //       default:
// //         return servicePlaceholder;
// //     }
// //   }
// //
// //   /// Get booking status icon by status
// //   static String getBookingStatusIcon(String status) {
// //     switch (status.toLowerCase()) {
// //       case 'pending':
// //         return pendingIcon;
// //       case 'confirmed':
// //         return confirmedIcon;
// //       case 'in_progress':
// //         return inProgressIcon;
// //       case 'completed':
// //         return completedIcon;
// //       case 'cancelled':
// //         return cancelledIcon;
// //       default:
// //         return pendingIcon;
// //     }
// //   }
// //
// //   /// Get payment method icon
// //   static String getPaymentMethodIcon(String method) {
// //     switch (method.toLowerCase()) {
// //       case 'card':
// //         return cardIcon;
// //       case 'cash':
// //         return cashIcon;
// //       case 'wallet':
// //         return walletIcon;
// //       case 'upi':
// //         return upiIcon;
// //       default:
// //         return cardIcon;
// //     }
// //   }
// // }
