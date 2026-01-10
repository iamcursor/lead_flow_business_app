import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lead_flow_business/screens/auth/forgot_password_page.dart';
import 'package:lead_flow_business/screens/auth/register_page.dart';
import 'package:lead_flow_business/screens/explore/explore_page.dart';
import 'package:lead_flow_business/screens/main_navigation_screen.dart';
import 'package:lead_flow_business/screens/profile/complete_profile_page.dart';
import 'package:lead_flow_business/screens/profile/waiting_for_approval_page.dart';

import 'package:provider/provider.dart';
import '../../models/auth/login_model.dart';
import '../../providers/auth_provider.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../common/utils/app_excpetions.dart';

/// Login Page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load saved credentials after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedCredentials();
    });
  }

  Future<void> _loadSavedCredentials() async {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    await provider.loadSavedCredentials();
    
    // If saved credentials exist, populate the fields
    if (provider.savedEmail != null && provider.savedPassword != null) {
      _emailController.text = provider.savedEmail!;
      _passwordController.text = provider.savedPassword!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return PopScope(
          canPop: !authProvider.isLoading,
          onPopInvoked: (didPop) {
            // Prevent back navigation when loading
            if (authProvider.isLoading && didPop) {
              // This shouldn't happen due to canPop, but just in case
            }
          },
          child: Scaffold(
            body: Stack(
              children: [
                SingleChildScrollView(
            padding: EdgeInsets.all(AppDimensions.screenPaddingTop),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppDimensions.verticalSpaceL),
                  Text('Hi, Welcome!', style: AppTextStyles.appBarTitle.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  )),
                  SizedBox(height: AppDimensions.verticalSpaceL),
                  // Email Field
                  Text('Email address', style: AppTextStyles.labelLarge.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  )),
                  SizedBox(height: AppDimensions.verticalSpaceS),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: const InputDecoration(hintText: 'Your email'),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: AppDimensions.verticalSpaceL),

                  // Password Field
                  Text('Password', style: AppTextStyles.labelLarge.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  )),
                  SizedBox(height: AppDimensions.verticalSpaceS),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: authProvider.obscurePassword,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          authProvider.toggleObscurePassword();
                        },
                        icon: Icon(
                          authProvider.obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: AppDimensions.verticalSpaceM),

                  // Remember Me & Forgot Password
                  Row(
                    children: [
                      Checkbox(
                        value: authProvider.rememberMe,
                        onChanged: (value) {
                          authProvider.setRememberMe(value ?? false);
                        },
                      ),
                      Text('Remember me', style: AppTextStyles.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      )),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage(),)),
                        child: Text(
                          'Forgot password?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppDimensions.verticalSpaceXL),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                      ),
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      child: Text('Login', style: AppTextStyles.buttonLarge),
                    ),
                  ),

                  SizedBox(height: AppDimensions.verticalSpaceXL),

                  // Or with
                  Center(
                    child: Text(
                      'Or Login With',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),

                  SizedBox(height: AppDimensions.verticalSpaceL),

                  // Social Login Buttons
                  Column(
                    children: [
                      // Google Login Button

                      if (Platform.isAndroid)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _handleGoogleSignIn(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                            foregroundColor: Theme.of(context).colorScheme.onSurface,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.buttonRadius,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.paddingM,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google Logo
                              Image.asset("assets/images/google.png",
                                height: 20, width: 20,),

                              SizedBox(width: AppDimensions.paddingM),
                              Text(
                                'Continue with Google',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimensions.verticalSpaceM),
                      // Apple Login Button
                      if (Platform.isIOS)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _handleAppleSignIn(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                            foregroundColor: Theme.of(context).colorScheme.onSurface,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.buttonRadius,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.paddingM,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Apple Logo
                              Icon(
                                Icons.apple,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 24,
                              ),
                              SizedBox(width: AppDimensions.paddingM),
                              Text(
                                'Continue with Apple',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppDimensions.verticalSpaceL),

                  // Sign up option
                  Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontSize: 18.w,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage(),)),
                            child: Text(
                              'Sign up',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 18.w,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ]
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Loader Overlay
          if (authProvider.isLoading)
            Container(
              color: AppColors.overlayLight,
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Hide keyboard when API is hit
      FocusScope.of(context).unfocus();
      
      final provider = Provider.of<AuthProvider>(context, listen: false);

      // Create model from your controllers
      final model = LoginModel(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      try {
        final success = await provider.loginUser(model);

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed. Please try again')),
          );
          return;
        }
      } on ForbiddenException catch (e) {
        // Extract user-friendly error message
        String errorMessage = 'Only business owners can access this app. Please use the customer app instead.';
        final errorString = e.toString();
        
        // Try to extract message from error string
        if (errorString.contains('{"message":')) {
          try {
            final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(errorString);
            if (jsonMatch != null) {
              final json = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
              if (json.containsKey('message')) {
                errorMessage = json['message'].toString();
              }
            }
          } catch (_) {
            // Use default message if parsing fails
          }
        } else if (errorString.contains('business owner') || errorString.contains('User is not a business owner')) {
          errorMessage = 'Only business owners can access this app.';
        } else if (errorString.contains('Forbidden')) {
          errorMessage = 'Access denied. Only business owners can use this app.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check verification status from login response
      final response = provider.response;
      String? verificationStatus;
      
      // Check various possible locations for verification status
      if (response != null) {
        // Check direct fields
        verificationStatus = response['verification_status']?.toString().toLowerCase() ?? 
                            response['approval_status']?.toString().toLowerCase() ?? 
                            response['status']?.toString().toLowerCase();
        
        // Check nested in user object
        if (verificationStatus == null && response['user'] != null) {
          final user = response['user'] as Map<String, dynamic>?;
          
          // Check in user object directly
          verificationStatus = user?['verification_status']?.toString().toLowerCase() ?? 
                             user?['approval_status']?.toString().toLowerCase() ?? 
                             user?['status']?.toString().toLowerCase();
          
          // Check nested in business_owner_profile within user object
          if (verificationStatus == null && user?['business_owner_profile'] != null) {
            final profile = user!['business_owner_profile'] as Map<String, dynamic>?;
            verificationStatus = profile?['verification_status']?.toString().toLowerCase() ?? 
                               profile?['approval_status']?.toString().toLowerCase() ?? 
                               profile?['status']?.toString().toLowerCase();
          }
        }
        
        // Check nested in business_owner_profile at root level (fallback)
        if (verificationStatus == null && response['business_owner_profile'] != null) {
          final profile = response['business_owner_profile'] as Map<String, dynamic>?;
          verificationStatus = profile?['verification_status']?.toString().toLowerCase() ?? 
                             profile?['approval_status']?.toString().toLowerCase() ?? 
                             profile?['status']?.toString().toLowerCase();
        }
      }

      // Navigate based on verification status
      if (verificationStatus == 'pending' || verificationStatus == 'waiting') {
        // Redirect to waiting for approval screen
        Navigator.push(context, MaterialPageRoute(builder: (context) => WaitingForApprovalPage(),));
      } else {
        // Redirect to main navigation screen (Bookings is now the default)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainNavigationScreen(),));
      }
    }
  }

  void _handleGoogleSignIn(BuildContext context) async {
    // Hide keyboard when API is hit
    FocusScope.of(context).unfocus();
    
    final provider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await provider.signInWithGoogle();

      if (!success) {
        final errorMessage = provider.errorMessage ?? 'Google Sign-In failed. Please try again';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }

      // Google Sign-In successful and backend authenticated
      // Token is now stored in provider.authToken
      
      // Check if user has a complete profile by checking ALL required fields in business_owner_profile
      final response = provider.response;
      bool hasCompleteProfile = false;
      String? verificationStatus;
      Map<String, dynamic>? profile;
      
      if (response != null && response['user'] != null) {
        final user = response['user'] as Map<String, dynamic>?;
        
        // Check if business_owner_profile exists
        if (user?['business_owner_profile'] != null) {
          profile = user!['business_owner_profile'] as Map<String, dynamic>?;
          
          // Get verification status from profile
          verificationStatus = profile?['verification_status']?.toString().toLowerCase() ?? 
                             profile?['approval_status']?.toString().toLowerCase() ?? 
                             profile?['status']?.toString().toLowerCase();
          
          // Check if ALL key required fields are filled (not null/empty)
          final hasGender = profile?['gender'] != null && profile!['gender'].toString().isNotEmpty;
          final hasDateOfBirth = profile?['date_of_birth'] != null && profile!['date_of_birth'].toString().isNotEmpty;
          final hasPrimaryServiceCategory = profile?['primary_service_category'] != null && profile!['primary_service_category'].toString().isNotEmpty;
          final hasCity = profile?['city'] != null && profile!['city'].toString().isNotEmpty;
          final hasYearsOfExperience = profile?['years_of_experience'] != null;
          final hasIdProofType = profile?['id_proof_type'] != null && profile!['id_proof_type'].toString().isNotEmpty;
          final hasRecentPhoto = profile?['recent_photo'] != null && profile!['recent_photo'].toString().isNotEmpty;
          final hasAlternatePhone = profile?['alternate_phone'] != null && profile!['alternate_phone'].toString().isNotEmpty;
          
          // Profile is complete ONLY if ALL required fields are filled
          hasCompleteProfile = hasGender && hasDateOfBirth && hasPrimaryServiceCategory && 
                              hasCity && hasYearsOfExperience && hasIdProofType && 
                              hasRecentPhoto && hasAlternatePhone;
        }
      }
      
      // Check root level business_owner_profile as fallback
      if (profile == null && response != null && response['business_owner_profile'] != null) {
        profile = response['business_owner_profile'] as Map<String, dynamic>?;
        verificationStatus = profile?['verification_status']?.toString().toLowerCase() ?? 
                           profile?['approval_status']?.toString().toLowerCase() ?? 
                           profile?['status']?.toString().toLowerCase();
        
        // Check if ALL key required fields are filled (not null/empty)
        final hasGender = profile?['gender'] != null && profile!['gender'].toString().isNotEmpty;
        final hasDateOfBirth = profile?['date_of_birth'] != null && profile!['date_of_birth'].toString().isNotEmpty;
        final hasPrimaryServiceCategory = profile?['primary_service_category'] != null && profile!['primary_service_category'].toString().isNotEmpty;
        final hasCity = profile?['city'] != null && profile!['city'].toString().isNotEmpty;
        final hasYearsOfExperience = profile?['years_of_experience'] != null;
        final hasIdProofType = profile?['id_proof_type'] != null && profile!['id_proof_type'].toString().isNotEmpty;
        final hasRecentPhoto = profile?['recent_photo'] != null && profile!['recent_photo'].toString().isNotEmpty;
        final hasAlternatePhone = profile?['alternate_phone'] != null && profile!['alternate_phone'].toString().isNotEmpty;
        
        // Profile is complete ONLY if ALL required fields are filled
        hasCompleteProfile = hasGender && hasDateOfBirth && hasPrimaryServiceCategory && 
                            hasCity && hasYearsOfExperience && hasIdProofType && 
                            hasRecentPhoto && hasAlternatePhone;
      }

      // Navigate based on profile completion status
      if (!hasCompleteProfile) {
        // Profile is incomplete (any field is missing) - go to complete profile page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CompleteProfilePage(),
          ),
        );
      } else {
        // User has complete profile (ALL fields filled) - check verification status
        if (verificationStatus == 'pending' || verificationStatus == 'waiting') {
          // Redirect to waiting for approval screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WaitingForApprovalPage()),
          );
        } else {
          // User is registered and verified - go to main navigation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(initialIndex: 0),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleAppleSignIn(BuildContext context) async {
    // Hide keyboard when API is hit
    FocusScope.of(context).unfocus();

    final provider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await provider.signInWithApple();

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apple Sign-In failed. Please try again'),
          ),
        );
        return;
      }

      // Apple Sign-In successful and backend authenticated
      // Token is now stored in provider.authToken

      // Check if user has a complete profile by checking ALL required fields in business_owner_profile
      final response = provider.response;
      bool hasCompleteProfile = false;
      String? verificationStatus;
      Map<String, dynamic>? profile;

      if (response != null && response['user'] != null) {
        final user = response['user'] as Map<String, dynamic>?;

        // Check if business_owner_profile exists
        if (user?['business_owner_profile'] != null) {
          profile = user!['business_owner_profile'] as Map<String, dynamic>?;

          // Get verification status from profile
          verificationStatus = profile?['verification_status']?.toString().toLowerCase() ??
              profile?['approval_status']?.toString().toLowerCase() ??
              profile?['status']?.toString().toLowerCase();

          // Check if ALL key required fields are filled (not null/empty)
          final hasGender = profile?['gender'] != null && profile!['gender'].toString().isNotEmpty;
          final hasDateOfBirth = profile?['date_of_birth'] != null && profile!['date_of_birth'].toString().isNotEmpty;
          final hasPrimaryServiceCategory = profile?['primary_service_category'] != null && profile!['primary_service_category'].toString().isNotEmpty;
          final hasCity = profile?['city'] != null && profile!['city'].toString().isNotEmpty;
          final hasYearsOfExperience = profile?['years_of_experience'] != null;
          final hasIdProofType = profile?['id_proof_type'] != null && profile!['id_proof_type'].toString().isNotEmpty;
          final hasRecentPhoto = profile?['recent_photo'] != null && profile!['recent_photo'].toString().isNotEmpty;
          final hasAlternatePhone = profile?['alternate_phone'] != null && profile!['alternate_phone'].toString().isNotEmpty;

          // Profile is complete ONLY if ALL required fields are filled
          hasCompleteProfile = hasGender && hasDateOfBirth && hasPrimaryServiceCategory &&
              hasCity && hasYearsOfExperience && hasIdProofType &&
              hasRecentPhoto && hasAlternatePhone;
        }
      }

      // Check root level business_owner_profile as fallback
      if (profile == null && response != null && response['business_owner_profile'] != null) {
        profile = response['business_owner_profile'] as Map<String, dynamic>?;
        verificationStatus = profile?['verification_status']?.toString().toLowerCase() ??
            profile?['approval_status']?.toString().toLowerCase() ??
            profile?['status']?.toString().toLowerCase();

        // Check if ALL key required fields are filled (not null/empty)
        final hasGender = profile?['gender'] != null && profile!['gender'].toString().isNotEmpty;
        final hasDateOfBirth = profile?['date_of_birth'] != null && profile!['date_of_birth'].toString().isNotEmpty;
        final hasPrimaryServiceCategory = profile?['primary_service_category'] != null && profile!['primary_service_category'].toString().isNotEmpty;
        final hasCity = profile?['city'] != null && profile!['city'].toString().isNotEmpty;
        final hasYearsOfExperience = profile?['years_of_experience'] != null;
        final hasIdProofType = profile?['id_proof_type'] != null && profile!['id_proof_type'].toString().isNotEmpty;
        final hasRecentPhoto = profile?['recent_photo'] != null && profile!['recent_photo'].toString().isNotEmpty;
        final hasAlternatePhone = profile?['alternate_phone'] != null && profile!['alternate_phone'].toString().isNotEmpty;

        // Profile is complete ONLY if ALL required fields are filled
        hasCompleteProfile = hasGender && hasDateOfBirth && hasPrimaryServiceCategory &&
            hasCity && hasYearsOfExperience && hasIdProofType &&
            hasRecentPhoto && hasAlternatePhone;
      }

      // Navigate based on profile completion status
      if (!hasCompleteProfile) {
        // Profile is incomplete (any field is missing) - go to complete profile page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CompleteProfilePage(),
          ),
        );
      } else {
        // User has complete profile (ALL fields filled) - check verification status
        if (verificationStatus == 'pending' || verificationStatus == 'waiting') {
          // Redirect to waiting for approval screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WaitingForApprovalPage()),
          );
        } else {
          // User is registered and verified - go to main navigation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(initialIndex: 0),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Apple Sign-In failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}


