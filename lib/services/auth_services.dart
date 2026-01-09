import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lead_flow_business/common/constants/app_url.dart';
import 'package:lead_flow_business/common/utils/request_provider.dart';
import 'package:lead_flow_business/common/utils/app_excpetions.dart';

import '../../models/auth/signup_model.dart';
import '../common/constants/app_constants.dart';
import '../models/auth/login_model.dart';
import '../models/auth/reset_password_model.dart';
import '../models/auth/send_otp_model.dart';
import '../models/auth/verify_otp_model.dart';


String? _extractEmailFromJWT(String? identityToken) {
  if (identityToken == null || identityToken.isEmpty) return null;

  try {
    // JWT format: header.payload.signature
    final parts = identityToken.split('.');
    if (parts.length != 3) return null;

    // Decode the payload (second part)
    final payload = parts[1];

    // Add padding if needed (base64url decoding)
    String normalizedPayload = payload;
    final remainder = payload.length % 4;
    if (remainder > 0) {
      normalizedPayload += '=' * (4 - remainder);
    }

    // Replace URL-safe characters
    normalizedPayload = normalizedPayload.replaceAll('-', '+').replaceAll('_', '/');

    // Decode base64
    final decodedBytes = base64Decode(normalizedPayload);
    final decodedString = utf8.decode(decodedBytes);
    final payloadMap = jsonDecode(decodedString) as Map<String, dynamic>;

    // Extract email from payload
    return payloadMap['email'] as String?;
  } catch (e) {
    print('Error extracting email from JWT: $e');
    return null;
  }
}
/// Sign Up Service
/// Handles user registration API calls
class SignupService {
  //Login Service
  Future<Map<String, dynamic>> login(LoginModel model) async {
    try {
      final data = await RequestProvider.post(
        url: AppUrl.login,
        body: model.toJson(),
      );

      // If data is null, it means safeApiCall caught an exception
      // For login, if we get null, it's likely a 403 Forbidden (user not a business owner)
      // We throw ForbiddenException so the provider can handle it properly
      if (data == null) {
        throw ForbiddenException('User is not a business owner.');
      }

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw UnknownException('Invalid response format');
      }
    } on ForbiddenException {
      // Re-throw ForbiddenException so provider can handle it
      rethrow;
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is ForbiddenException) rethrow;
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Login failed: ${e.toString()}');
    }
  }

  //SignUp Service
  Future<Map<String, dynamic>> signUp(SignUpModel model) async {
    try {
      final data = await RequestProvider.post(
        url: AppUrl.signup,
        body: model.toJson(),
      );

      if (data == null) {
        throw UnknownException('Signup failed: No response from server');
      }

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw UnknownException('Invalid response format');
      }
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Signup failed: ${e.toString()}');
    }
  }

  //Send OTP Service
  Future<Map<String, dynamic>> sendOtp(SendOtpModel model) async {
    try {
      final data = await RequestProvider.post(
        url: AppUrl.sendOtp,
        body: model.toJson(),
      );

      if (data == null) {
        throw UnknownException('Sending OTP failed: No response from server');
      }

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw UnknownException('Invalid response format');
      }
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Sending Otp failed: ${e.toString()}');
    }
  }

  //Verify OTP Service
  Future<Map<String, dynamic>> verifyOtp(VerifyOtpModel model) async {
    try {
      final data = await RequestProvider.post(
        url: AppUrl.verifyOTP,
        body: model.toJson(),
      );

      if (data == null) {
        throw UnknownException('Verification OTP failed: No response from server');
      }

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw UnknownException('Invalid response format');
      }
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Verification Otp failed: ${e.toString()}');
    }
  }

  //Reset Password Service
  Future<Map<String, dynamic>> resetPassword(ResetPasswordModel model) async {
    try {
      final data = await RequestProvider.post(
        url: AppUrl.updatePassword,
        body: model.toJson(),
      );

      if (data == null) {
        throw UnknownException('Reset password failed: No response from server');
      }

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw UnknownException('Invalid response format');
      }
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Reset Password failed: ${e.toString()}');
    }
  }

  //Delete User Service
  Future<Map<String, dynamic>> deleteUser() async {
    try {
      final data = await RequestProvider.delete(
        url: AppUrl.deleteUser,
      );

      // For DELETE requests, null response might be valid (204 No Content)
      if (data == null) {
        return {'success': true, 'message': 'User deleted successfully'};
      }

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        return {'success': true, 'message': 'User deleted successfully'};
      }
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Delete user failed: ${e.toString()}');
    }
  }
  static Future<Map<String, dynamic>?> googleSignIn({
    required String email,
    String? name,
    String? googleId,
    String? idToken,
    String? fcmToken,
  }) async {
    try {
      // Prepare request body
      final requestBody = {
        'email': email,
        'name': name,
        'google_id': googleId,
        'id_token': idToken, // Backend can verify this token with Google
        'fcm_token': fcmToken ?? '', // Always include fcm_token, even if empty
      };
      
      print('Google Sign-In Request Body: ${jsonEncode(requestBody)}');
      
      final response = await RequestProvider.post(
        url: '${AppConstants.baseUrl}/users/google-signin/business-owner/',
        body: jsonEncode(requestBody),
      );

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Google Sign-In API error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> appleSignIn({
    required String identityToken,
    required String authorizationCode,
    String? email,
    String? fullName,
    String? userId,
    String? fcmToken,
  }) async {
    try {
      // Extract email from JWT if not provided by Apple
      String? finalEmail = email;
      if (finalEmail == null || finalEmail.isEmpty) {
        finalEmail = _extractEmailFromJWT(identityToken);
      }

      // Prepare request body
      // Note: email might be null on first sign-in if user chose to hide it
      // We try to extract it from identity_token (JWT), but backend should also handle this
      final requestBody = {
        'identity_token': identityToken,
        'authorization_code': authorizationCode,
        'email': finalEmail ?? '', // Always include email field (extract from JWT if needed)
        if (fullName != null && fullName.isNotEmpty) 'name': fullName,
        if (userId != null && userId.isNotEmpty) 'apple_user_id': userId,
        'fcm_token': fcmToken ?? '', // Always include fcm_token, even if empty
      };

      print('Apple Sign-In Request Body: ${jsonEncode(requestBody)}');

      final response = await RequestProvider.post(
        url: AppUrl.appleSignIn,
        body: jsonEncode(requestBody),
      );

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Apple Sign-In API error: $e');
      return null;
    }
  }
}


