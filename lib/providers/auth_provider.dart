import 'package:flutter/foundation.dart';

import '../models/auth/login_model.dart';
import '../models/auth/reset_password_model.dart';
import '../models/auth/send_otp_model.dart';
import '../models/auth/signup_model.dart';
import '../models/auth/verify_otp_model.dart';
import '../services/auth_services.dart';
import '../services/social_login_service.dart';
import '../services/storage_service.dart';
import '../common/utils/app_excpetions.dart';

import 'dart:async';

class AuthProvider with ChangeNotifier {
  final SignupService _service = SignupService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  bool _obscureConfirmPassword = true;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  bool _acceptTerms = false;
  bool get acceptTerms => _acceptTerms;

  bool _rememberMe = false;
  bool get rememberMe => _rememberMe;

  String? _savedEmail;
  String? _savedPassword;
  String? get savedEmail => _savedEmail;
  String? get savedPassword => _savedPassword;

  Timer? _timer;
  int _remainingSeconds = 300; // 5 minutes in seconds
  bool _canResend = false;

  int get remainingSeconds => _remainingSeconds;
  bool get canResend => _canResend;

  Map<String, dynamic>? _response;
  Map<String, dynamic>? get response => _response;

  // Update response with new data (for profile updates)
  void updateResponse(Map<String, dynamic> newData) {
    if (_response == null) {
      _response = Map<String, dynamic>.from(newData);
    } else {
      // Create a deep copy to avoid modifying the original
      _response = Map<String, dynamic>.from(_response!);
      
      // Merge top-level keys (like token)
      newData.forEach((key, value) {
        if (key != 'user') {
          _response![key] = value;
        }
      });
      
      // Handle user object merge
      if (newData['user'] != null) {
        final newUser = newData['user'] as Map<String, dynamic>;
        
        if (_response!['user'] != null) {
          // Merge existing user with new user data
          final existingUser = _response!['user'] as Map<String, dynamic>;
          final updatedUser = Map<String, dynamic>.from(existingUser);
          
          // Update user-level fields (name, email, etc.)
          newUser.forEach((key, value) {
            if (key != 'business_owner_profile') {
              updatedUser[key] = value;
            }
          });
          
          // Handle business_owner_profile merge
          if (newUser['business_owner_profile'] != null) {
            final newProfile = newUser['business_owner_profile'] as Map<String, dynamic>;
            
            if (updatedUser['business_owner_profile'] != null) {
              // Merge existing profile with new profile data
              final existingProfile = updatedUser['business_owner_profile'] as Map<String, dynamic>;
              final updatedProfile = Map<String, dynamic>.from(existingProfile);
              
              // Update all profile fields
              newProfile.forEach((key, value) {
                updatedProfile[key] = value;
              });
              
              updatedUser['business_owner_profile'] = updatedProfile;
            } else {
              // If profile doesn't exist, add it
              updatedUser['business_owner_profile'] = Map<String, dynamic>.from(newProfile);
            }
          }
          
          _response!['user'] = updatedUser;
        } else {
          // If user doesn't exist, add it
          _response!['user'] = Map<String, dynamic>.from(newUser);
        }
      }
    }
    notifyListeners();
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void setAcceptTerms(bool value) {
    _acceptTerms = value;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    // If unchecking remember me, clear saved credentials
    if (!value) {
      StorageService.instance.clearSavedCredentials();
      _savedEmail = null;
      _savedPassword = null;
    }
    notifyListeners();
  }

  /// Load saved credentials from storage
  Future<void> loadSavedCredentials() async {
    try {
      final hasCredentials = await StorageService.instance.hasSavedCredentials();
      if (hasCredentials) {
        _savedEmail = await StorageService.instance.getSavedEmail();
        _savedPassword = await StorageService.instance.getSavedPassword();
        _rememberMe = true;
        notifyListeners();
      }
    } catch (e) {
      print("Error loading saved credentials: $e");
    }
  }

  /// Check if saved credentials exist
  Future<bool> hasSavedCredentials() async {
    return await StorageService.instance.hasSavedCredentials();
  }

  void startTimer() {
    _remainingSeconds = 300;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _canResend = true;
        notifyListeners();
        _timer?.cancel();
      }
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  //Login Function
  Future<bool> loginUser(LoginModel model) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _service.login(model);

      // Check if data is null (which happens when safeApiCall catches an exception)
      if (data == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _response = data;
      
      // Verify user is a business owner
      String? userRole;
      if (data['user'] != null && data['user'] is Map<String, dynamic>) {
        final user = data['user'] as Map<String, dynamic>;
        userRole = user['role']?.toString().toLowerCase();
      }
      
      // Check if user is not a business owner
      if (userRole != null && userRole != 'business_owner') {
        _isLoading = false;
        notifyListeners();
        throw ForbiddenException('Only business owners can access this app. Please use the customer app instead.');
      }
      
      // Extract and save token from response
      if (data.containsKey('token') && data['token'] != null) {
        final token = data['token'] as String;
        await StorageService.instance.saveToken(token);
      }

      // Save credentials if remember me is checked
      if (_rememberMe) {
        await StorageService.instance.saveCredentials(model.email, model.password);
        _savedEmail = model.email;
        _savedPassword = model.password;
      } else {
        // Clear saved credentials if remember me is unchecked
        await StorageService.instance.clearSavedCredentials();
        _savedEmail = null;
        _savedPassword = null;
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } on ForbiddenException catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Login error (Forbidden) → $e");
      rethrow; // Re-throw to handle in login page
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Login error → $e");
      return false;
    }
  }

