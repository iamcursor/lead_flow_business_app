import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lead_flow_business/screens/auth/login_page.dart';

import 'package:provider/provider.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {


  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPaddingHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppDimensions.screenPaddingTop),
                      
                      // Back Button and Title Row
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.primary,
                              size: AppDimensions.iconM,
                            ),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                          SizedBox(width: AppDimensions.paddingM),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Delete Account',
                                style: AppTextStyles.appBarTitle.copyWith(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onBackground,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppDimensions.iconM + AppDimensions.paddingM),
                        ],
                      ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceL),
                      
                      // Warning Message Card
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: AppDimensions.shadowBlurRadius,
                              offset: Offset(0, AppDimensions.shadowOffset),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(AppDimensions.cardPadding),
                        child: Text(
                          "Deleting your account is permanent. All your data, settings, and activity will be removed. This action cannot be undone.",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceM),


                      
                      // Confirm Deletion Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : () async {
                            // Call delete user API directly
                            final success = await authProvider.deleteUser();
                            
                            // Use the page context for navigation
                            if (!context.mounted) return;
                            
                            if (success) {
                              // Navigate to login screen after successful deletion
                              // Use post-frame callback to ensure navigation happens after UI updates
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.mounted) {
                                  // Use go() to clear all routes and navigate to login
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                                }
                              });
                            } else {
                              // Show error message
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to delete account. Please try again.'),
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                            padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.paddingM,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Confirm Deletion',
                            style: AppTextStyles.buttonMedium,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceXL),
                    ],
                  ),
                ),
                
                // Loading Overlay
                if (authProvider.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
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

}

