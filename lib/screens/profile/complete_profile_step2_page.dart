import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lead_flow_business/screens/profile/complete_profile_step3_page.dart';
import 'package:provider/provider.dart';
import '../../providers/business_owner_provider.dart';
import '../../models/business_owner_profile/business_profile.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';

/// Complete Profile Page - Step 2 of 5
class CompleteProfileStep2Page extends StatefulWidget {
  const CompleteProfileStep2Page({super.key});

  @override
  State<CompleteProfileStep2Page> createState() => _CompleteProfileStep2PageState();
}

class _CompleteProfileStep2PageState extends State<CompleteProfileStep2Page> {
  final _formKey = GlobalKey<FormState>();
  
  final List<String> _experienceOptions = [
    'Less than 1 year',
    '1-2 years',
    '3-5 years',
    '6-10 years',
    'More than 10 years',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize provider after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
      provider.initializeStep2();
    });
  }

  String _formatGender(String? gender) {
    if (gender == null || gender.isEmpty) return '';
    return gender.toLowerCase();
  }

  String _formatDateOfBirth(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

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
    // Get the list of selected subcategory IDs
    final selectedIds = provider.getSelectedSubCategoryIds();
    return selectedIds.join(',');
  }

  Future<void> _handleNext() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Hide keyboard when API is hit
      FocusScope.of(context).unfocus();
      
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);

      if (provider.isLoading) return;

      // Validate all required fields
      if (provider.selectedExperience == null || provider.selectedExperience!.isEmpty ||
          provider.selectedServiceCategory == null || provider.selectedServiceCategory!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All fields are required'),
          ),
        );
        return;
      }

      // Validate sub-services selection
      if (provider.selectedServiceCategory != null && provider.selectedServiceCategory!.isNotEmpty) {
        final hasSelectedSubServices = provider.subServices.values.any((isSelected) => isSelected);
        if (!hasSelectedSubServices) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All fields are required'),
            ),
          );
          return;
        }
      }

      try {
        // Create BusinessProfileModel with step 1 + step 2 data
        final businessProfile = BusinessProfileModel(
          gender: _formatGender(provider.selectedGender),
          dateOfBirth: _formatDateOfBirth(provider.selectedDate),
          alternatePhone: provider.alternatePhone ?? '',
          businessName: '',
          tagline: '',
          description: '',
          yearsOfExperience: _getYearsOfExperience(provider.selectedExperience),
          primaryServiceCategory: provider.selectedServiceCategory ?? '',
          primaryServiceCategoryId: provider.selectedServiceCategoryId ?? '',
          serviceCategories: _getServiceCategories(provider.selectedServiceCategory, provider.subServices),
          serviceCategoryIds: _getServiceCategoryIds(provider),
          servicesOffered: _getServicesOffered(provider.subServices),
          addressLine: '',
          city: provider.selectedCity ?? '',
          state: '',
          postalCode: '',
          latitude: '',
          longitude: '',
          website: '',
          businessHours: '', // Will be set in step 4/5
          maxLeadDistanceMiles: provider.serviceRadius.toInt(),
          autoRespondEnabled: false,
          autoRespondMessage: '',
          subscriptionTier: 'basic',
          availabilityStatus: '', // Will be set in step 4/5
          logo: '',
          gallery: '',
          idProofType: '', // Will be set in step 3/5
          idProofFile: '', // Will be set in step 3/5
          recentPhoto: '', // Will be set in step 3/5
          baseServiceRate: '', // Will be set in step 4/5
        );

        // Update business profile (no files for step 2)
        final success = await provider.updateBusinessProfileWithFiles(
          businessProfile,
          name: provider.fullName,
          phone: provider.mobileNumber,
          idProofFile: null,
          recentPhoto: null,
          logoFile: null,
          context: context,
        );
        
        if (mounted) {
          if (success) {
            // Navigate to Step 3
            Navigator.push(context, MaterialPageRoute(builder: (context) => CompleteProfileStep3Page(),));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save profile. Please try again.'),
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
                      child: Form(
                        key: _formKey,
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
                                  'Step 2 of 5',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    fontSize: 13.sp,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${(provider.step2Progress * 100).toInt()}%',
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
                                value: provider.step2Progress,
                                backgroundColor: AppColors.borderLight,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                                minHeight: 6.h,
                              ),
                            ),
                        
                        SizedBox(height: AppDimensions.verticalSpaceM),
                        
                        // Personal Information Card
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
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                
                                SizedBox(height: AppDimensions.verticalSpaceS),
                                
                                // Years of Experience
                                Text(
                                  'Years of Experience',
                                  style: TextStyle(
                                    fontSize: 14.w,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: AppDimensions.verticalSpaceS),
                                DropdownButtonFormField<String>(
                                  initialValue: provider.selectedExperience,
                                  style: AppTextStyles.inputText,
                                  decoration: const InputDecoration(
                                    hintText: 'Select your experience',
                                    suffixIcon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: AppColors.iconSecondary,
                                    ),
                                  ),
                                  items: _experienceOptions.map((String experience) {
                                    return DropdownMenuItem<String>(
                                      value: experience,
                                      child: Text(experience),
                                    );
                                  }).toList(),
                                  onChanged: provider.setSelectedExperience,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select your experience';
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: AppDimensions.verticalSpaceS),
                                
                                // Primary Service Category
                                Text(
                                  'Primary Service Category',
                                  style: TextStyle(
                                    fontSize: 14.w,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: AppDimensions.verticalSpaceS),
                                provider.isLoadingCategories
                                    ? Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: AppDimensions.verticalSpaceM),
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
                                      )
                                    : DropdownButtonFormField<String>(
                                        initialValue: provider.selectedServiceCategory,
                                        style: AppTextStyles.inputText,
                                        decoration: const InputDecoration(
                                          hintText: 'Select service category',
                                          suffixIcon: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: AppColors.iconSecondary,
                                          ),
                                        ),
                                        items: provider.serviceCategories.map((category) {
                                          return DropdownMenuItem<String>(
                                            value: category.name,
                                            child: Text(category.name),
                                          );
                                        }).toList(),
                                        onChanged: provider.setSelectedServiceCategory,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select service category';
                                          }
                                          return null;
                                        },
                                      ),
                              ],
                            ),
                          ),
                        ),
                        
                        SizedBox(height: AppDimensions.verticalSpaceL),
                        
                        // Service Details Card - Sub Services (only show when main category is selected)
                        if (provider.selectedServiceCategory != null && provider.selectedServiceCategory!.isNotEmpty)
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
                                    'Service Details',
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  
                                  SizedBox(height: AppDimensions.verticalSpaceS),
                                  
                                  Text(
                                    'Sub Services Offered',
                                    style: TextStyle(
                                      fontSize: 14.w,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  
                                  SizedBox(height: AppDimensions.verticalSpaceS),
                                  
                                  // Loading or Sub-categories Checkboxes
                                  provider.isLoadingSubCategories
                                      ? Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: AppDimensions.verticalSpaceM),
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
                                        )
                                      : provider.subServices.isEmpty
                                          ? Padding(
                                              padding: EdgeInsets.symmetric(vertical: AppDimensions.verticalSpaceS),
                                              child: Text(
                                                'No sub-services available for this category',
                                                style: AppTextStyles.labelMedium.copyWith(
                                                  fontSize: 14.sp,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            )
                                          : Column(
                                              children: provider.subServices.keys.map((String service) {
                                                return CheckboxListTile(
                                                  contentPadding: EdgeInsets.zero,
                                                  dense: true,
                                                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                                  title: Text(
                                                    service,
                                                    style: AppTextStyles.labelLarge.copyWith(
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  value: provider.subServices[service],
                                                  onChanged: (val) => provider.setSubService(service, val!),
                                                  controlAffinity: ListTileControlAffinity.leading,
                                                );
                                              }).toList(),
                                            ),
                                ],
                              ),
                            ),
                          ),
                        
                        SizedBox(height: AppDimensions.verticalSpaceM),
                        
                        // Service Details Card - Service Area Radius
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
                                  'Service Details',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                
                                SizedBox(height: AppDimensions.verticalSpaceS),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Service Area Radius',
                                      style: TextStyle(
                                        fontSize: 14.w,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${provider.serviceRadius.toInt()} km',
                                      style: AppTextStyles.titleLarge.copyWith(
                                        fontSize: 14.w,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: AppDimensions.verticalSpaceM),
                                
                                // Slider
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: AppColors.primary,
                                    inactiveTrackColor: AppColors.borderLight,
                                    trackHeight: 4.0,
                                    thumbColor: AppColors.primary,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8.0,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 16.0,
                                    ),
                                    overlayColor: AppColors.primary.withOpacity(0.1),
                                  ),
                                  child: Slider(
                                    value: provider.serviceRadius,
                                    min: 2,
                                    max: 25,
                                    divisions: 23,
                                    activeColor: AppColors.primary,
                                    inactiveColor: AppColors.borderLight,
                                    onChanged: (double value) {
                                      provider.setServiceRadius(value);
                                    },
                                  ),
                                ),
                                
                                // Slider Labels
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '2 km',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        fontSize: 12.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '25 km',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        fontSize: 12.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                
                                
                                // Use Current Location Checkbox
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    'Use current location as center',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  value: provider.useCurrentLocation,
                                  onChanged: (bool? value) {
                                    provider.setUseCurrentLocation(value ?? false);
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
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
            ),
            
            // Next Button
            Container(
              padding: EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.buttonRadius,
                        ),
                      ),
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                    ),
                    child: Text(
                      'Next',
                      style: AppTextStyles.buttonLarge
                    ),
                  ),
                ),
              ),
            ),
          ],
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
}

