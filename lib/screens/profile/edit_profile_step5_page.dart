import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/business_owner_provider.dart';
import '../../models/business_owner_profile/business_profile.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../screens/main_navigation_screen.dart';

/// Edit Profile Page - Step 5
class EditProfileStep5Page extends StatefulWidget {
  const EditProfileStep5Page({super.key});

  @override
  State<EditProfileStep5Page> createState() => _EditProfileStep5PageState();
}

class _EditProfileStep5PageState extends State<EditProfileStep5Page> {

  int _getYearsOfExperience(String? experience) {
    if (experience == null || experience.isEmpty) return 0;
    
    if (experience.contains('Less than 1')) return 0;
    if (experience.contains('1-2')) return 2;
    if (experience.contains('3-5')) return 4;
    if (experience.contains('6-10')) return 8;
    if (experience.contains('More than 10')) return 12;
    
    return 0;
  }
  
  String _getServicesOffered(Map<String, bool> subServices) {
    final selectedServices = subServices.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    return selectedServices.join(', ');
  }

  String _getServiceCategories(String? primaryCategory, Map<String, bool> subServices) {
    final selectedSubServices = subServices.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .where((serviceName) => serviceName != primaryCategory)
        .toList();
    
    return selectedSubServices.join(',');
  }
  
  String _getServiceCategoryIds(BusinessOwnerProvider provider) {
    final selectedIds = provider.getSelectedSubCategoryIds();
    return selectedIds.join(',');
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getAvailabilityStatus(Map<String, bool> availabilityDays) {
    final hasSelectedDays = availabilityDays.values.any((isSelected) => isSelected);
    return hasSelectedDays ? 'available' : 'unavailable';
  }

  String _getBusinessHours(TimeOfDay? startTime, TimeOfDay? endTime) {
    if (startTime == null || endTime == null) return '';
    return '${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}';
  }

  String _formatGender(String? gender) {
    if (gender == null || gender.isEmpty) return '';
    return gender.toLowerCase();
  }

  String _formatIdProofType(String? idType) {
    if (idType == null || idType.isEmpty) return '';
    return idType.toLowerCase().replaceAll(' ', '_');
  }

  String _formatDateOfBirth(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _extractServiceRateNumber(String? rate) {
    if (rate == null || rate.isEmpty) return '';
    return rate.replaceAll('\$', '').replaceAll(' ', '').trim();
  }

  Future<void> _handleUpdate() async {
    FocusScope.of(context).unfocus();
    
    final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);

    if (provider.isLoading) return;

    // Validate confirmation checkbox
    if (!provider.confirmInformation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm that all information is accurate'),
        ),
      );
      return;
    }

