import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../providers/business_owner_provider.dart';
import '../../models/business_owner_profile/business_profile.dart';
import 'edit_profile_step2_page.dart';

/// Edit Profile Page
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _phoneNumberController = TextEditingController();
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
    'Saket',
    'New York',
  ];

  final ImagePicker _imagePicker = ImagePicker();
  final ValueNotifier<File?> _selectedImageNotifier = ValueNotifier<File?>(null);

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
      
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
      
      // Get name from API response
      final userName = user?['name']?.toString() ?? 
                       businessProfile?['name']?.toString() ?? 
                       provider.fullName ?? 
                       'Alexander Knight';

      
      // Get phone from API response (use main phone, not alternate_phone)
      final phone = businessProfile?['phone']?.toString() ?? 
                    user?['phone']?.toString() ??
                    provider.mobileNumber ?? 
                    '+14987889999';
      
      // Get service category from API response
      final serviceCategory = businessProfile?['primary_service_category']?.toString();
      if (serviceCategory != null && serviceCategory.isNotEmpty) {
        provider.setSelectedServiceCategory(serviceCategory);
      }
      
      // Get location from API response
      final city = businessProfile?['city']?.toString();
      if (city != null && city.isNotEmpty) {
        // Add city to the list if it's not already there
        if (!_cityOptions.contains(city)) {
          _cityOptions.insert(0, city);
        }
        provider.setSelectedCity(city);
      }
      
      // Get gender from API response
      final gender = businessProfile?['gender']?.toString();
      if (gender != null && gender.isNotEmpty) {
        // Capitalize first letter to match dropdown options
        final capitalizedGender = gender.substring(0, 1).toUpperCase() + gender.substring(1).toLowerCase();
        if (_genderOptions.contains(capitalizedGender)) {
          provider.setSelectedGender(capitalizedGender);
        } else {
          // If exact match not found, try to match case-insensitively
          final lowerGender = gender.toLowerCase();
          for (var option in _genderOptions) {
            if (option.toLowerCase() == lowerGender) {
              provider.setSelectedGender(option);
              break;
            }
          }
        }
      } else if (provider.selectedGender != null && provider.selectedGender!.isNotEmpty) {
        // Use existing provider value if API doesn't have it
        // (already set, no need to set again)
      }
      
      // Get date of birth from API response
      final dateOfBirth = businessProfile?['date_of_birth']?.toString();
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
        try {
          // Try parsing ISO format (YYYY-MM-DD)
          final date = DateTime.parse(dateOfBirth);
          provider.setSelectedDate(date);
          _dateOfBirthController.text = _formatDate(date);
        } catch (e) {
          // If parsing fails, try other formats or use provider value
          if (provider.selectedDate != null) {
            _dateOfBirthController.text = _formatDate(provider.selectedDate);
          }
        }
      } else if (provider.selectedDate != null) {
        // Use existing provider value if API doesn't have it
        _dateOfBirthController.text = _formatDate(provider.selectedDate);
      }
      
      // Get alternate phone from API response
      final alternatePhone = businessProfile?['alternate_phone']?.toString() ?? 
                             provider.alternatePhone ?? 
                             '';
      if (alternatePhone.isNotEmpty) {
        _alternatePhoneController.text = alternatePhone;
        provider.setAlternatePhone(alternatePhone);
      }
      
      // Pre-populate fields with API response values
      _usernameController.text = userName;
      _phoneNumberController.text = phone;

      
      // Initialize service categories if needed
      if (provider.serviceCategories.isEmpty) {
        provider.initializeStep2();
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _dateOfBirthController.dispose();
    _phoneNumberController.dispose();
    _alternatePhoneController.dispose();
    _selectedImageNotifier.dispose();
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
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatDateOfBirth(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatGender(String? gender) {
    if (gender == null || gender.isEmpty) return '';
    return gender.toLowerCase();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        _selectedImageNotifier.value = File(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Hide keyboard when API is hit
      FocusScope.of(context).unfocus();
      
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);

      if (provider.isLoading) return;

      try {
        // Get existing business profile data first
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
        
        // Get form values
        final name = _usernameController.text.trim();
        final phone = _phoneNumberController.text.trim();
        final alternatePhone = _alternatePhoneController.text.trim();
        final serviceCategory = provider.selectedServiceCategory;
        final city = provider.selectedCity;
        
        // Create BusinessProfileModel with all fields
        final businessProfile = BusinessProfileModel(
          gender: _formatGender(provider.selectedGender),
          dateOfBirth: _formatDateOfBirth(provider.selectedDate),
          alternatePhone: alternatePhone,
          businessName: existingProfileData?['business_name']?.toString() ?? '',
          tagline: existingProfileData?['tagline']?.toString() ?? '',
          description: existingProfileData?['description']?.toString() ?? '',
          yearsOfExperience: existingProfileData?['years_of_experience'] ?? 0,
          primaryServiceCategory: serviceCategory ?? '',
          primaryServiceCategoryId: provider.selectedServiceCategoryId ?? '',
          serviceCategories: existingProfileData?['service_categories']?.toString() ?? '',
          serviceCategoryIds: existingProfileData?['service_category_ids']?.toString() ?? '',
          servicesOffered: existingProfileData?['services_offered']?.toString() ?? '',
          addressLine: existingProfileData?['address_line']?.toString() ?? '',
          city: city ?? '',
          state: existingProfileData?['state']?.toString() ?? '',
          postalCode: existingProfileData?['postal_code']?.toString() ?? '',
          latitude: existingProfileData?['latitude']?.toString() ?? '',
          longitude: existingProfileData?['longitude']?.toString() ?? '',
          website: existingProfileData?['website']?.toString() ?? '',
          businessHours: existingProfileData?['business_hours']?.toString() ?? '',
          maxLeadDistanceMiles: existingProfileData?['max_lead_distance_miles'] ?? (provider.serviceRadius / 1.60934).round(),
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

        // Update business profile with files
        final success = await provider.updateBusinessProfileWithFiles(
          businessProfile,
          name: name,
          phone: phone,
          idProofFile: null,
          recentPhoto: _selectedImageNotifier.value,
          logoFile: null,
          context: context,
        );
        
        if (!mounted) return;
        
        if (success) {
          // Clear selected image so it shows the updated network image
          _selectedImageNotifier.value = null;
          
          // Navigate to Edit Profile Step 2
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileStep2Page()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile. Please try again.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
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

                            SizedBox(height: AppDimensions.verticalSpaceL),
                            
                            // Personal Information Section
                            Text(
                              'Personal Information',
                              style: AppTextStyles.titleLarge.copyWith(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          
                          SizedBox(height: AppDimensions.verticalSpaceS),
                          
                            // Full Name Field
                            Text('Full Name', style: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onBackground,
                            )),
                            SizedBox(height: AppDimensions.verticalSpaceS),
                            TextFormField(
                              controller: _usernameController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: const InputDecoration(hintText: 'Your full name'),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                          
                          SizedBox(height: AppDimensions.verticalSpaceS),
                          
                            // Gender Field
                            Text(
                              'Gender',
                                style: TextStyle(
                                  fontSize: 14.w,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onBackground,
                                )
                            ),
                            SizedBox(height: AppDimensions.verticalSpaceS),
                            DropdownButtonFormField<String>(
                              initialValue: provider.selectedGender,
                              decoration: const InputDecoration(hintText: 'Select your gender'),
                              style: AppTextStyles.inputText.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              items: _genderOptions.map((String gender) {
                                return DropdownMenuItem<String>(
                                  value: gender,
                                  child: Text(
                                    gender,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                provider.setSelectedGender(newValue);
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
                                  color: Theme.of(context).colorScheme.onBackground,
                                )
                            ),
                            SizedBox(height: AppDimensions.verticalSpaceS),
                            TextFormField(
                              controller: _dateOfBirthController,
                              readOnly: true,
                              onTap: () {
                                _selectDate(context);
                              },
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Select your date of birth',
                                suffixIcon: Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true || provider.selectedDate == null) {
                                  return 'Please select your date of birth';
                                }
                                return null;
                              },
                            ),
                          
                          SizedBox(height: AppDimensions.verticalSpaceS),
                          
                            // Mobile Number Field
                            Text(
                              'Mobile Number',
                                style: TextStyle(
                                  fontSize: 14.w,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onBackground,
                                )
                            ),
                            SizedBox(height: AppDimensions.verticalSpaceS),
                            TextFormField(
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.phone,
                              maxLength: 11,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
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
                          
                          SizedBox(height: AppDimensions.verticalSpaceS),
                          
                            // Alternate Phone Number Field
                            Text(
                              'Alternate Phone Number',
                                style: TextStyle(
                                  fontSize: 14.w,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onBackground,
                                )
                            ),
                            SizedBox(height: AppDimensions.verticalSpaceS),
                            TextFormField(
                              controller: _alternatePhoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 11,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
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
                          
                          SizedBox(height: AppDimensions.verticalSpaceS),
                          
                            // City / Town Field
                            Text(
                              'City / Town',
                                style: TextStyle(
                                  fontSize: 14.w,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onBackground,
                                )
                            ),
                            SizedBox(height: AppDimensions.verticalSpaceS),
                            DropdownButtonFormField<String>(
                              initialValue: provider.selectedCity,
                              decoration: const InputDecoration(hintText: 'Your city'),
                              style: AppTextStyles.inputText.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              items: _cityOptions.map((String city) {
                                final displayText = city == 'Saket' 
                                    ? 'Saket'
                                    : city;
                                return DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(
                                    displayText,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                provider.setSelectedCity(newValue);
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

