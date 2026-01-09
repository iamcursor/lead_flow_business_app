// import 'dart:async';
// import 'dart:convert';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;
//
// /// Google Sign-In Service Class
// class GoogleSignInService {
//   static StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;
//   static bool _isInitialized = false;
//   static GoogleSignInAccount? _currentUser;
//
//   /// Initialize Google Sign-In
//   static Future<void> initialize() async {
//     if (_isInitialized) return;
//
//     final GoogleSignIn signIn = GoogleSignIn.instance;
//     await signIn.initialize();
//
//     _authSubscription?.cancel();
//     _authSubscription = signIn.authenticationEvents.listen(
//           (GoogleSignInAuthenticationEvent event) {
//         switch (event) {
//           case GoogleSignInAuthenticationEventSignIn():
//             _currentUser = event.user;
//           case GoogleSignInAuthenticationEventSignOut():
//             _currentUser = null;
//         }
//       },
//       onError: (error) {
//         print("Google Sign-In authentication event error: $error");
//       },
//     );
//
//     await signIn.attemptLightweightAuthentication();
//     _isInitialized = true;
//   }
//
//   /// Sign in with Google
//   static Future<GoogleSignInAccount?> signIn() async {
//     try {
//       if (!_isInitialized) {
//         await initialize();
//       }
//
//       final GoogleSignIn signIn = GoogleSignIn.instance;
//
//       if (!signIn.supportsAuthenticate()) {
//         throw Exception('Google Sign-In is not supported on this platform');
//       }
//
//       // Clear any cached user before signing in to force account selection
//       _currentUser = null;
//
//       // Sign out first to ensure we get a fresh account selection
//       // This ensures the user can choose a different account
//       try {
//         await signIn.signOut();
//       } catch (e) {
//         // Ignore errors if already signed out
//         print("Sign out before sign in (expected if not signed in): $e");
//       }
//
//       // Now authenticate - this will show account picker
//       // authenticate() returns GoogleSignInAccount? directly
//       final googleUser = await signIn.authenticate();
//
//       if (googleUser != null) {
//         // Update cached user
//         _currentUser = googleUser;
//         return googleUser;
//       }
//
//       // Authentication was cancelled or failed
//       return null;
//     } on GoogleSignInException catch (e) {
//       if (e.code == GoogleSignInExceptionCode.canceled) {
//         print("Google sign in canceled by user");
//       } else {
//         print("Google sign in error: ${e.code} - ${e.description}");
//       }
//       return null;
//     } catch (e) {
//       print("Google sign in error: $e");
//       return null;
//     }
//   }
//
//   /// Get authentication tokens
//   static Future<Map<String, String?>?> getAuthenticationTokens(
//       GoogleSignInAccount user,
//       ) async {
//     try {
//       final GoogleSignInAuthentication auth = await user.authentication;
//       return {
//         'idToken': auth.idToken,
//       };
//     } catch (e) {
//       print("Error getting authentication tokens: $e");
//       return null;
//     }
//   }
//
//   /// Sign out from Google
//   static Future<void> signOut() async {
//     try {
//       final GoogleSignIn signIn = GoogleSignIn.instance;
//       // First disconnect to revoke access
//       await signIn.disconnect();
//       // Then sign out to clear the account selection
//       await signIn.signOut();
//       // Clear cached user
//       _currentUser = null;
//       // Reset initialization state to force fresh account selection next time
//       _isInitialized = false;
//     } catch (e) {
//       print("Google sign out error: $e");
//       // Even if there's an error, clear our cached state
//       _currentUser = null;
//       _isInitialized = false;
//     }
//   }
//
//   /// Get current user
//   static GoogleSignInAccount? getCurrentUser() {
//     return _currentUser;
//   }
//
//   /// Dispose resources
//   static void dispose() {
//     _authSubscription?.cancel();
//     _authSubscription = null;
//     _currentUser = null;
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // Add this import

/// Google Sign-In Service Class
class GoogleSignInService {
  static StreamSubscription? _authSubscription;
  static bool _isInitialized = false;
  static GoogleSignInAccount? _currentUser;
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Add Firebase Auth instance

  /// Initialize Google Sign-In
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final GoogleSignIn signIn = GoogleSignIn.instance;
    await signIn.initialize();

    _authSubscription?.cancel();
    _authSubscription = signIn.authenticationEvents.listen(
          (GoogleSignInAuthenticationEvent event) {
        switch (event) {
          case GoogleSignInAuthenticationEventSignIn():
            _currentUser = event.user;
          case GoogleSignInAuthenticationEventSignOut():
            _currentUser = null;
        }
      },
      onError: (error) {
        print("Google Sign-In authentication event error: $error");
      },
    );

    await signIn.attemptLightweightAuthentication();
    _isInitialized = true;
  }

  /// Sign in with Google
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final GoogleSignIn signIn = GoogleSignIn.instance;

      if (!signIn.supportsAuthenticate()) {
        throw Exception('Google Sign-In is not supported on this platform');
      }

      // Clear any cached user before signing in to force account selection
      _currentUser = null;

      // Sign out first to ensure we get a fresh account selection
      try {
        await signIn.signOut();
      } catch (e) {
        print("Sign out before sign in (expected if not signed in): $e");
      }

      // Now authenticate - this will show account picker
      final googleUser = await signIn.authenticate();

      if (googleUser != null) {
        // Update cached user
        _currentUser = googleUser;

        // ===== FIREBASE INTEGRATION STARTS HERE =====
        // Get the authentication tokens
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create a new credential for Firebase
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        try {
          final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

          print("Firebase sign-in successful: ${userCredential.user?.email}");
          print("Firebase UID: ${userCredential.user?.uid}");
        } catch (firebaseError) {
          print("Firebase sign-in error: $firebaseError");
          // Continue even if Firebase fails - your backend auth still works
        }
        // ===== FIREBASE INTEGRATION ENDS HERE =====

        return googleUser;
      }

      return null;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        print("Google sign in canceled by user");
      } else {
        print("Google sign in error: ${e.code} - ${e.description}");
      }
      return null;
    } catch (e) {
      print("Google sign in error: $e");
      return null;
    }
  }

  /// Get authentication tokens
  static Future<Map<String, dynamic>?> getAuthenticationTokens(
      GoogleSignInAccount user,
      ) async {
    try {
      final GoogleSignInAuthentication auth = await user.authentication;
      return {
        'idToken': auth.idToken,
      };
    } catch (e) {
      print("Error getting authentication tokens: $e");
      return null;
    }
  }

  /// Sign out from Google
  static Future<void> signOut() async {
    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;

      // Sign out from Firebase first
      await _firebaseAuth.signOut();

      // First disconnect to revoke access
      await signIn.disconnect();

      // Then sign out to clear the account selection
      await signIn.signOut();

      // Clear cached user
      _currentUser = null;

      // Reset initialization state to force fresh account selection next time
      _isInitialized = false;
    } catch (e) {
      print("Google sign out error: $e");
      // Even if there's an error, clear our cached state
      _currentUser = null;
      _isInitialized = false;
    }
  }

  /// Get current user
  static GoogleSignInAccount? getCurrentUser() {
    return _currentUser;
  }

  /// Get current Firebase user
  static User? getFirebaseUser() {
    return _firebaseAuth.currentUser;
  }

  /// Dispose resources
  static void dispose() {
    _authSubscription?.cancel();
    _authSubscription = null;
    _currentUser = null;
  }
}