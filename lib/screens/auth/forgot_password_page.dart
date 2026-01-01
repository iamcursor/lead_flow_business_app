import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lead_flow_business/screens/auth/login_page.dart';
import 'package:lead_flow_business/screens/auth/verify_email_page.dart';
import 'package:provider/provider.dart';

import '../../models/auth/send_otp_model.dart';
import '../../providers/auth_provider.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';

/// Forgot Password Page
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

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
        children:[
          SingleChildScrollView(
            padding: EdgeInsets.all(AppDimensions.screenPaddingTop),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppDimensions.verticalSpaceL),
                  Text('Forgot Password', style: AppTextStyles.appBarTitle),
                  SizedBox(height: AppDimensions.verticalSpaceM),
                  Text(
                    'Forgot your password? Let create a new one and make your account secure again.',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14.h
                    ),
                  ),
                  SizedBox(height: AppDimensions.verticalSpaceL),
                  // Email Field
                  Text('Email address', style: AppTextStyles.labelLarge),
                  SizedBox(height: AppDimensions.verticalSpaceS),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Enter your email address'),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppDimensions.verticalSpaceXL),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                      ),
                      onPressed: authProvider.isLoading ? null : _handleResetPassword,
                      child:  Text('Send Code',style: AppTextStyles.buttonLarge),
                    ),
                  ),
                  SizedBox(height: AppDimensions.verticalSpaceL),
                  Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Remember password? ",
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontSize: 18.w,
                              fontWeight: FontWeight.w400,
                            ),

                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),)),
                            child: Text(
                              'Log in',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 18.w,
                                color: AppColors.primary,
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
          if (authProvider.isLoading)
            Container(
              color: AppColors.overlayLight,
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryLight,
                    ),
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ]
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

      final model = SendOtpModel(
        email: _emailController.text.trim(),
      );

      bool success = await provider.sendOTP(model);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send code. Please try again')),
        );
        return;
      }
      
      if (mounted) {
        final email = _emailController.text.trim();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VerifyEmailPage(email: email,),));
      }
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}

