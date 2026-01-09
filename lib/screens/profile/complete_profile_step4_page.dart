import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../providers/business_owner_provider.dart';
import '../../models/business_owner_profile/business_profile.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import 'complete_profile_step5_page.dart';

/// Complete Profile Page - Step 2 of 5
class CompleteProfileStep4Page extends StatefulWidget {
  const CompleteProfileStep4Page({super.key});

  @override
  State<CompleteProfileStep4Page> createState() => _CompleteProfileStep4PageState();
}

class _CompleteProfileStep4PageState extends State<CompleteProfileStep4Page> {
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
    });
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
      // If end time is already set, check if new start time is valid
      if (provider.endTime != null) {
        // Convert TimeOfDay to minutes for easier comparison
        int timeToMinutes(TimeOfDay time) {
          return time.hour * 60 + time.minute;
        }
        
        final startMinutes = timeToMinutes(picked);
        final endMinutes = timeToMinutes(provider.endTime!);
        
        // Check if new start time is greater than or equal to end time
        if (startMinutes >= endMinutes) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Start time must be less than end time. End time will be cleared.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
            ),
          );
          // Clear end time since it's no longer valid
          provider.setEndTime(null);
        } else {
          // Check if end time is still within 24 hours
          final timeDifference = endMinutes - startMinutes;
          if (timeDifference > 1440) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('End time exceeds 24 hours from new start time. End time will be cleared.'),
                backgroundColor: AppColors.error,
                duration: Duration(seconds: 3),
              ),
            );
            // Clear end time since it's no longer valid
            provider.setEndTime(null);
          }
        }
      }
      
      provider.setStartTime(picked);
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
    
    // Check if start time is set
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
      
      // Convert TimeOfDay to minutes for easier comparison
      int timeToMinutes(TimeOfDay time) {
        return time.hour * 60 + time.minute;
      }
      
      final startMinutes = timeToMinutes(startTime);
      final endMinutes = timeToMinutes(picked);
      
      // Check if end time is less than start time (same day)
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
      
      // Check if end time is within 24 hours (1440 minutes)
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
      
      // Validation passed, set the end time
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

  String _extractServiceRateNumber(String? rate) {
    if (rate == null || rate.isEmpty) return '';
    return rate.replaceAll('\$', '').replaceAll(' ', '').trim();
  }

  Future<void> _handleNext() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Hide keyboard when API is hit
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
        // Prepare file objects from provider
        File? idProofFile = provider.selectedIdDocument;
        File? recentPhoto = provider.selectedPhoto;
        File? logoFile; // Logo is empty for now

        // Create BusinessProfileModel with step 4 data and previous steps data
        final businessProfile = BusinessProfileModel(
          gender: _formatGender(provider.selectedGender),
          dateOfBirth: _formatDateOfBirth(provider.selectedDate),
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
          subscriptionTier: 'basic',
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
            // Navigate to Step 5
            Navigator.push(context, MaterialPageRoute(builder: (context) => CompleteProfileStep5Page(),));
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
                                  'Step 4 of 5',
                                  style: AppTextStyles.labelMedium.copyWith(
                                      fontSize: 13.sp,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${(provider.step4Progress * 100).toInt()}%',
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
                                value: provider.step4Progress,
                                backgroundColor: AppColors.borderLight,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                                minHeight: 6.h,
                              ),
                            ),

                        SizedBox(height: AppDimensions.verticalSpaceM),

                        // Availability & Rates Card
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
                                  'Availability & Rates',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                
                                SizedBox(height: AppDimensions.verticalSpaceS),
                                
                                Text(
                                  'Working Hours',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textPrimary,
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
                                            hintStyle: AppTextStyles.inputText.copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                            suffixIcon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: AppColors.primary,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                              borderSide: const BorderSide(
                                                color: AppColors.borderLight,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                              borderSide: const BorderSide(
                                                color: AppColors.borderLight,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                              borderSide: const BorderSide(
                                                color: AppColors.primary,
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
                                                ? AppColors.textPrimary 
                                                : AppColors.textHint,
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
                                            hintStyle: AppTextStyles.inputText.copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                            suffixIcon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: AppColors.primary,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                              borderSide: const BorderSide(
                                                color: AppColors.borderLight,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                              borderSide: const BorderSide(
                                                color: AppColors.borderLight,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                              borderSide: const BorderSide(
                                                color: AppColors.primary,
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
                                                ? AppColors.textPrimary 
                                                : AppColors.textHint,
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



                        // Service Details Card - Sub Services
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
                                  'Availability Days',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
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
                                  'Base Service Rate',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: AppDimensions.verticalSpaceS),
                                DropdownButtonFormField<String>(
                                  initialValue: provider.serviceRate,
                                  style: AppTextStyles.inputText,
                                  decoration: const InputDecoration(
                                    hintText: 'Select service rate',
                                    suffixIcon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: AppColors.iconSecondary,
                                    ),
                                  ),
                                  items: _serviceRateOptions.map((String rate) {
                                    return DropdownMenuItem<String>(
                                      value: rate,
                                      child: Text(rate),
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
                                    color: AppColors.textPrimary,
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

