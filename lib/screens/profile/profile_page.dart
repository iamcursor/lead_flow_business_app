import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lead_flow_business/screens/auth/login_page.dart';
import 'package:lead_flow_business/screens/profile/change_password_page.dart';
import 'package:lead_flow_business/screens/profile/delete_account_page.dart';
import 'package:lead_flow_business/screens/profile/edit_profile_page.dart';
import 'package:lead_flow_business/screens/profile/notification_settings_page.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/business_owner_provider.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Fetch business owner profile when page loads only if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
      // Only fetch if profile hasn't been loaded yet
      if (provider.response == null) {
        provider.fetchBusinessOwnerProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessOwnerProvider>(
      builder: (context, provider, child) {
        // Extract user data from GET API response only
        final apiResponse = provider.response;
        
        Map<String, dynamic>? user;
        Map<String, dynamic>? businessProfile;
        
        // Get data from API response
        if (apiResponse != null) {
          // Check if API returned user object
          if (apiResponse['user'] != null) {
            user = apiResponse['user'] as Map<String, dynamic>?;
            if (user != null && user['business_owner_profile'] != null) {
              businessProfile = user['business_owner_profile'] as Map<String, dynamic>?;
            }
          } else if (apiResponse['id'] != null || apiResponse['business_owner_profile'] != null) {
            // If API returns profile directly (not nested in user)
            businessProfile = apiResponse;
          }
        }
        
        // Get user name
        final userName = user?['name']?.toString() ?? 
                         businessProfile?['name']?.toString() ?? 
                         provider.fullName ?? 
                         'User';
        
        // Get profile image
        final profileImageUrl = businessProfile?['recent_photo']?.toString();
        
        // Get service category
        final serviceCategory = businessProfile?['primary_service_category']?.toString() ?? 
                               provider.selectedServiceCategory ?? 
                               'Electrician';
        
        // Get location
        final city = businessProfile?['city']?.toString();
        final state = businessProfile?['state']?.toString();
        final locationText = city != null && city.isNotEmpty
            ? (state != null && state.isNotEmpty ? '$city, $state' : city)
            : provider.selectedCity ?? 'Saket';
        
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Main Content
                    Expanded(
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.screenPaddingHorizontal,
                        vertical: AppDimensions.screenPaddingVertical,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppDimensions.verticalSpaceS),
                          
                          // Title
                          Center(
                            child: Text(
                              'Profile',
                              style: AppTextStyles.appBarTitle.copyWith(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: AppDimensions.verticalSpaceL),
                          
                          // Error State
                          if (provider.errorMessage != null && provider.response == null)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppDimensions.verticalSpaceXL,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      provider.errorMessage!,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: AppDimensions.verticalSpaceM),
                                    ElevatedButton(
                                      onPressed: () => provider.fetchBusinessOwnerProfile(),
                                      child: Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          // Profile Card
                          else if (provider.response != null)
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
                            child: Padding(
                              padding: EdgeInsets.all(AppDimensions.cardPadding),
                              child: Row(
                                children: [
                                  // Profile Picture with Camera Icon
                                  Stack(
                                    children: [
                                      Container(
                                        width: 80.w,
                                        height: 80.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).colorScheme.surfaceVariant,
                                        ),
                                        child: profileImageUrl != null && profileImageUrl.isNotEmpty
                                            ? ClipOval(
                                                child: Image.network(
                                                  profileImageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.person,
                                                      size: 40.w,
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                    );
                                                  },
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                        value: loadingProgress.expectedTotalBytes != null
                                                            ? loadingProgress.cumulativeBytesLoaded /
                                                                loadingProgress.expectedTotalBytes!
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : provider.photoPath != null && provider.photoPath!.isNotEmpty
                                                ? ClipOval(
                                                    child: Image.asset(
                                                      provider.photoPath!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.person,
                                                    size: 40.w,
                                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                  ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 24.w,
                                          height: 24.w,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Theme.of(context).colorScheme.surface,
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 12.w,
                                            color: Theme.of(context).colorScheme.onPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(width: AppDimensions.paddingM),
                                  
                                  // Profile Information
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Name
                                        Text(
                                          userName,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        

                                        
                                        // Verified Service Category
                                        Text(
                                          'Verified $serviceCategory',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        

                                        
                                        // Location
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 15.w,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                            SizedBox(width: 4.w),
                                            Expanded(
                                              child: Text(
                                                locationText,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        

                                        
                                        // Rating
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 18.w,
                                              color: Theme.of(context).colorScheme.tertiary,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              '4.5 (72 Jobs)',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: AppDimensions.verticalSpaceM),
                          
                          // Account Management Options Card
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
                            child: Column(
                              children: [
                                // Edit Personal Details
                                _buildMenuItem(
                                  icon: Icons.note_add,
                                  title: 'Edit Personal Details',
                                  subtitle: 'Edit your account details',
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(),));
                                  },
                                ),
                                
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                
                                // Change Password
                                _buildMenuItem(
                                  icon: Icons.help_outline,
                                  title: 'Change Password',
                                  subtitle: 'Change your password',
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordPage(),));
                                  },
                                ),
                                
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                
                                // Notifications Preferences
                                _buildMenuItem(
                                  icon: Icons.notifications_outlined,
                                  title: 'Notifications Preferences',
                                  subtitle: 'Control alerts, reminders',
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationSettingsPage(),));
                                  },
                                ),
                                
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                
                                // Delete Account
                                _buildMenuItem(
                                  icon: Icons.help_outline,
                                  title: 'Delete Account',
                                  subtitle: 'App permissions, security',
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DeleteAccountPage(),));
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: AppDimensions.verticalSpaceM),
                          
                          // Logout Button Card
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                            ),
                            child: InkWell(
                              onTap: () async {
                                // Get auth provider and sign out properly
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                await authProvider.signOut();
                                
                                // Navigate to login screen
                                if (context.mounted) {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                                }
                              },
                              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                              child: Padding(
                                padding: EdgeInsets.all(AppDimensions.cardPadding),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      size: 20.w,
                                      color: Theme.of(context).colorScheme.onErrorContainer,
                                    ),
                                    SizedBox(width: AppDimensions.paddingS),
                                    Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Bottom padding for scroll
                          SizedBox(height: AppDimensions.verticalSpaceXL),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
                // Loader Overlay
                if (provider.isLoadingProfile)
                  Container(
                    color: Colors.transparent,
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
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.cardPadding),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
              ),
              child: Icon(
                icon,
                size: 20.w,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            SizedBox(width: AppDimensions.paddingM),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
