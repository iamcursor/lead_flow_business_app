import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/auth/reset_password_model.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import 'login_page.dart';

/// Reset Password Page
class ResetPasswordPage extends StatefulWidget {
  final String? email;
  
  const ResetPasswordPage({super.key, this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
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

                      // Title
                      Text('Create New Password', style: AppTextStyles.appBarTitle.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      )),
                      SizedBox(height: AppDimensions.verticalSpaceS),
                      
                      // Description
                      Text(
                        'Forgot your password? Let\'s create a new one and make your account secure again',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14.h
                        ),
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
                          hintText: 'Re enter password',
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
                          Expanded(
                            child: Text(
                              'I accept the terms and privacy policy',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppDimensions.verticalSpaceXL),

                      // Confirm Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.paddingM,
                            ),
                          ),
                          onPressed: authProvider.isLoading ? null : _handleResetPassword,
                          child:  Text('Confirm',style: AppTextStyles.buttonLarge),
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
          )
        );
      },
    );
  }

  void _handleResetPassword() async {
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

      // Confirm password match
      if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password and confirm password do not match'),
          ),
        );
        return;
      }

      // Get email from widget parameter
      final email = widget.email;
      if (email == null || email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email is required. Please go back and try again.'),
          ),
        );
        return;
      }

      final model = ResetPasswordModel(
        email: email,
        newPassword: _passwordController.text.trim(),
      );

      final success = await provider.resetPassword(model);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully')),
        );

        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to reset password. Try again.')),
        );
      }
    }
  }



  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

