import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth/login_model.dart';
import '../models/auth/reset_password_model.dart';
import '../models/auth/send_otp_model.dart';
import '../models/auth/signup_model.dart';
import '../models/auth/verify_otp_model.dart';
import '../services/auth_services.dart';
import '../services/social_login_service.dart';
import '../services/notification_service.dart';
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

  String? _authToken;
  String? get authToken => _authToken;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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
      _clearSavedCredentials(); // Fire and forget
      _savedEmail = null;
      _savedPassword = null;
    }
    notifyListeners();
  }

  /// Clear saved credentials
  Future<void> _clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
  }

  /// Load saved credentials from storage
  Future<void> loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasCredentials = prefs.containsKey('saved_email') && prefs.containsKey('saved_password');
      if (hasCredentials) {
        _savedEmail = prefs.getString('saved_email');
        _savedPassword = prefs.getString('saved_password');
        _rememberMe = true;
        notifyListeners();
      }
    } catch (e) {
      print("Error loading saved credentials: $e");
    }
  }

  /// Check if saved credentials exist
  Future<bool> hasSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('saved_email') && prefs.containsKey('saved_password');
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
      }

      // Save credentials if remember me is checked
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', model.email);
        await prefs.setString('saved_password', model.password);
        _savedEmail = model.email;
        _savedPassword = model.password;
      } else {
        // Clear saved credentials if remember me is unchecked
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('refresh_token');
      
      // Clear saved credentials
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
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

  //Google Sign-In Function
  // Follows the reference pattern - authenticates with Google and gets user info
  // No backend API call required
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Step 1: Clear any previous Google sign-in state to ensure fresh account selection
      // This ensures that if user logged out and wants to use a different account,
      // they get the account picker instead of auto-signing in with previous account
      try {
        await GoogleSignInService.signOut();
      } catch (e) {
        // Ignore errors - might already be signed out
        print("Pre-signin cleanup (expected if not signed in): $e");
      }

      // Step 2: Initialize Google Sign-In (fresh initialization)
      await GoogleSignInService.initialize();

      // Step 3: Sign in with Google (will show account picker)
      final googleUser = await GoogleSignInService.signIn();

      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Step 4: Get authentication tokens
      final tokens = await GoogleSignInService.getAuthenticationTokens(googleUser);

      if (tokens == null || tokens['idToken'] == null) {
        _isLoading = false;
        _errorMessage = "Failed to get Google authentication tokens";
        notifyListeners();
        print("Failed to get Google authentication tokens");
        return false;
      }

      // Step 5: Get FCM token
      final fcmToken = await NotificationService().getFcmToken();
      print("FCM Token retrieved: ${fcmToken ?? 'null'}");

      // Step 6: Send email to backend and get your app's token
      final backendResponse = await SignupService.googleSignIn(
        email: googleUser.email,
        name: googleUser.displayName,
        googleId: googleUser.id,
        idToken: tokens['idToken'], // Send for backend verification
        fcmToken: fcmToken, // Send FCM token
      );

      if (backendResponse == null) {
        _isLoading = false;
        _errorMessage = "Failed to authenticate with backend";
        notifyListeners();
        print("Failed to authenticate with backend");
        return false;
      }

      if (backendResponse['error'] != null || backendResponse['status'] == 'error') {
        _isLoading = false;
        _errorMessage = backendResponse['message'] ?? 'Authentication failed';
        notifyListeners();
        return false;
      }

      // Step 7: Store the backend token and user data
      _authToken = backendResponse['token']; // Get token from backend
      _response = backendResponse;

      if (_authToken == null || _authToken!.isEmpty) {
        _isLoading = false;
        _errorMessage = "No token received from backend";
        notifyListeners();
        return false;
      }

      // Save token to SharedPreferences - this is critical for API calls
      await _saveTokenToStorage(_authToken!);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      print("Google Sign-In error → $e");
      return false;
    }
  }

  /// Save token to local storage using SharedPreferences
  Future<void> _saveTokenToStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  /// Sign out - Clear all tokens and user data
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await GoogleSignInService.signOut();
      
      // Clear auth token and response
      _authToken = null;
      _response = null;
      _errorMessage = null;
      _savedEmail = null;
      _savedPassword = null;
      _rememberMe = false;

      // Clear all tokens and auth-related data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token'); // Main auth token
      await prefs.remove('refresh_token'); // Refresh token if exists
      await prefs.remove('auth_token'); // Legacy token key if exists
      
      // Clear saved credentials
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      
      // Clear cookie if exists (used for device authentication)
      await prefs.remove('Cookie');

      notifyListeners();
    } catch (e) {
      print("Sign out error: $e");
      // Still clear local state even if storage clearing fails
      _authToken = null;
      _response = null;
      _errorMessage = null;
      _savedEmail = null;
      _savedPassword = null;
      _rememberMe = false;
      notifyListeners();
    }
  }

}