  //SignUp Function
  Future<bool> registerUser(SignUpModel model) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _service.signUp(model);

      _response = data;
      
      // Extract and save token from response
      if (data.containsKey('token') && data['token'] != null) {
        final token = data['token'] as String;
        await StorageService.instance.saveToken(token);
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      print("Signup error → $e");
      return false;
    }
  }

  //Send OTP Function
  Future<bool> sendOTP(SendOtpModel model) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _service.sendOtp(model);

      _response = data;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      print("Otp sending error → $e");
      return false;
    }
  }

  //Verify OTP Function
  Future<bool> verifyOTP(VerifyOtpModel model) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _service.verifyOtp(model);

      _response = data;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      print("Verification Otp sending error → $e");
      return false;
    }
  }

  //Reset Password Function
  Future<bool> resetPassword(ResetPasswordModel model) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _service.resetPassword(model);

      _response = data;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      print("Reset Password error → $e");
      return false;
    }
  }

  //Delete User Function
  Future<bool> deleteUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _service.deleteUser();

      _response = data;
      _isLoading = false;
      notifyListeners();

      // Clear token from storage
      await StorageService.instance.deleteToken();
      await StorageService.instance.deleteRefreshToken();
      
      // Clear saved credentials
      await StorageService.instance.clearSavedCredentials();
      _savedEmail = null;
      _savedPassword = null;
      
      // Clear response data
      _response = null;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      print("Delete user error → $e");
      return false;
    }
  }

  // //Google Sign-In Function
  // Future<bool> signInWithGoogle() async {
  //   try {
  //     _isLoading = true;
  //     notifyListeners();
  //
  //     final userCredential = await GoogleSignInService.signInWithGoogle();
  //
  //     if (userCredential == null) {
  //       // User cancelled the sign-in
  //       _isLoading = false;
  //       notifyListeners();
  //       return false;
  //     }
  //
  //     final user = userCredential.user;
  //     if (user != null) {
  //       // Extract and save token if available
  //       final idToken = await user.getIdToken();
  //       if (idToken != null) {
  //         await StorageService.instance.saveToken(idToken);
  //         ApiClient.instance.setAuthToken(idToken);
  //       }
  //
  //       _response = {
  //         'uid': user.uid,
  //         'email': user.email,
  //         'name': user.displayName,
  //         'photoURL': user.photoURL,
  //         'token': idToken,
  //       };
  //
  //       _isLoading = false;
  //       notifyListeners();
  //       return true;
  //     }
  //
  //     _isLoading = false;
  //     notifyListeners();
  //     return false;
  //   } catch (e) {
  //     _isLoading = false;
  //     notifyListeners();
  //     print("Google Sign-In error → $e");
  //     return false;
  //   }
  // }
  //
  // //Logout Function
  // Future<void> logout() async {
  //   try {
  //     // Sign out from Google if signed in
  //     await GoogleSignInService.signOut();
  //     // Clear stored tokens
  //     await StorageService.instance.clearAllTokens();
  //     // Remove token from API client
  //     ApiClient.instance.removeAuthToken();
  //     // Clear response data
  //     _response = null;
  //     notifyListeners();
  //   } catch (e) {
  //     print("Logout error → $e");
  //   }
  // }
}
