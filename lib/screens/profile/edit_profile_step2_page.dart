import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/business_owner_provider.dart';
import '../../models/business_owner_profile/business_profile.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import 'edit_profile_step3_page.dart';

/// Edit Profile Page - Step 2
class EditProfileStep2Page extends StatefulWidget {
  const EditProfileStep2Page({super.key});

  @override
  State<EditProfileStep2Page> createState() => _EditProfileStep2PageState();
}

class _EditProfileStep2PageState extends State<EditProfileStep2Page> {
  final _formKey = GlobalKey<FormState>();
  
  final List<String> _experienceOptions = [
    'Less than 1 year',
    '1-2 years',
    '3-5 years',
    '6-10 years',
    'More than 10 years',
  ];

  String _getExperienceFromYears(int? years) {
    if (years == null) return '';
    if (years < 1) return 'Less than 1 year';
    if (years >= 1 && years <= 2) return '1-2 years';
    if (years >= 3 && years <= 5) return '3-5 years';
    if (years >= 6 && years <= 10) return '6-10 years';
    if (years > 10) return 'More than 10 years';
    return '';
  }

  @override
  void initState() {
    super.initState();
    // Initialize provider after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
      provider.initializeStep2();
      await _loadProfileData(provider);
    });
  }

  Future<void> _loadProfileData(BusinessOwnerProvider provider) async {
    // Extract user data from GET API response (profile page data)
    final apiResponse = provider.response;
    Map<String, dynamic>? user;
    Map<String, dynamic>? businessProfile;
    
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
    
    // Get years of experience from API response
    final yearsOfExperience = businessProfile?['years_of_experience'];
    if (yearsOfExperience != null) {
      final years = yearsOfExperience is int ? yearsOfExperience : int.tryParse(yearsOfExperience.toString());
      if (years != null) {
        final experienceText = _getExperienceFromYears(years);
        if (experienceText.isNotEmpty) {
          provider.setSelectedExperience(experienceText);
        }
      }
    }
    
    // Get service category from API response (already loaded in step 1, but ensure it's set)
    final serviceCategory = businessProfile?['primary_service_category']?.toString();
    if (serviceCategory != null && serviceCategory.isNotEmpty) {
      // Set the service category - this will trigger fetching sub-categories
      if (provider.selectedServiceCategory != serviceCategory) {
        provider.setSelectedServiceCategory(serviceCategory);
      }
      
      // Wait for sub-categories to load (poll until loaded or timeout)
      int attempts = 0;
      while (provider.isLoadingSubCategories && attempts < 20) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      
      // Get services_offered from API response (comma-separated string)
      final servicesOffered = businessProfile?['services_offered']?.toString();
      final servicesArray = businessProfile?['services'] as List<dynamic>?;
      
      // Collect all service names from API
      Set<String> apiServiceNames = {};
      
      // From services_offered string (comma-separated)
      if (servicesOffered != null && servicesOffered.isNotEmpty) {
        final servicesList = servicesOffered.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        apiServiceNames.addAll(servicesList);
      }
      
      // From services array (sub_category_name field)
      if (servicesArray != null && servicesArray.isNotEmpty) {
        for (var service in servicesArray) {
          if (service is Map<String, dynamic>) {
            final subCategoryName = service['sub_category_name']?.toString();
            if (subCategoryName != null && subCategoryName.isNotEmpty) {
              apiServiceNames.add(subCategoryName.trim());
            }
          }
        }
      }
      
      // Mark matching sub-services as selected
      if (apiServiceNames.isNotEmpty && provider.subServices.isNotEmpty) {
        for (var serviceName in apiServiceNames) {
          // Try exact match first
          if (provider.subServices.containsKey(serviceName)) {
            provider.setSubService(serviceName, true);
          } else {
            // Try case-insensitive match
            for (var key in provider.subServices.keys) {
              if (key.toLowerCase() == serviceName.toLowerCase()) {
                provider.setSubService(key, true);
                break;
              }
            }
          }
        }
      }
    }
    
    // Get service radius from API response (convert miles to km)
    final maxLeadDistance = businessProfile?['max_lead_distance_miles'];
    if (maxLeadDistance != null) {
      final radiusInMiles = maxLeadDistance is int ? maxLeadDistance.toDouble() : double.tryParse(maxLeadDistance.toString());
      if (radiusInMiles != null && radiusInMiles > 0) {
        // Convert miles to kilometers (1 mile = 1.60934 km)
        final radiusInKm = radiusInMiles * 1.60934;
        // Clamp to slider range (2-25 km)
        final clampedRadius = radiusInKm.clamp(2.0, 25.0);
        provider.setServiceRadius(clampedRadius);
      }
    }
    
    // Get use current location (if available in API)
    // This might not be in API, so we'll use provider default
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

  Future<void> _handleUpdate() async {
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

        // Create BusinessProfileModel with all data
        final businessProfile = BusinessProfileModel(
          gender: _formatGender(provider.selectedGender),
          dateOfBirth: _formatDateOfBirth(provider.selectedDate),
          alternatePhone: provider.alternatePhone ?? '',
          businessName: existingProfileData?['business_name']?.toString() ?? '',
          tagline: existingProfileData?['tagline']?.toString() ?? '',
          description: existingProfileData?['description']?.toString() ?? '',
          yearsOfExperience: _getYearsOfExperience(provider.selectedExperience),
          primaryServiceCategory: provider.selectedServiceCategory ?? '',
          primaryServiceCategoryId: provider.selectedServiceCategoryId ?? '',
          serviceCategories: _getServiceCategories(provider.selectedServiceCategory, provider.subServices),
          serviceCategoryIds: _getServiceCategoryIds(provider),
          servicesOffered: _getServicesOffered(provider.subServices),
          addressLine: existingProfileData?['address_line']?.toString() ?? '',
          city: provider.selectedCity ?? '',
          state: existingProfileData?['state']?.toString() ?? '',
          postalCode: existingProfileData?['postal_code']?.toString() ?? '',
          latitude: existingProfileData?['latitude']?.toString() ?? '',
          longitude: existingProfileData?['longitude']?.toString() ?? '',
          website: existingProfileData?['website']?.toString() ?? '',
          businessHours: existingProfileData?['business_hours']?.toString() ?? '',
          maxLeadDistanceMiles: (provider.serviceRadius / 1.60934).round(), // Convert km to miles
          autoRespondEnabled: existingProfileData?['auto_respond_enabled'] ?? false,
          autoRespondMessage: existingProfileData?['auto_respond_message']?.toString() ?? '',
          subscriptionTier: existingProfileData?['subscription_tier']?.toString() ?? 'basic',
          availabilityStatus: existingProfileData?['availability_status']?.toString() ?? '',
          logo: existingProfileData?['logo']?.toString() ?? '',
          gallery: existingProfileData?['gallery']?.toString() ?? '',
          idProofType: existingProfileData?['id_proof_type']?.toString() ?? '',
          idProofFile: existingProfileData?['id_proof_file']?.toString() ?? '',
          recentPhoto: existingProfileData?['recent_photo']?.toString() ?? '',
          baseServiceRate: existingProfileData?['base_service_rate']?.toString() ?? '',
        );

        // Update business profile
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
            // Navigate to Edit Profile Step 3
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileStep3Page()),
            );
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
                      child: Form(
                        key: _formKey,
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
                            
                            SizedBox(height: AppDimensions.verticalSpaceM),
                        
                        
                        // Personal Information Card
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
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                
                                SizedBox(height: AppDimensions.verticalSpaceS),
                                
                                // Years of Experience
                                Text(
                                  'Years of Experience',
                                  style: TextStyle(
                                    fontSize: 14.w,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: AppDimensions.verticalSpaceS),
                                DropdownButtonFormField<String>(
                                  initialValue: provider.selectedExperience,
                                  style: AppTextStyles.inputText.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  dropdownColor: Theme.of(context).colorScheme.surface,
                                  decoration: InputDecoration(
                                    hintText: 'Select your experience',
                                    suffixIcon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  items: _experienceOptions.map((String experience) {
                                    return DropdownMenuItem<String>(
                                      value: experience,
                                      child: Text(
                                        experience,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
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
                                    color: Theme.of(context).colorScheme.onSurface,
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
                                                AppColors.primary,
                                              ),
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      )
                                    : DropdownButtonFormField<String>(
                                        initialValue: provider.selectedServiceCategory,
                                        style: AppTextStyles.inputText.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                        dropdownColor: Theme.of(context).colorScheme.surface,
                                        decoration: InputDecoration(
                                          hintText: 'Select service category',
                                          suffixIcon: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        items: provider.serviceCategories.map((category) {
                                          return DropdownMenuItem<String>(
                                            value: category.name,
                                            child: Text(
                                              category.name,
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                            ),
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
                                    'Service Details',
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  
                                  SizedBox(height: AppDimensions.verticalSpaceS),
                                  
                                  Text(
                                    'Sub Services Offered',
                                    style: TextStyle(
                                      fontSize: 14.w,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onSurface,
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
                                                  AppColors.primary,
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
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                                      color: Theme.of(context).colorScheme.onSurface,
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
                                  'Service Details',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onSurface,
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
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '${provider.serviceRadius.toInt()} km',
                                      style: AppTextStyles.titleLarge.copyWith(
                                        fontSize: 14.w,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: AppDimensions.verticalSpaceM),
                                
                                // Slider
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Theme.of(context).colorScheme.primary,
                                    inactiveTrackColor: Theme.of(context).colorScheme.outline,
                                    trackHeight: 4.0,
                                    thumbColor: Theme.of(context).colorScheme.primary,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8.0,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 16.0,
                                    ),
                                    overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  ),
                                  child: Slider(
                                    value: provider.serviceRadius,
                                    min: 2,
                                    max: 25,
                                    divisions: 23,
                                    activeColor: Theme.of(context).colorScheme.primary,
                                    inactiveColor: Theme.of(context).colorScheme.outline,
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
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      '25 km',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        fontSize: 12.sp,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                      color: Theme.of(context).colorScheme.onSurface,
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
            
            // Update Button
            Container(
              padding: EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.buttonRadius,
                        ),
                      ),
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
}

