import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/business_owner_provider.dart';
import '../../../models/business_owner_profile/change_password_model.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';

/// Change Password Page
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<BusinessOwnerProvider>(
        builder: (context, businessOwnerProvider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(AppDimensions.screenPaddingTop),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppDimensions.verticalSpaceL),
                      
                      // Title
                      Text(
                        'Change Your Password',
                        style: AppTextStyles.appBarTitle.copyWith(
                          fontSize: 30
                        ),

                      ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceM),
                      
                      // Subtitle
                      Text(
                        'Want to change your password? Let\'s create a new one and make your account secure again',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceXL),
                      
                      // Old Password Field
                      Text(
                        'Old password',
                        style: AppTextStyles.labelLarge,
                      ),
                      SizedBox(height: AppDimensions.verticalSpaceS),
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: businessOwnerProvider.obscureOldPassword,
                        decoration: InputDecoration(
                          hintText: 'Enter your old password',
                          hintStyle: AppTextStyles.inputHint,
                          suffixIcon: IconButton(
                            onPressed: () {
                              businessOwnerProvider.toggleObscureOldPassword();
                            },
                            icon: Icon(
                              businessOwnerProvider.obscureOldPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.iconSecondary,
                            ),
                          ),
                        ),
                        style: AppTextStyles.inputText,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your old password';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceL),
                      
                      // New Password Field
                      Text(
                        'New password',
                        style: AppTextStyles.labelLarge,
                      ),
                      SizedBox(height: AppDimensions.verticalSpaceS),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: businessOwnerProvider.obscureNewPassword,
                        decoration: InputDecoration(
                          hintText: 'enter new password',
                          hintStyle: AppTextStyles.inputHint,
                          suffixIcon: IconButton(
                            onPressed: () {
                              businessOwnerProvider.toggleObscureNewPassword();
                            },
                            icon: Icon(
                              businessOwnerProvider.obscureNewPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.iconSecondary,
                            ),
                          ),
                        ),
                        style: AppTextStyles.inputText,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter a new password';
                          }
                          if (value!.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceL),
                      
                      // Confirm Password Field
                      Text(
                        'Confirm password',
                        style: AppTextStyles.labelLarge,
                      ),
                      SizedBox(height: AppDimensions.verticalSpaceS),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: businessOwnerProvider.obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: 'Re enter password',
                          hintStyle: AppTextStyles.inputHint,
                          suffixIcon: IconButton(
                            onPressed: () {
                              businessOwnerProvider.toggleObscureConfirmPassword();
                            },
                            icon: Icon(
                              businessOwnerProvider.obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.iconSecondary,
                            ),
                          ),
                        ),
                        style: AppTextStyles.inputText,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please confirm your password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.buttonRadius,
                              ),
                            ),
                          ),
                          onPressed: businessOwnerProvider.isLoading ? null : _handleChangePassword,
                          child: Text(
                            'Confirm',
                            style: AppTextStyles.buttonLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Loader Overlay
              if (businessOwnerProvider.isLoading)
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

  void _handleChangePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);

      // Create ChangePasswordModel from form data
      final model = ChangePasswordModel(
        oldPassword: _oldPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );

      // Call change password API
      final success = await provider.changePassword(model);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          
          // Navigate back after successful password change
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to change password. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

