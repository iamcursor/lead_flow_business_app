/// App-wide constants and configuration values
class AppConstants {
  AppConstants._();

  // Base URL
  static const String baseUrl = 'https://leadflow.techaelia.com';

  // API Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int initialPage = 1;

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 1);
  static const Duration longCacheExpiration = Duration(days: 1);
  static const int maxCacheSize = 50; // MB

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Debounce Durations
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration buttonDebounce = Duration(milliseconds: 1000);

  // User Preferences Keys
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyUserToken = 'user_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserType = 'user_type';
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyLocationPermission = 'location_permission';
  static const String keySelectedLocation = 'selected_location';

  // User Types
  static const String userTypeSeeker = 'seeker';
  static const String userTypeProvider = 'provider';

  // Service Categories
  static const List<String> serviceCategories = [
    'Electrician',
    'Plumber',
    'AC Repair',
    'Carpenter',
    'Cleaner',
    'Painter',
    'Mechanic',
    'Beauty',
  ];

  // Booking Status
  static const String bookingStatusPending = 'pending';
  static const String bookingStatusConfirmed = 'confirmed';
  static const String bookingStatusInProgress = 'in_progress';
  static const String bookingStatusCompleted = 'completed';
  static const String bookingStatusCancelled = 'cancelled';

  // Payment Methods
  static const String paymentMethodCard = 'card';
  static const String paymentMethodCash = 'cash';
  static const String paymentMethodWallet = 'wallet';
  static const String paymentMethodUPI = 'upi';

  // Rating Configuration
  static const double minRating = 1.0;
  static const double maxRating = 5.0;
  static const double defaultRating = 0.0;

  // Location Configuration
  static const double defaultLatitude = 28.6139; // Delhi
  static const double defaultLongitude = 77.2090;
  static const double searchRadius = 10.0; // km
  static const double maxSearchRadius = 50.0; // km

  // Default Location Values for Signup
  static const String defaultCity = 'Austin';
  static const String defaultState = 'TX';
  static const int defaultRadiusMiles = 25;

  // Image Configuration
  static const int maxImageSize = 5; // MB
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  static const double imageQuality = 0.8;

  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const int maxReviewLength = 300;

  // Phone Number Configuration
  static const String defaultCountryCode = '+91';
  static const int phoneNumberLength = 10;

  // Time Configuration
  static const List<String> timeSlots = [
    '9:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '12:00 PM - 1:00 PM',
    '1:00 PM - 2:00 PM',
    '2:00 PM - 3:00 PM',
    '3:00 PM - 4:00 PM',
    '4:00 PM - 5:00 PM',
    '5:00 PM - 6:00 PM',
    '6:00 PM - 7:00 PM',
  ];

  // Date Configuration
  static const int maxAdvanceBookingDays = 30;
  static const int minAdvanceBookingHours = 2;

  // Notification Types
  static const String notificationTypeBooking = 'booking';
  static const String notificationTypePayment = 'payment';
  static const String notificationTypePromotion = 'promotion';
  static const String notificationTypeSystem = 'system';

  // Social Login
  static const String googleClientId = 'your-google-client-id';
  static const String facebookAppId = 'your-facebook-app-id';

  // Error Messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String timeoutErrorMessage =
      'Request timeout. Please try again.';
  static const String unauthorizedErrorMessage =
      'Session expired. Please login again.';

  // Success Messages
  static const String bookingSuccessMessage = 'Booking confirmed successfully!';
  static const String paymentSuccessMessage = 'Payment completed successfully!';
  static const String profileUpdateSuccessMessage =
      'Profile updated successfully!';
  static const String reviewSubmitSuccessMessage =
      'Review submitted successfully!';

  // Feature Flags
  static const bool enableDarkMode = true;
  static const bool enableNotifications = true;
  static const bool enableLocationServices = true;
  static const bool enableCrashReporting = true;
  static const bool enableAnalytics = true;

  // App Store URLs
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.localconnect.app';
  static const String appStoreUrl =
      'https://apps.apple.com/app/localconnect/id123456789';

  // Support URLs
  static const String supportEmail = 'support@localconnect.com';
  static const String privacyPolicyUrl = 'https://localconnect.com/privacy';
  static const String termsOfServiceUrl = 'https://localconnect.com/terms';
  static const String helpCenterUrl = 'https://help.localconnect.com';

  // Regular Expressions
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^[6-9]\d{9}$';
  static const String nameRegex = r'^[a-zA-Z\s]+$';
  static const String passwordRegex =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';

  // Currency
  static const String currency = '₹';
  static const String currencyCode = 'INR';

  // Distance Units
  static const String distanceUnit = 'km';
  static const String distanceUnitShort = 'km';

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
  static const String serverDateFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';
}
