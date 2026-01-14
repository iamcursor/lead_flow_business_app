import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/business_owner_provider.dart';
import '../../models/business_owner_profile/business_profile.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import 'edit_profile_step5_page.dart';

/// Edit Profile Page - Step 4
class EditProfileStep4Page extends StatefulWidget {
  const EditProfileStep4Page({super.key});

  @override
  State<EditProfileStep4Page> createState() => _EditProfileStep4PageState();
}

class _EditProfileStep4PageState extends State<EditProfileStep4Page> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _serviceRateOptions = [
    '\$500',
    '\$600',
    '\$700',
    '\$800',
    '\$900',
    '\$1000',
    '\$1200',
    '\$1500',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize provider after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
      provider.initializeStep4();
      _loadProfileData(provider);
    });
  }

  void _loadProfileData(BusinessOwnerProvider provider) {
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
    
    // Get business hours from API response
    final businessHours = businessProfile?['business_hours'];
    if (businessHours != null) {
      if (businessHours is Map<String, dynamic>) {
        // Parse start_time and end_time from JSON object
        final startTimeStr = businessHours['start_time']?.toString();
        final endTimeStr = businessHours['end_time']?.toString();
        
        if (startTimeStr != null && startTimeStr.isNotEmpty) {
          final startTime = _parseTimeString(startTimeStr);
          if (startTime != null) {
            provider.setStartTime(startTime);
          }
        }
        
        if (endTimeStr != null && endTimeStr.isNotEmpty) {
          final endTime = _parseTimeString(endTimeStr);
          if (endTime != null) {
            provider.setEndTime(endTime);
          }
        }
      } else if (businessHours is String && businessHours.isNotEmpty) {
        // Try parsing as string format "HH:mm - HH:mm"
        final parts = businessHours.split(' - ');
        if (parts.length == 2) {
          final startTime = _parseTimeString(parts[0].trim());
          final endTime = _parseTimeString(parts[1].trim());
          if (startTime != null) {
            provider.setStartTime(startTime);
          }
          if (endTime != null) {
            provider.setEndTime(endTime);
          }
        }
      }
    }
    
    // Get base service rate from API response
    final baseServiceRate = businessProfile?['base_service_rate']?.toString();
    if (baseServiceRate != null && baseServiceRate.isNotEmpty) {
      // Convert "500.00" to "$500" format
      final rateNumber = double.tryParse(baseServiceRate);
      if (rateNumber != null) {
        final rateString = '\$${rateNumber.toInt()}';
        if (_serviceRateOptions.contains(rateString)) {
          provider.setServiceRate(rateString);
        } else {
          // If not in options, add it or use closest match
          provider.setServiceRate(rateString);
        }
      }
    }
    
    // Get availability status - if available, we might need to set default days
    // Note: API might not store specific days, so we'll use availability_status as indicator
    final availabilityStatus = businessProfile?['availability_status']?.toString();
    // If status is "available", we can assume some days are selected, but we don't know which ones
    // So we'll leave availability days as they are (user can update them)
  }

  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      // Parse format "HH:mm" (e.g., "21:47", "00:47")
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0].trim());
        final minute = int.tryParse(parts[1].trim());
        if (hour != null && minute != null && hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      // If parsing fails, return null
    }
    return null;
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: provider.startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != provider.startTime) {
      if (provider.endTime != null) {
        int timeToMinutes(TimeOfDay time) {
          return time.hour * 60 + time.minute;
        }
        
        final startMinutes = timeToMinutes(picked);
        final endMinutes = timeToMinutes(provider.endTime!);
        
        if (startMinutes >= endMinutes) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Start time must be less than end time. End time will be cleared.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
            ),
          );
          provider.setEndTime(null);
        } else {
          final timeDifference = endMinutes - startMinutes;
          if (timeDifference > 1440) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('End time exceeds 24 hours from new start time. End time will be cleared.'),
                backgroundColor: AppColors.error,
                duration: Duration(seconds: 3),
              ),
            );
            provider.setEndTime(null);
          }
        }
      }
      
      provider.setStartTime(picked);
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
    
    if (provider.startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start time first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: provider.endTime ?? provider.startTime!,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != provider.endTime) {
      final startTime = provider.startTime!;
      
      int timeToMinutes(TimeOfDay time) {
        return time.hour * 60 + time.minute;
      }
      
      final startMinutes = timeToMinutes(startTime);
      final endMinutes = timeToMinutes(picked);
      
      if (endMinutes <= startMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be greater than start time'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      
      final timeDifference = endMinutes - startMinutes;
      if (timeDifference > 1440) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be within 24 hours of start time'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      
      provider.setEndTime(picked);
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
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

  String _extractServiceRateNumber(String? rate) {
    if (rate == null || rate.isEmpty) return '';
    return rate.replaceAll('\$', '').replaceAll(' ', '').trim();
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);

      if (provider.isLoading) return;

      // Validate all required fields
      if (provider.startTime == null || 
          provider.endTime == null ||
          provider.serviceRate == null || 
          provider.serviceRate!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All fields are required'),
          ),
        );
        return;
      }

      // Validate at least one availability day is selected
      final hasSelectedAvailabilityDays = provider.availabilityDays.values.any((isSelected) => isSelected);
      if (!hasSelectedAvailabilityDays) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All fields are required'),
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
             // Navigate to Edit Profile Step 5
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const EditProfileStep5Page()),
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

                        // Availability & Rates Card
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
                                  'Availability & Rates',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                
                                SizedBox(height: AppDimensions.verticalSpaceS),
                                
                                Text(
                                  'Working Hours',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                
                                SizedBox(height: AppDimensions.verticalSpaceS),
                                
                                // Time Picker Fields
                                Row(
                                  children: [
                                    // Start Time
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _selectStartTime(context),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            hintText: 'Start time',
                                            suffixIcon: Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                              borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.outline,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                              borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.outline,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                              borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: AppDimensions.paddingM,
                                              vertical: AppDimensions.paddingM,
                                            ),
                                          ),
                                          child: Text(
                                            provider.startTime != null ? _formatTime(provider.startTime) : 'Start time',
                                            style: AppTextStyles.inputText.copyWith(
                                              color: provider.startTime != null 
                                                ? Theme.of(context).colorScheme.onSurface 
                                                : Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    SizedBox(width: AppDimensions.paddingM),
                                    
                                    // End Time
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _selectEndTime(context),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            hintText: 'End time',
                                            suffixIcon: Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                              borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.outline,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                              borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.outline,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                              borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: AppDimensions.paddingM,
                                              vertical: AppDimensions.paddingM,
                                            ),
                                          ),
                                          child: Text(
                                            provider.endTime != null ? _formatTime(provider.endTime) : 'End time',
                                            style: AppTextStyles.inputText.copyWith(
                                              color: provider.endTime != null 
                                                ? Theme.of(context).colorScheme.onSurface 
                                                : Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: AppDimensions.verticalSpaceL),

                        // Availability Days Card
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
                                  'Availability Days',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),

                                SizedBox(height: AppDimensions.verticalSpaceS),

                                // Checkboxes
                                ...provider.availabilityDays.keys.map((String service) {
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
                                    value: provider.availabilityDays[service],
                                    onChanged: (bool? value) {
                                      provider.setAvailabilityDay(service, value ?? false);
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: AppDimensions.verticalSpaceM),

                        // Service Rate Card
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
                                  'Base Service Rate',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: AppDimensions.verticalSpaceS),
                                DropdownButtonFormField<String>(
                                  value: provider.serviceRate,
                                  style: AppTextStyles.inputText.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  dropdownColor: Theme.of(context).colorScheme.surface,
                                  decoration: InputDecoration(
                                    hintText: 'Select service rate',
                                    suffixIcon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  items: _serviceRateOptions.map((String rate) {
                                    return DropdownMenuItem<String>(
                                      value: rate,
                                      child: Text(
                                        rate,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    provider.setServiceRate(newValue);
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select service rate';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: AppDimensions.verticalSpaceM),
                                Text(
                                  'This is your starting rate per hour. You can adjust rates for specific services later',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: AppDimensions.verticalSpaceM),

                        // Tip Banner
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
                                  text: 'Tip: Being available on weekends and setting competitive rates can help you get more bookings!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warningDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

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

