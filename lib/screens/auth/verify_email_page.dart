import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lead_flow_business/screens/auth/verification_success_page.dart';
import 'package:provider/provider.dart';
import '../../models/auth/verify_otp_model.dart';
import '../../providers/auth_provider.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';

/// Verify Email Page
class VerifyEmailPage extends StatefulWidget {
  final String? email;

  const VerifyEmailPage({super.key, this.email});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AuthProvider>(context, listen: false);
    provider.startTimer();
    // Auto focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  String _getMaskedEmail() {
    if (widget.email == null || widget.email!.isEmpty) {
      return 'c*****@gmail.com';
    }
    // Decode email if it's URL-encoded (for backward compatibility)
    String email = widget.email!;
    try {
      email = Uri.decodeComponent(email);
    } catch (e) {
      // If decoding fails, use the original email
      email = widget.email!;
    }
    
    if (email.contains('@')) {
      final parts = email.split('@');
      final username = parts[0];
      final domain = parts[1];
      if (username.length > 1) {
        return '${username[0]}*****@$domain';
      }
      return 'c*****@$domain';
    }
    return 'c*****@gmail.com';
  }

  String _formatTimer(int remainingSeconds) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}s';
  }

  void _onCodeChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getOtpCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _handleVerify() async {
    final otpCode = _getOtpCode();
    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 6-digit code')),
      );
      return;
    }

    final provider = Provider.of<AuthProvider>(context, listen: false);

    // Decode email if it's URL-encoded (for backward compatibility)
    String email = widget.email ?? '';
    try {
      email = Uri.decodeComponent(email);
    } catch (e) {
      // If decoding fails, use the original email
      email = widget.email ?? '';
    }

    // Create VerifyOtpModel
    final model = VerifyOtpModel(
      email: email,
      otp: otpCode,
    );

    // Call provider's verifyOTP
    final success = await provider.verifyOTP(model);

    if (success) {
      // Navigate to success screen
      if (mounted) {
        // Decode email if it's URL-encoded (for backward compatibility)
        String decodedEmail = widget.email ?? '';
        try {
          decodedEmail = Uri.decodeComponent(decodedEmail);
        } catch (e) {
          decodedEmail = widget.email ?? '';
        }
        
        if (decodedEmail.isNotEmpty) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VerificationSuccessPage(email: decodedEmail,),));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VerificationSuccessPage(),));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP verification failed. Please try again.')),
      );
    }
  }


  void _handleResendCode() {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    if (!provider.canResend) return;

    // TODO: Implement resend OTP logic
    provider.startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code resent successfully')),
    );
  }

  @override
  void dispose() {
    // Timer is managed by AuthProvider, no need to cancel here
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(AppDimensions.screenPaddingTop),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppDimensions.verticalSpaceL),

                    // Title
                    Text('Verify Email', style: AppTextStyles.appBarTitle),
                    SizedBox(height: AppDimensions.verticalSpaceM),

                    // Description
                    Text(
                      'Verify your email below to proceed',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14.h
                      ),
                    ),
                    SizedBox(height: AppDimensions.verticalSpaceS),
                    Text(
                      'Enter the 6 digits code sent to your email address ${_getMaskedEmail()} below',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14.h
                      ),
                    ),
                    SizedBox(height: AppDimensions.verticalSpaceXL),

                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) =>
                        SizedBox(
                          width: 54.w,

                          child: Stack(
                            alignment: Alignment.center,
                            children:[
                              TextFormField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontSize: 18.w,

                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: AppColors.border,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: AppColors.border,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.background,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) => _onCodeChanged(index, value),
                              ),
                            ]
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.verticalSpaceL),

                    // Timer
                    Center(
                      child: Text(
                        'code expires in ${_formatTimer(authProvider.remainingSeconds)}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12.h
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.verticalSpaceM),

                    // Resend Code
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't get code? ",
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                                fontSize: 12.h
                            ),
                          ),
                          GestureDetector(
                            onTap: authProvider.canResend ? _handleResendCode : null,
                            child: Text(
                              'Resend code',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: authProvider.canResend ? AppColors.primary : AppColors.textTertiary,
                                fontWeight: FontWeight.w600,
                                  fontSize: 12.h
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.verticalSpaceXL),

                    // Verify Button
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
                        onPressed: authProvider.isLoading ? null : _handleVerify,
                        child:  Text('Verify', style: AppTextStyles.buttonLarge,),
                      ),
                    ),
                  ],
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
                          AppColors.primaryLight,
                        ),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