    try {
      // Get existing business profile data
      final apiResponse = provider.response;
      Map<String, dynamic>? existingProfileData;
      if (apiResponse != null) {
        if (apiResponse['user'] != null) {
          final user = apiResponse['user'] as Map<String, dynamic>?;
          if (user != null && user['business_owner_profile'] != null) {
            existingProfileData = user['business_owner_profile'] as Map<String, dynamic>?;
          }
        } else if (apiResponse['id'] != null || apiResponse['business_owner_profile'] != null) {
          existingProfileData = apiResponse;
        }
      }

      // Prepare file objects
      File? idProofFile = existingProfileData?['id_proof_file'] != null ? null : provider.selectedIdDocument;
      File? recentPhoto = existingProfileData?['recent_photo'] != null ? null : provider.selectedPhoto;
      File? logoFile;

      // Create BusinessProfileModel with all data
      final businessProfile = BusinessProfileModel(
        gender: _formatGender(provider.selectedGender),
        dateOfBirth: _formatDateOfBirth(provider.selectedDate),
        alternatePhone: provider.alternatePhone ?? '',
        businessName: existingProfileData?['business_name']?.toString() ?? '',
        tagline: existingProfileData?['tagline']?.toString() ?? '',
        description: existingProfileData?['description']?.toString() ?? '',
        yearsOfExperience: existingProfileData?['years_of_experience'] ?? 0,
        primaryServiceCategory: provider.selectedServiceCategory ?? '',
        primaryServiceCategoryId: provider.selectedServiceCategoryId ?? '',
        serviceCategories: existingProfileData?['service_categories']?.toString() ?? '',
        serviceCategoryIds: existingProfileData?['service_category_ids']?.toString() ?? '',
        servicesOffered: existingProfileData?['services_offered']?.toString() ?? '',
        addressLine: existingProfileData?['address_line']?.toString() ?? '',
        city: provider.selectedCity ?? '',
        state: existingProfileData?['state']?.toString() ?? '',
        postalCode: existingProfileData?['postal_code']?.toString() ?? '',
        latitude: existingProfileData?['latitude']?.toString() ?? '',
        longitude: existingProfileData?['longitude']?.toString() ?? '',
        website: existingProfileData?['website']?.toString() ?? '',
        businessHours: _getBusinessHours(provider.startTime, provider.endTime),
        maxLeadDistanceMiles: (provider.serviceRadius / 1.60934).round(),
        autoRespondEnabled: existingProfileData?['auto_respond_enabled'] ?? false,
        autoRespondMessage: existingProfileData?['auto_respond_message']?.toString() ?? '',
        subscriptionTier: existingProfileData?['subscription_tier']?.toString() ?? 'basic',
        availabilityStatus: _getAvailabilityStatus(provider.availabilityDays),
        logo: existingProfileData?['logo']?.toString() ?? '',
        gallery: existingProfileData?['gallery']?.toString() ?? '',
        idProofType: _formatIdProofType(provider.selectedIdType),
        idProofFile: existingProfileData?['id_proof_file']?.toString() ?? '',
        recentPhoto: existingProfileData?['recent_photo']?.toString() ?? '',
        baseServiceRate: _extractServiceRateNumber(provider.serviceRate),
      );

      // Update business profile with files
      final success = await provider.updateBusinessProfileWithFiles(
        businessProfile,
        name: provider.fullName,
        phone: provider.mobileNumber,
        idProofFile: idProofFile,
        recentPhoto: recentPhoto,
        logoFile: logoFile,
        context: context,
      );
      
      if (mounted) {
        if (success) {
          // Refresh profile data
          provider.fetchBusinessOwnerProfile();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
          
          // Navigate to profile page (index 4 in MainNavigationScreen)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(initialIndex: 4),
            ),
            (route) => false, // Remove all previous routes
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile. Please try again.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessOwnerProvider>(
      builder: (context, provider, child) {
        return PopScope(
          canPop: !provider.isLoading,
          onPopInvoked: (didPop) {
            if (provider.isLoading && didPop) {
              // This shouldn't happen due to canPop, but just in case
            }
          },
          child: Scaffold(
            body: Stack(
            children: [
              SafeArea(
            child: Column(
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
                              'Update your Profile',
                              style: AppTextStyles.appBarTitle.copyWith(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: AppDimensions.verticalSpaceS),
                          
                          // Subtitle
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingM,
                              ),
                              child: Text(
                                'Help customer know you better and get more bookings.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 14.sp,
                                  color: Theme.of(context).colorScheme.onBackground,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceL),
                      
                      // Profile Completion Status Card
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppDimensions.cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile Completion Status',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              
                              SizedBox(height: AppDimensions.verticalSpaceM),
                              
                              // Personal Information
                              _buildStatusItem(
                                context: context,
                                icon: Icons.person_outline,
                                title: 'Personal Information',
                                isComplete: true,
                              ),
                              
                              SizedBox(height: AppDimensions.verticalSpaceL),
                              
                              // Service Details
                              _buildStatusItem(
                                context: context,
                                icon: Icons.shopping_bag_outlined,
                                title: 'Service Details',
                                isComplete: true,
                              ),
                              
                              SizedBox(height: AppDimensions.verticalSpaceL),
                              
                              // Documentations
                              _buildStatusItem(
                                context: context,
                                icon: Icons.calendar_today_outlined,
                                title: 'Documentations',
                                isComplete: true,
                              ),
                              
                              SizedBox(height: AppDimensions.verticalSpaceL),
                              
                              // Availability & Rates
                              _buildStatusItem(
                                context: context,
                                icon: Icons.schedule_outlined,
                                title: 'Availability & Rates',
                                isComplete: true,
                              ),
                              
                              SizedBox(height: AppDimensions.verticalSpaceL),
                              
                              // Overall Completion
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Overall Completion',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '4/4 Complete',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceM),
                      
                      // Confirmation Checkbox Card
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppDimensions.cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: provider.confirmInformation,
                                    onChanged: (bool? value) {
                                      provider.setConfirmInformation(value ?? false);
                                    },
                                    activeColor: Theme.of(context).colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 8.h),
                                      child: Text(
                                        'I confirm all the information provided is accurate and genuine.',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: AppDimensions.verticalSpaceS),
                              
                              Padding(
                                padding: EdgeInsets.only(left: 40.w),
                                child: Text(
                                  'By checking this box, I acknowledge that providing false information may result in account suspension and understand that all details will be verified.',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceM),
                      
                      // Warning Banner
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingM,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                          border: Border.all(
                            color: AppColors.warningDark,
                            width: 1,
                          ),
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.warningDark,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: 'Note: Please provide all sections before proceeding. Incomplete profile receive fewer bookings',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warningDark,
                                ),
                              ),
                            ],
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
            
            // Bottom Buttons
            Container(
              padding: EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Previous Button
                    Expanded(
                      child: SizedBox(
                        height: AppDimensions.buttonHeight,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.buttonRadius,
                              ),
                            ),
                          ),
                          child: Text(
                            'Previous',
                            style: AppTextStyles.buttonLarge.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.h,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: AppDimensions.paddingM),
                    
                    // Update Button
                    Expanded(
                      child: SizedBox(
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          onPressed: (provider.confirmInformation && !provider.isLoading) 
                              ? _handleUpdate 
                              : null,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.buttonRadius,
                              ),
                            ),
                          ),
                          child: Text(
                            'Update',
                            style: AppTextStyles.buttonLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.h,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ]
            ),
              ),
              
              // Centered Loader Overlay
              if (provider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
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
  
  Widget _buildStatusItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isComplete,
  }) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    // Dark blue color for icons in light mode
    final darkBlue = const Color(0xFF1565C0);
    // Very light background for light mode
    final lightBackground = const Color(0xFFFAFAFA);
    
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppDimensions.paddingS),
          decoration: BoxDecoration(
            color: isLightMode ? lightBackground : Colors.black,
            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          ),
          child: Icon(
            icon,
            size: 20.w,
            color: isLightMode ? darkBlue : AppColors.primary,
          ),
        ),
        SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        if (isComplete)
          Image.asset(
            "assets/images/success.png",
            height: 20.h,
            width: 20.w,
          ),
      ],
    );
  }
}

