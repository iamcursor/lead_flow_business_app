import 'app_constants.dart';

class AppUrl{

  //Base Url
  static const String baseUrl = 'https://leadflow.techaelia.com';


  // Authentication Endpoints
  static const String login = '$baseUrl/users/login/';
  static const String signup = '$baseUrl/users/signup/';
  static const String sendOtp = '$baseUrl/users/send-otp/';
  static const String updatePassword = '$baseUrl/users/update-password/';
  static const String verifyOTP = '$baseUrl/users/verify-otp/';
  static const String resendOTP = '$baseUrl/auth/resend-otp';
  static const String deleteUser = '$baseUrl/users/delete-user/';
  static const String appleSignIn = '$baseUrl/users/apple-signin/business-owner/';
  
  // Bookings
  static const String bookings = '$baseUrl/api/bookings/';
  static const String dashboard = '$baseUrl/api/bookings/dashboard/';
  static String updateBookingStatus(String bookingId) => '$baseUrl/booking/$bookingId/update-status/';

  // User Profile Endpoints
  static const String getBusinessOwnerProfile = '$baseUrl/users/business-owner-profile/';
  static const String updateBusinessOwnerProfile = '$baseUrl/users/business-owner-profile/update/';
  static const String changePassword = '$baseUrl/users/change-password/';

  // Service Categories Endpoints
  static const String mainServiceCategories = '$baseUrl/api/services/main-categories/';
  static const String subServiceCategories = '$baseUrl/api/services/sub-categories/';

  // AI/Verification Endpoints
  static const String analyzeFile = '$baseUrl/ai/analyze-file/';

  //Earning Endpoints
  static const String earnings = '$baseUrl/earnings/';

  // Payment Endpoints
  static const String createCheckoutSession = '$baseUrl/api/payments/create-checkout-session/';

  // Chat Endpoints
  static const String chatRooms = '$baseUrl/chat/api/rooms/';
  static const String chatMessages = '$baseUrl/chat/api/rooms/messages/';
  static const String markMessagesRead = '$baseUrl/chat/api/rooms/mark-read/';
  static const String sendMessage = '$baseUrl/chat/api/messages/send/';
  static const String getChatRooms = '$baseUrl/chat/api/rooms/';
  static const String getRoomMessages = '$baseUrl/chat/api/rooms/messages/';
  static const String createChatRoom = '$baseUrl/chat/api/rooms/';
  static const String searchUsers = '$baseUrl/chat/api/users/search/';
}