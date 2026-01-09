import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lead_flow_business/screens/profile/complete_profile_step2_page.dart';
import 'package:provider/provider.dart';
import '../../providers/business_owner_provider.dart';
import '../../models/business_owner_profile/business_profile.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';

/// Complete Profile Page - Step 1 of 5
class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _alternatePhoneController = TextEditingController();
  
  
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _cityOptions = [
    'Lahore',
    'Karachi',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Multan',
    'Peshawar',
    'Quetta',
  ];

  @override
  void initState() {
    super.initState();
    
    // Add listeners to update progress when fields change
    _fullNameController.addListener(_updateProgress);
    _dateOfBirthController.addListener(_updateProgress);
    _mobileNumberController.addListener(_updateProgress);
    _alternatePhoneController.addListener(_updateProgress);
    
    // Initialize provider after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
      provider.initializeStep1();
      
      // Pre-populate fields with existing values from provider
      if (provider.fullName != null && provider.fullName!.isNotEmpty) {
        _fullNameController.text = provider.fullName!;
      }
      
      if (provider.selectedDate != null) {
        _dateOfBirthController.text = _formatDate(provider.selectedDate);
      }
      
      if (provider.mobileNumber != null && provider.mobileNumber!.isNotEmpty) {
        _mobileNumberController.text = provider.mobileNumber!;
      }
      
      if (provider.alternatePhone != null && provider.alternatePhone!.isNotEmpty) {
        _alternatePhoneController.text = provider.alternatePhone!;
      }
      
      _updateProgress();
    });
  }
  
  void _updateProgress() {
    final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
    // Update provider values (onChanged callbacks handle typing flags)
    if (_fullNameController.text.trim().isNotEmpty) {
      provider.setFullName(_fullNameController.text.trim());
    }
    if (_mobileNumberController.text.trim().isNotEmpty) {
      provider.setMobileNumber(_mobileNumberController.text.trim());
    }
    if (_alternatePhoneController.text.trim().isNotEmpty) {
      provider.setAlternatePhone(_alternatePhoneController.text.trim());
    }
    provider.setSelectedCity(provider.selectedCity);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _mobileNumberController.dispose();
    _alternatePhoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
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
    if (picked != null && picked != provider.selectedDate) {
      provider.setSelectedDate(picked);
      _dateOfBirthController.text = _formatDate(picked);
      _updateProgress();
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatGender(String? gender) {
    if (gender == null || gender.isEmpty) return '';
    return gender.toLowerCase();
  }

  String _formatDateOfBirth(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _handleNext() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Hide keyboard when API is hit
      FocusScope.of(context).unfocus();
      
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);

      if (provider.isLoading) return;

      try {
        // Create BusinessProfileModel with step 1 data only
        final businessProfile = BusinessProfileModel(
          gender: _formatGender(provider.selectedGender),
          dateOfBirth: _formatDateOfBirth(provider.selectedDate),
          alternatePhone: provider.alternatePhone ?? '',
          businessName: '',
          tagline: '',
          description: '',
          yearsOfExperience: 0, // Will be set in step 2/5
          primaryServiceCategory: '', // Will be set in step 2/5
          primaryServiceCategoryId: '', // Will be set in step 2/5
          serviceCategories: '', // Will be set in step 2/5
          serviceCategoryIds: '', // Will be set in step 2/5
          servicesOffered: '', // Will be set in step 2/5
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

        // Update business profile (no files for step 1)
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
            // Navigate to Step 2
            Navigator.push(context, MaterialPageRoute(builder: (context) => CompleteProfileStep2Page(),));
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
                                  'Step 1 of 5',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    fontSize: 13.sp,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${(provider.step1Progress * 100).toInt()}%',
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
                                value: provider.step1Progress,
                                backgroundColor: AppColors.borderLight,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                                minHeight: 6.h,
                              ),
                            ),
                        
                        SizedBox(height: AppDimensions.verticalSpaceL),
                        
                        // Personal Information Section
                        Text(
                          'Personal Information',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceS),
                      
                        // Full Name Field
                        Text('Full Name', style: TextStyle(
                          fontSize: 14.w,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,

                        )),
                        SizedBox(height: AppDimensions.verticalSpaceS),
                        TextFormField(
                          controller: _fullNameController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(hintText: 'Your full name'),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            provider.setFullName(value.trim().isEmpty ? null : value.trim());
                          },
                        ),
                        // Show message below name field if empty and not started typing
                        if (!provider.hasStartedTypingName && (_fullNameController.text.isEmpty || provider.fullName == null))
                          Padding(
                            padding: EdgeInsets.only(top: AppDimensions.verticalSpaceXS),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 14.w,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    'Your name must match your ID card',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceS),
                      
                        // Gender Field
                        Text(
                          'Gender',
                            style: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,

                            )
                          ),

                        SizedBox(height: AppDimensions.verticalSpaceS),
                        DropdownButtonFormField<String>(
                          initialValue: provider.selectedGender,
                          decoration: const InputDecoration(hintText: 'Select your gender'),
                          style: AppTextStyles.inputText,
                          items: _genderOptions.map((String gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            provider.setSelectedGender(newValue);
                            _updateProgress();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your gender';
                            }
                            return null;
                          },
                        ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceS),
                      
                        // Date of Birth Field
                        Text(
                          'Date of Birth',
                            style: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,

                            )
                        ),
                        SizedBox(height: AppDimensions.verticalSpaceS),
                        TextFormField(
                          controller: _dateOfBirthController,
                          readOnly: true,
                          onTap: () {
                            provider.setHasStartedTypingDateOfBirth(true);
                            _selectDate(context);
                          },
                          decoration: const InputDecoration(
                            hintText: 'Select your date of birth',
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: AppColors.iconSecondary,
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true || provider.selectedDate == null) {
                              return 'Please select your date of birth';
                            }
                            return null;
                          },
                        ),
                        // Show message below date of birth field if empty and not started typing
                        if (!provider.hasStartedTypingDateOfBirth && (_dateOfBirthController.text.isEmpty || provider.selectedDate == null))
                          Padding(
                            padding: EdgeInsets.only(top: AppDimensions.verticalSpaceXS),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 14.w,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    'Date of birth must match your ID card',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceS),
                      
                        // Mobile Number Field
                        Text(
                          'Mobile Number',
                            style: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,

                            )
                        ),
                        SizedBox(height: AppDimensions.verticalSpaceS),
                        TextFormField(
                          controller: _mobileNumberController,
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                          decoration: const InputDecoration(
                            hintText: 'Your phone no',
                            counterText: '', // Hide character counter
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your mobile number';
                            }
                            if (value != null && value.length > 11) {
                              return 'Phone number must not be longer than 11 digits';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            provider.setMobileNumber(value.trim().isEmpty ? null : value.trim());
                          },
                        ),
                        // Show message below phone field if empty and not started typing
                        if (!provider.hasStartedTypingPhone && (_mobileNumberController.text.isEmpty || provider.mobileNumber == null))
                          Padding(
                            padding: EdgeInsets.only(top: AppDimensions.verticalSpaceXS),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 14.w,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    'Phone number cannot be longer than 11 digits',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        SizedBox(height: AppDimensions.verticalSpaceS),
                        
                        // Alternate Phone Number Field
                        Text(
                          'Alternate Phone Number',
                            style: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,

                            )
                        ),
                        SizedBox(height: AppDimensions.verticalSpaceS),
                        TextFormField(
                          controller: _alternatePhoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                          decoration: const InputDecoration(
                            hintText: 'Your phone no',
                            counterText: '', // Hide character counter
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter alternate phone number';
                            }
                            if (value != null && value.length > 11) {
                              return 'Phone number must not be longer than 11 digits';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            provider.setAlternatePhone(value.trim().isEmpty ? null : value.trim());
                          },
                        ),
                        // Show message below alternate phone field if empty and not started typing
                        if (!provider.hasStartedTypingAlternatePhone && (_alternatePhoneController.text.isEmpty || provider.alternatePhone == null))
                          Padding(
                            padding: EdgeInsets.only(top: AppDimensions.verticalSpaceXS),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 14.w,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    'Phone number cannot be longer than 11 digits',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        SizedBox(height: AppDimensions.verticalSpaceS),
                        
                        // City / Town Field
                        Text(
                          'City / Town',
                            style: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,

                            )
                        ),
                        SizedBox(height: AppDimensions.verticalSpaceS),
                        DropdownButtonFormField<String>(
                          initialValue: provider.selectedCity,
                          decoration: const InputDecoration(hintText: 'Your city'),
                          style: AppTextStyles.inputText,

                          items: _cityOptions.map((String city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            provider.setSelectedCity(newValue);
                            _updateProgress();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your city';
                            }
                            return null;
                          },
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

