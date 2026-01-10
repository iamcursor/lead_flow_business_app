import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lead_flow_business/screens/profile/complete_profile_page.dart';
import '../../models/auth/signup_model.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../main_navigation_screen.dart';
import '../profile/waiting_for_approval_page.dart';
import 'login_page.dart';

/// Register Page
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
              // Main Content
              SingleChildScrollView(
                padding: EdgeInsets.all(AppDimensions.screenPaddingTop),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppDimensions.verticalSpaceL),

                      Text('Create Account', style: AppTextStyles.appBarTitle.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      )),
                      SizedBox(height: AppDimensions.verticalSpaceL),
                      // Email Field
                      Text('Email', style: AppTextStyles.labelLarge.copyWith(
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
                        enabled: !authProvider.isLoading,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: AppDimensions.verticalSpaceL),

                      // Password Field
                      Text('Create a password', style: AppTextStyles.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      )),
                      SizedBox(height: AppDimensions.verticalSpaceS),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: authProvider.obscurePassword,
                        enabled: !authProvider.isLoading,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter password',
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
                            return 'Please enter a password';
                          }
                          if (value!.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: AppDimensions.verticalSpaceL),

                      // Confirm Password Field
                      Text('Confirm password', style: AppTextStyles.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      )),
                      SizedBox(height: AppDimensions.verticalSpaceS),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: authProvider.obscureConfirmPassword,
                        enabled: !authProvider.isLoading,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Re-enter password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              authProvider.toggleObscureConfirmPassword();
                            },
                            icon: Icon(
                              authProvider.obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: AppDimensions.verticalSpaceM),

                      // Terms and Privacy
                      Row(
                        children: [
                          Checkbox(
                            value: authProvider.acceptTerms,
                            onChanged: authProvider.isLoading
                                ? null
                                : (value) {
                              authProvider.setAcceptTerms(value ?? false);
                            },
                          ),
                          Text('I accept the terms and privacy policy', style: AppTextStyles.labelLarge.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          )),
                        ],
                      ),

                      SizedBox(height: AppDimensions.verticalSpaceL),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _handleSignUp,
                          child:  Text('Sign Up', style: AppTextStyles.buttonLarge),
                        ),
                      ),

                      SizedBox(height: AppDimensions.verticalSpaceL),

                      // Or with
                      Center(
                        child: Text(
                          'Or with',
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
                          if(Platform.isIOS)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: authProvider.isLoading ? null : () {},
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

                      // Login option
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontSize: 18.w,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            GestureDetector(
                              onTap: authProvider.isLoading
                                  ? null
                                  : () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),)),
                              child: Text(
                                'Login',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 18.w,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom padding for keyboard
                      SizedBox(height: AppDimensions.verticalSpaceL),
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

  void _handleSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Hide keyboard when API is hit
      FocusScope.of(context).unfocus();
      
      final provider = Provider.of<AuthProvider>(context, listen: false);
      
      if (!provider.acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept the terms and privacy policy'),
          ),
        );
        return;
      }

      // ---------------------------
      // CONFIRM PASSWORD VALIDATION
      // ---------------------------
      if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password and confirm password do not match'),
          ),
        );
        return;
      }

      // --------------------------------------
      // SIGNUP LOGIC USING PROVIDER
      // --------------------------------------

      final model = SignUpModel(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        password: _passwordController.text.trim(),
        potentialBusinessProfile: PotentialBusinessProfile(
          defaultCity: "Austin",
          defaultState: "TX",
          defaultRadiusMiles: 25,
        ),
      );

      final success = await provider.registerUser(model);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup failed! Please try again")),
        );
        return;
      }

      // --------------------------------------
      // Redirect to complete profile page after registration
      // --------------------------------------
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CompleteProfilePage(),));
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
      // Navigate to complete profile page (same for both login and signup)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CompleteProfilePage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
