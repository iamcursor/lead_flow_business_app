import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lead_flow_business/screens/main_navigation_screen.dart';
import 'package:lead_flow_business/screens/profile/waiting_for_approval_page.dart';

import 'package:provider/provider.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../providers/business_owner_provider.dart';
import '../../models/business_owner_profile/business_profile.dart';

/// Complete Profile Page - Step 5 of 5
class CompleteProfileStep5Page extends StatefulWidget {
  const CompleteProfileStep5Page({super.key});

  @override
  State<CompleteProfileStep5Page> createState() => _CompleteProfileStep5PageState();
}

class _CompleteProfileStep5PageState extends State<CompleteProfileStep5Page> {

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
    // Only include selected sub-services (not the primary category)
    final selectedSubServices = subServices.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .where((serviceName) => serviceName != primaryCategory) // Explicitly exclude primary category
        .toList();
    
    return selectedSubServices.join(',');
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getAvailabilityStatus(Map<String, bool> availabilityDays) {
    // API expects "available" or "unavailable" status, not comma-separated days
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
    // Convert "ID Card" to "id_card" or keep as is based on API requirements
    // Try lowercase with underscore format
    return idType.toLowerCase().replaceAll(' ', '_');
  }

  String _extractServiceRateNumber(String? rate) {
    if (rate == null || rate.isEmpty) return '';
    // Remove $ and any whitespace, return just the number
    return rate.replaceAll('\$', '').replaceAll(' ', '').trim();
  }

  Future<void> _handleSubmit() async {
    // Hide keyboard when API is hit
    FocusScope.of(context).unfocus();
    
    final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);

    if (provider.isLoading) return;

    try {
      // Prepare file objects from provider
      File? idProofFile = provider.selectedIdDocument;
      File? recentPhoto = provider.selectedPhoto;
      File? logoFile; // Logo is empty for now

      // Create BusinessProfileModel (file paths will be replaced by actual files in multipart)
      final businessProfile = BusinessProfileModel(
        gender: _formatGender(provider.selectedGender),
        dateOfBirth: provider.selectedDate != null 
            ? '${provider.selectedDate!.year}-${provider.selectedDate!.month.toString().padLeft(2, '0')}-${provider.selectedDate!.day.toString().padLeft(2, '0')}'
            : '',
        alternatePhone: provider.alternatePhone ?? '',
        businessName: '',
        tagline: '',
        description: '',
        yearsOfExperience: _getYearsOfExperience(provider.selectedExperience),
        primaryServiceCategory: provider.selectedServiceCategory ?? '',
        serviceCategories: _getServiceCategories(provider.selectedServiceCategory, provider.subServices),
        servicesOffered: _getServicesOffered(provider.subServices),
        addressLine: '',
        city: provider.selectedCity ?? '',
        state: '',
        postalCode: '',
        latitude: '',
        longitude: '',
        website: '',
        businessHours: _getBusinessHours(provider.startTime, provider.endTime),
        maxLeadDistanceMiles: provider.serviceRadius.toInt(),
        autoRespondEnabled: false,
        autoRespondMessage: '',
        subscriptionTier: 'basic', // API expects "basic" as default
        availabilityStatus: _getAvailabilityStatus(provider.availabilityDays),
        logo: '',
        gallery: '',
        idProofType: _formatIdProofType(provider.selectedIdType),
        idProofFile: '', // Will be replaced by actual file in multipart
        recentPhoto: '', // Will be replaced by actual file in multipart
        baseServiceRate: _extractServiceRateNumber(provider.serviceRate),
      );

      // Update business profile with files using multipart/form-data
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
          // Check verification status from response
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WaitingForApprovalPage()),
            );
          } else {
            // Redirect to main navigation screen (Explore page at index 0)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(initialIndex: 0),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit profile. Please try again.'),
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
            // Prevent back navigation when loading
            if (provider.isLoading && didPop) {
              // This shouldn't happen due to canPop, but just in case
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Stack(
            children: [
              SafeArea(
            child: Column(
              children: [
                // Main Content
                Expanded(
                  child: Container(
                    color: AppColors.background,
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
                              'Complete Your Profile',
                              style: AppTextStyles.appBarTitle.copyWith(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
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
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: AppDimensions.verticalSpaceM),
                          
                          // Progress Section
                          Row(
                            children: [
                              Text(
                                'Step 5 of 5',
                                style: AppTextStyles.labelMedium.copyWith(
                                  fontSize: 13.sp,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${(provider.step5Progress * 100).toInt()}%',
                                style: AppTextStyles.labelMedium.copyWith(
                                  fontSize: 13.sp,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: AppDimensions.verticalSpaceS),
                          
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: provider.step5Progress,
                              backgroundColor: AppColors.borderLight,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              minHeight: 6.h,
                            ),
                          ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceL),
                      
                      // Profile Completion Status Card
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                          border: Border.all(
                            color: AppColors.borderLight,
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
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              
                              SizedBox(height: AppDimensions.verticalSpaceM),
                              
                              // Personal Information
                              _buildStatusItem(
                                icon: Icons.person_outline,
                                title: 'Personal Information',
                                isComplete: true,
                              ),
                              
                              SizedBox(height: AppDimensions.verticalSpaceL),
                              
                              // Service Details
                              _buildStatusItem(
                                icon: Icons.shopping_bag_outlined,
                                title: 'Service Details',
                                isComplete: true,
                              ),
                              
                              SizedBox(height: AppDimensions.verticalSpaceL),
                              
                              // Documentations
                              _buildStatusItem(
                                icon: Icons.calendar_today_outlined,
                                title: 'Documentations',
                                isComplete: true,
                              ),
                              
                              SizedBox(height: AppDimensions.verticalSpaceL),
                              
                              // Availability & Rates
                              _buildStatusItem(
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
                                      color: AppColors.textPrimary,
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
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                          border: Border.all(
                            color: AppColors.borderLight,
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
                                    activeColor: AppColors.primary,
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
                                          color: AppColors.textPrimary,
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
                                    color: AppColors.textPrimary,
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
                          color: AppColors.warningLight,// Light yellow background
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
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.buttonRadius,
                              ),
                            ),
                          ),
                          child: Text(
                            'Previous',
                            style: AppTextStyles.buttonLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.h,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: AppDimensions.paddingM),
                    
                    // Submit for Approval Button
                    Expanded(
                      child: SizedBox(
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          onPressed: (provider.confirmInformation && !provider.isLoading) 
                              ? _handleSubmit 
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            disabledBackgroundColor: AppColors.borderLight,
                            disabledForegroundColor: AppColors.textHint,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.buttonRadius,
                              ),
                            ),
                          ),
                          child: Text(
                            'Submit for Approval',
                            style: AppTextStyles.buttonLarge.copyWith(
                              color: AppColors.textOnPrimary,
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
          ),
        ),
      );
      },
    );
  }
  
  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required bool isComplete,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppDimensions.paddingS),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          ),
          child: Icon(
            icon,
            size: 20.w,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
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

