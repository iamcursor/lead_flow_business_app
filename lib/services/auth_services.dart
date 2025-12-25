import 'package:lead_flow_business/common/constants/app_url.dart';
import 'package:lead_flow_business/common/utils/request_provider.dart';
import 'package:lead_flow_business/common/utils/app_excpetions.dart';

import '../../models/auth/signup_model.dart';
import '../models/auth/login_model.dart';
import '../models/auth/reset_password_model.dart';
import '../models/auth/send_otp_model.dart';
import '../models/auth/verify_otp_model.dart';

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
}
