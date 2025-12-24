import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../providers/business_owner_provider.dart';

/// Edit Profile Page
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  
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

    _phoneNumberController.dispose();
    _selectedImageNotifier.dispose();
    super.dispose();
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
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
      
      // Get form values
      final name = _usernameController.text.trim();

      final phone = _phoneNumberController.text.trim();
      final serviceCategory = provider.selectedServiceCategory;
      final city = provider.selectedCity;
      
      // Call API to update profile
      final success = await provider.updateProfile(
        name: name,
        phone: phone,
        serviceCategory: serviceCategory,
        city: city,
        recentPhoto: _selectedImageNotifier.value,
        context: context,
      );
      
      if (!mounted) return;
      
      if (success) {
        // Clear selected image so it shows the updated network image
        _selectedImageNotifier.value = null;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<BusinessOwnerProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Blue Header Section
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // BLUE HEADER BACKGROUND
                        Container(
                          width: double.infinity,
                          height: 210,
                          padding: EdgeInsets.only(
                            bottom: AppDimensions.verticalSpaceXL,
                            left: AppDimensions.screenPaddingHorizontal,
                            right: AppDimensions.screenPaddingHorizontal,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () =>  Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back, color: AppColors.textOnPrimary),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              SizedBox(width: AppDimensions.paddingS),
                              Expanded(
                                child: Text(
                                  'Edit Profile',
                                  style: AppTextStyles.appBarTitle.copyWith(
                                    color: AppColors.textOnPrimary,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(width: AppDimensions.paddingM + 24.w),
                            ],
                          ),
                        ),

                        // ⭐ CENTER AVATAR OVERLAPPING BOTTOM (THE IMPORTANT PART)
                        Positioned(
                          bottom: -60, // 👈 half of avatar height to overlap
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 120.w,
                                    height: 120.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.backgroundSecondary,
                                      border: Border.all(
                                        color: AppColors.textOnPrimary,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.shadowMedium,
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ValueListenableBuilder<File?>(
                                      valueListenable: _selectedImageNotifier,
                                      builder: (context, selectedImage, child) {
                                        if (selectedImage != null) {
                                          return ClipOval(
                                            child: Image.file(selectedImage, fit: BoxFit.cover),
                                          );
                                        }
                                        
                                        // Get profile image from API response (profile page data)
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
                                        
                                        final profileImageUrl = businessProfile?['recent_photo']?.toString();
                                        
                                        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
                                          return ClipOval(
                                            child: Image.network(
                                              profileImageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(Icons.person, size: 60.w, color: AppColors.textSecondary);
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
                                          );
                                        } else if (provider.photoPath != null && provider.photoPath!.isNotEmpty) {
                                          return ClipOval(
                                            child: Image.asset(provider.photoPath!, fit: BoxFit.cover),
                                          );
                                        } else {
                                          return Icon(Icons.person, size: 60.w, color: AppColors.textSecondary);
                                        }
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 4,
                                    child: Container(
                                      width: 24.w,
                                      height: 24.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.surface,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 12.w,
                                        color: AppColors.textOnPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Form Section
                    Padding(
                      padding: EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: AppDimensions.verticalSpaceXL),
                            
                            // Username Field
                            Text(
                              'Username',
                              style: AppTextStyles.labelLarge,
                            ),
                            SizedBox(height: AppDimensions.verticalSpaceS),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                hintText: 'Enter your username',
                                hintStyle: AppTextStyles.inputHint,
                              ),
                              style: AppTextStyles.inputText,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                            ),
                            

                            
                            // Email Field


                            
                            SizedBox(height: AppDimensions.verticalSpaceL),
                            
                            // Phone Number Field
                            Text(
                              'Phone Number',
                              style: AppTextStyles.labelLarge,
                            ),
                            SizedBox(height: AppDimensions.verticalSpaceS),
                            TextFormField(
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'Enter your phone number',
                                hintStyle: AppTextStyles.inputHint,
                              ),
                              style: AppTextStyles.inputText,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                            
                            SizedBox(height: AppDimensions.verticalSpaceL),
                            
                            // Service Dropdown
                            Text(
                              'Service',
                              style: AppTextStyles.labelLarge,
                            ),
                            SizedBox(height: AppDimensions.verticalSpaceS),
                            provider.isLoadingCategories
                                ? const Center(child: CircularProgressIndicator())
                                : DropdownButtonFormField<String>(
                                    initialValue: provider.selectedServiceCategory,
                                    style: AppTextStyles.inputText,
                                    decoration: InputDecoration(
                                      hintText: 'Select service',
                                      hintStyle: AppTextStyles.inputHint,
                                      suffixIcon: const Icon(
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
                                    onChanged: (String? newValue) {
                                      provider.setSelectedServiceCategory(newValue);
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a service';
                                      }
                                      return null;
                                    },
                                  ),
                            
                            SizedBox(height: AppDimensions.verticalSpaceL),
                            
                            // Location Dropdown
                            Text(
                              'Location',
                              style: AppTextStyles.labelLarge,
                            ),
                            SizedBox(height: AppDimensions.verticalSpaceS),
                            DropdownButtonFormField<String>(
                              initialValue: provider.selectedCity,
                              style: AppTextStyles.inputText,
                              decoration: InputDecoration(
                                hintText: 'Select location',
                                hintStyle: AppTextStyles.inputHint,
                                suffixIcon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.iconSecondary,
                                ),
                              ),
                              items: _cityOptions.map((String city) {
                                final displayText = city == 'Saket' 
                                    ? 'Saket'
                                    : city;
                                return DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(displayText),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                provider.setSelectedCity(newValue);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a location';
                                }
                                return null;
                              },
                            ),
                            
                            SizedBox(height: AppDimensions.verticalSpaceXL),
                            
                            // Update Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.textOnPrimary,
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppDimensions.paddingM,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.buttonRadius,
                                    ),
                                  ),
                                ),
                                onPressed: provider.isLoading ? null : _handleUpdate,
                                child: Text(
                                  'Update',
                                  style: AppTextStyles.buttonLarge,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: AppDimensions.verticalSpaceXL),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Loader Overlay
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
          );
        },
      ),
    );
  }
}

