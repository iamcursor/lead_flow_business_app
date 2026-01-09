import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/business_owner_profile/business_profile.dart';
import '../models/business_owner_profile/change_password_model.dart';
import '../models/service_category/service_category_model.dart';
import '../models/service_category/sub_category_model.dart';
import '../services/business_owner_profile_services.dart';
import '../services/service_category_service.dart';
import 'auth_provider.dart';

class BusinessOwnerProvider with ChangeNotifier {
  // Step 1 - Personal Information

  final BusinessProfileService _service = BusinessProfileService();
  final ServiceCategoryService _categoryService = ServiceCategoryService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingProfile = false;
  bool get isLoadingProfile => _isLoadingProfile;

  Map<String, dynamic>? _response;
  Map<String, dynamic>? get response => _response;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ID Card Analysis Result
  Map<String, dynamic>? _idCardAnalysisResult;
  Map<String, dynamic>? get idCardAnalysisResult => _idCardAnalysisResult;

  String? _fullName;
  String? get fullName => _fullName;
  
  String? _selectedGender;
  String? get selectedGender => _selectedGender;
  
  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;
  
  String? _selectedCity;
  String? get selectedCity => _selectedCity;
  
  String? _mobileNumber;
  String? get mobileNumber => _mobileNumber;
  
  String? _alternatePhone;
  String? get alternatePhone => _alternatePhone;
  
  // Track if user has started typing in fields (for showing/hiding messages)
  bool _hasStartedTypingName = false;
  bool get hasStartedTypingName => _hasStartedTypingName;
  
  bool _hasStartedTypingDateOfBirth = false;
  bool get hasStartedTypingDateOfBirth => _hasStartedTypingDateOfBirth;
  
  bool _hasStartedTypingPhone = false;
  bool get hasStartedTypingPhone => _hasStartedTypingPhone;
  
  bool _hasStartedTypingAlternatePhone = false;
  bool get hasStartedTypingAlternatePhone => _hasStartedTypingAlternatePhone;
  
  double _step1Progress = 0.0;
  double get step1Progress => _step1Progress;
  
  // Step 2 - Service Details
  String? _selectedExperience;
  String? get selectedExperience => _selectedExperience;
  
  String? _selectedServiceCategory;
  String? get selectedServiceCategory => _selectedServiceCategory;
  
  List<ServiceCategoryModel> _serviceCategories = [];
  List<ServiceCategoryModel> get serviceCategories => List.unmodifiable(_serviceCategories);
  
  bool _isLoadingCategories = false;
  bool get isLoadingCategories => _isLoadingCategories;
  
  List<SubCategoryModel> _subCategories = [];
  List<SubCategoryModel> get subCategories => List.unmodifiable(_subCategories);
  
  bool _isLoadingSubCategories = false;
  bool get isLoadingSubCategories => _isLoadingSubCategories;
  
  Map<String, bool> _subServices = {};
  Map<String, bool> get subServices => Map.unmodifiable(_subServices);
  
  double _serviceRadius = 10.0;
  double get serviceRadius => _serviceRadius;
  
  bool _useCurrentLocation = false;
  bool get useCurrentLocation => _useCurrentLocation;
  
  double _step2Progress = 0.0;
  double get step2Progress => _step2Progress;
  
  // Step 3 - Verification Documents
  String? _selectedIdType;
  String? get selectedIdType => _selectedIdType;
  
  String? _idDocumentPath;
  String? get idDocumentPath => _idDocumentPath;
  
  File? _selectedIdDocument;
  File? get selectedIdDocument => _selectedIdDocument;
  
  String? _photoPath;
  String? get photoPath => _photoPath;
  
  File? _selectedPhoto;
  File? get selectedPhoto => _selectedPhoto;
  
  double _step3Progress = 0.4;
  double get step3Progress => _step3Progress;
  
  // Step 4 - Availability & Rates
  TimeOfDay? _startTime;
  TimeOfDay? get startTime => _startTime;
  
  TimeOfDay? _endTime;
  TimeOfDay? get endTime => _endTime;
  
  String? _serviceRate;
  String? get serviceRate => _serviceRate;
  
  final Map<String, bool> _availabilityDays = {
    'Mon': false,
    'Tue': false,
    'Wed': false,
    'Thur': false,
    'Fri': false,
    'Sat': false,
    'Sun': false,
  };
  Map<String, bool> get availabilityDays => Map.unmodifiable(_availabilityDays);
  
  double _step4Progress = 0.0;
  double get step4Progress => _step4Progress;
  
  // Step 5 - Confirmation
  bool _confirmInformation = false;
  bool get confirmInformation => _confirmInformation;
  
  double get step5Progress => _confirmInformation ? 1.0 : 0.8;
  // Change Password - Password Visibility States
  bool _obscureOldPassword = true;
  bool get obscureOldPassword => _obscureOldPassword;

  bool _obscureNewPassword = true;
  bool get obscureNewPassword => _obscureNewPassword;

  bool _obscureConfirmPassword = true;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  void toggleObscureOldPassword() {
    _obscureOldPassword = !_obscureOldPassword;
    notifyListeners();
  }

  void toggleObscureNewPassword() {
    _obscureNewPassword = !_obscureNewPassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }


  
  // Step 1 Methods
  void setFullName(String? value) {
    _fullName = value;
    if (value != null && value.isNotEmpty) {
      _hasStartedTypingName = true;
    }
    _updateStep1Progress();
    notifyListeners();
  }
  
  void setHasStartedTypingName(bool value) {
    _hasStartedTypingName = value;
    notifyListeners();
  }
  
  void setSelectedGender(String? value) {
    _selectedGender = value;
    _updateStep1Progress();
    notifyListeners();
  }
  
  void setSelectedDate(DateTime? value) {
    _selectedDate = value;
    if (value != null) {
      _hasStartedTypingDateOfBirth = true;
    }
    _updateStep1Progress();
    notifyListeners();
  }
  
  void setHasStartedTypingDateOfBirth(bool value) {
    _hasStartedTypingDateOfBirth = value;
    notifyListeners();
  }
  
  void setSelectedCity(String? value) {
    _selectedCity = value;
    _updateStep1Progress();
    notifyListeners();
  }
  
  void setMobileNumber(String? value) {
    _mobileNumber = value;
    if (value != null && value.isNotEmpty) {
      _hasStartedTypingPhone = true;
    }
    _updateStep1Progress();
    notifyListeners();
  }
  
  void setHasStartedTypingPhone(bool value) {
    _hasStartedTypingPhone = value;
    notifyListeners();
  }
  
  void setAlternatePhone(String? value) {
    _alternatePhone = value;
    if (value != null && value.isNotEmpty) {
      _hasStartedTypingAlternatePhone = true;
    }
    _updateStep1Progress();
    notifyListeners();
  }
  
  void setHasStartedTypingAlternatePhone(bool value) {
    _hasStartedTypingAlternatePhone = value;
    notifyListeners();
  }
  
  void _updateStep1Progress() {
    int filledFields = 0;
    int totalFields = 6; // Full Name, Gender, Date of Birth, Mobile, Alternate Phone, City
    
    if (_fullName != null && _fullName!.trim().isNotEmpty) {
      filledFields++;
    }
    
    if (_selectedGender != null && _selectedGender!.isNotEmpty) {
      filledFields++;
    }
    
    if (_selectedDate != null) {
      filledFields++;
    }
    
    if (_mobileNumber != null && _mobileNumber!.trim().isNotEmpty) {
      filledFields++;
    }
    
    if (_alternatePhone != null && _alternatePhone!.trim().isNotEmpty) {
      filledFields++;
    }
    
    if (_selectedCity != null && _selectedCity!.isNotEmpty) {
      filledFields++;
    }
    
    _step1Progress = (filledFields / totalFields) * 0.2;
  }
  
  // Step 2 Methods
  void setSelectedExperience(String? value) {
    _selectedExperience = value;
    _updateStep2Progress();
    notifyListeners();
  }
  
  void setSelectedServiceCategory(String? value) {
    _selectedServiceCategory = value;
    _updateStep2Progress();
    
    // Clear previous sub-categories and sub-services when category changes
    _subCategories = [];
    _subServices = {};
    _isLoadingSubCategories = false;
    
    // Notify immediately to clear UI
    notifyListeners();
    
    // Fetch sub-categories if a category is selected
    if (value != null && value.isNotEmpty && _serviceCategories.isNotEmpty) {
      // Find the selected category to get its ID
      try {
        final selectedCategory = _serviceCategories.firstWhere(
          (cat) => cat.name == value,
        );
        _fetchSubCategories(selectedCategory.id, value);
      } catch (e) {
        print("Category not found: $value");
        // Category not found, keep sub-categories empty
        _subCategories = [];
        _subServices = {};
        _isLoadingSubCategories = false;
        notifyListeners();
      }
    }
  }
  
  void setServiceRadius(double value) {
    _serviceRadius = value;
    _updateStep2Progress();
    notifyListeners();
  }
  
  void setUseCurrentLocation(bool value) {
    _useCurrentLocation = value;
    notifyListeners();
  }
  
  void setSubService(String service, bool value) {
    _subServices[service] = value;
    _updateStep2Progress();
    notifyListeners();
  }
  
  void _updateStep2Progress() {
    int filledFields = 0;
    int totalFields = 4;
    
    if (_selectedExperience != null && _selectedExperience!.isNotEmpty) {
      filledFields++;
    }
    
    if (_selectedServiceCategory != null && _selectedServiceCategory!.isNotEmpty) {
      filledFields++;
    }
    
    // Service Radius always has a value (default 10)
    filledFields++;
    
    bool hasSubServiceSelected = _subServices.values.any((isSelected) => isSelected);
    if (hasSubServiceSelected) {
      filledFields++;
    }
    
    _step2Progress = 0.2 + (filledFields / totalFields) * 0.2;
  }
  
  // Step 3 Methods
  void setSelectedIdType(String? value) {
    _selectedIdType = value;
    notifyListeners();
  }
  
  void setIdDocumentPath(String? value) {
    _idDocumentPath = value;
    if (value != null && value.isNotEmpty) {
      _selectedIdDocument = File(value);
    } else {
      _selectedIdDocument = null;
    }
    _updateStep3Progress();
    notifyListeners();
  }
  
  void setPhotoPath(String? value) {
    _photoPath = value;
    if (value != null && value.isNotEmpty) {
      _selectedPhoto = File(value);
    } else {
      _selectedPhoto = null;
    }
    _updateStep3Progress();
    notifyListeners();
  }
  
  void setSelectedIdDocument(File? file) {
    _selectedIdDocument = file;
    _idDocumentPath = file?.path;
    _updateStep3Progress();
    notifyListeners();
  }
  
  void setSelectedPhoto(File? file) {
    _selectedPhoto = file;
    _photoPath = file?.path;
    _updateStep3Progress();
    notifyListeners();
  }
  
  void _updateStep3Progress() {
    int filledFields = 0;
    int totalFields = 2; // ID Document, Photo
    
    if (_idDocumentPath != null && _idDocumentPath!.isNotEmpty) {
      filledFields++;
    }
    
    if (_photoPath != null && _photoPath!.isNotEmpty) {
      filledFields++;
    }
    
    _step3Progress = 0.4 + (filledFields / totalFields) * 0.2;
  }
  
  // Step 4 Methods
  void setStartTime(TimeOfDay? value) {
    _startTime = value;
    _updateStep4Progress();
    notifyListeners();
  }
  
  void setEndTime(TimeOfDay? value) {
    _endTime = value;
    _updateStep4Progress();
    notifyListeners();
  }
  
  void setServiceRate(String? value) {
    _serviceRate = value;
    _updateStep4Progress();
    notifyListeners();
  }
  
  void setAvailabilityDay(String day, bool value) {
    _availabilityDays[day] = value;
    _updateStep4Progress();
    notifyListeners();
  }
  
  void _updateStep4Progress() {
    int filledFields = 0;
    int totalFields = 4; // Start Time, End Time, At least one Availability Day checkbox, Service Rate
    
    if (_startTime != null) {
      filledFields++;
    }
    
    if (_endTime != null) {
      filledFields++;
    }
    
    bool hasAvailabilityDaySelected = _availabilityDays.values.any((isSelected) => isSelected);
    if (hasAvailabilityDaySelected) {
      filledFields++;
    }
    
    if (_serviceRate != null && _serviceRate!.isNotEmpty) {
      filledFields++;
    }
    
    if (filledFields == totalFields) {
      _step4Progress = 0.8;
    } else {
      _step4Progress = 0.6 + (filledFields / totalFields) * 0.2;
    }
  }
  
  // Step 5 Methods
  void setConfirmInformation(bool value) {
    _confirmInformation = value;
    notifyListeners();
  }
  
  // Initialize step 1 with default date
  void initializeStep1() {
    _selectedDate = DateTime(2025, 8, 17);
    _updateStep1Progress();
    notifyListeners();
  }
  
  // Initialize step 2
  void initializeStep2() {
    _updateStep2Progress();
    _fetchServiceCategories();
    notifyListeners();
  }

  // Initialize step 3
  void initializeStep3() {
    _updateStep3Progress();
    notifyListeners();
  }

  // Initialize step 4
  void initializeStep4() {
    _updateStep4Progress();
    notifyListeners();
  }
  
  // Fetch service categories from API
  Future<void> _fetchServiceCategories() async {
    try {
      _isLoadingCategories = true;
      notifyListeners();
      
      final categories = await _categoryService.getMainCategories();
      _serviceCategories = categories.where((category) => category.isActive).toList();
      
      _isLoadingCategories = false;
      notifyListeners();
    } catch (e) {
      _isLoadingCategories = false;
      notifyListeners();
      print("Failed to fetch service categories: $e");
      // Keep empty list on error, UI will handle it
      _serviceCategories = [];
    }
  }
  
  // Fetch sub-categories by main category ID
  Future<void> _fetchSubCategories(String mainCategoryId, String selectedCategoryName) async {
    try {
      _isLoadingSubCategories = true;
      notifyListeners();
      
      final subCategories = await _categoryService.getSubCategoriesByMainCategory(mainCategoryId);
      
      // Only update if the selected category is still the same (prevent race condition)
      if (_selectedServiceCategory == selectedCategoryName) {
        // Filter sub-categories to only include those that match the main category
        _subCategories = subCategories
            .where((subCat) => subCat.isActive && subCat.mainCategory == mainCategoryId)
            .toList();
        
        // Initialize sub-services map with sub-categories
        _subServices = {};
        for (var subCat in _subCategories) {
          _subServices[subCat.name] = false;
        }
      }
      
      _isLoadingSubCategories = false;
      _updateStep2Progress();
      notifyListeners();
    } catch (e) {
      // Only update if the selected category is still the same (prevent race condition)
      if (_selectedServiceCategory == selectedCategoryName) {
        _isLoadingSubCategories = false;
        _subCategories = [];
        _subServices = {};
        notifyListeners();
      }
      print("Failed to fetch sub-categories: $e");
    }
  }
  
  Future<bool> updateBusinessProfileWithFiles(
    BusinessProfileModel model, {
    String? name,
    String? phone,
    File? idProofFile,
    File? recentPhoto,
    File? logoFile,
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Extract profile ID from auth response if available
      String? profileId;
      if (context != null) {
        try {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final authResponse = authProvider.response;
          if (authResponse != null) {
            final user = authResponse['user'] as Map<String, dynamic>?;
            if (user != null) {
              final businessProfile = user['business_owner_profile'] as Map<String, dynamic>?;
              if (businessProfile != null && businessProfile['id'] != null) {
                profileId = businessProfile['id'].toString();
              }
            }
          }
        } catch (e) {
          print("Error extracting profile ID: $e");
        }
      }

      final data = await _service.updateBusinessProfileWithFiles(
        model,
        name: name,
        phone: phone,
        idProofFile: idProofFile,
        recentPhoto: recentPhoto,
        logoFile: logoFile,
        profileId: profileId,
      );

      _response = data;
      _isLoading = false;
      notifyListeners();

      return true;
    }  catch (e) {
      _isLoading = false;
      notifyListeners();

      print("Business Profile Update Error → $e");
      return false;
    }
  }

  // Analyze ID Card File
  Future<bool> analyzeIdCardFile(File idCardFile) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _service.analyzeIdCardFile(idCardFile);

      _idCardAnalysisResult = data;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      _idCardAnalysisResult = null;
      print("Analyze ID Card Error → $e");
      return false;
    }
  }

  // Clear ID Card Analysis Result
  void clearIdCardAnalysisResult() {
    _idCardAnalysisResult = null;
    notifyListeners();
  }

  // change password provider
  Future<bool> changePassword(ChangePasswordModel model) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _service.changePassword(model);

      _response = data;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Change Password Error → $e");
      return false;
    }
  }

  // Update Profile (for edit profile page)
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? serviceCategory,
    String? city,
    File? recentPhoto,
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _service.updateProfile(
        name: name,
        email: email,
        phone: phone,
        serviceCategory: serviceCategory,
        city: city,
        recentPhoto: recentPhoto,
      );

      _response = data;
      
      // Update local state if update was successful
      if (name != null && name.isNotEmpty) {
        _fullName = name;
      }
      if (phone != null && phone.isNotEmpty) {
        _mobileNumber = phone;
      }
      if (serviceCategory != null && serviceCategory.isNotEmpty) {
        _selectedServiceCategory = serviceCategory;
      }
      if (city != null && city.isNotEmpty) {
        _selectedCity = city;
      }
      
      // Update AuthProvider response to reflect changes immediately
      if (context != null) {
        try {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final authResponse = authProvider.response;
          
          if (authResponse != null) {
            // Create updated response structure
            Map<String, dynamic> updatedResponse = Map<String, dynamic>.from(authResponse);
            
            // Update user data if present
            if (updatedResponse['user'] != null) {
              Map<String, dynamic> user = Map<String, dynamic>.from(updatedResponse['user'] as Map<String, dynamic>);
              
              // Update user name and email
              if (name != null && name.isNotEmpty) {
                user['name'] = name;
              }
              if (email != null && email.isNotEmpty) {
                user['email'] = email;
              }
              
              // Update business_owner_profile if present
              if (user['business_owner_profile'] != null) {
                Map<String, dynamic> profile = Map<String, dynamic>.from(user['business_owner_profile'] as Map<String, dynamic>);
                
                // Update profile fields
                if (name != null && name.isNotEmpty) {
                  profile['name'] = name;
                }
                if (phone != null && phone.isNotEmpty) {
                  profile['phone'] = phone;
                  // Also update user phone if it exists
                  if (user['phone'] != null) {
                    user['phone'] = phone;
                  }
                }
                if (serviceCategory != null && serviceCategory.isNotEmpty) {
                  profile['primary_service_category'] = serviceCategory;
                }
                if (city != null && city.isNotEmpty) {
                  profile['city'] = city;
                }
                
                // Update image URL if API returned it
                // Check multiple possible response structures
                String? imageUrl;
                
                // Check if image is in data['user']['business_owner_profile']['recent_photo']
                if (data['user'] != null) {
                  final responseUser = data['user'] as Map<String, dynamic>?;
                  if (responseUser != null && responseUser['business_owner_profile'] != null) {
                    final responseProfile = responseUser['business_owner_profile'] as Map<String, dynamic>?;
                    if (responseProfile != null) {
                      if (responseProfile['recent_photo'] != null) {
                        imageUrl = responseProfile['recent_photo']?.toString();
                      }
                      // Also update phone from API response if present
                      if (responseProfile['phone'] != null) {
                        profile['phone'] = responseProfile['phone'];
                        if (user['phone'] != null) {
                          user['phone'] = responseProfile['phone'];
                        }
                      }
                    }
                  }
                  // Also update user phone if directly in response user
                  if (responseUser != null && responseUser['phone'] != null) {
                    user['phone'] = responseUser['phone'];
                    profile['phone'] = responseUser['phone'];
                  }
                }
                
                // Also check if image is directly in data['business_owner_profile']['recent_photo']
                if (imageUrl == null && data['business_owner_profile'] != null) {
                  final responseProfile = data['business_owner_profile'] as Map<String, dynamic>?;
                  if (responseProfile != null) {
                    if (responseProfile['recent_photo'] != null) {
                      imageUrl = responseProfile['recent_photo']?.toString();
                    }
                    if (responseProfile['phone'] != null) {
                      profile['phone'] = responseProfile['phone'];
                      if (user['phone'] != null) {
                        user['phone'] = responseProfile['phone'];
                      }
                    }
                  }
                }
                
                // Also check if image is directly in data['recent_photo']
                if (imageUrl == null && data['recent_photo'] != null) {
                  imageUrl = data['recent_photo']?.toString();
                }
                
                // Update profile with image URL if found
                if (imageUrl != null && imageUrl.isNotEmpty) {
                  profile['recent_photo'] = imageUrl;
                }
                
                user['business_owner_profile'] = profile;
              } else if (data['user'] != null && data['user']['business_owner_profile'] != null) {
                // If profile doesn't exist in auth response, add it from API response
                user['business_owner_profile'] = data['user']['business_owner_profile'];
              }
              
              updatedResponse['user'] = user;
            } else if (data['user'] != null) {
              // If user doesn't exist in auth response, add it from API response
              updatedResponse['user'] = data['user'];
            }
            
            // Update AuthProvider with merged response
            authProvider.updateResponse(updatedResponse);
          } else if (data['user'] != null) {
            // If no auth response exists, use the API response directly
            authProvider.updateResponse(data);
          }
        } catch (e) {
          print("Error updating AuthProvider response: $e");
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    }  catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Update Profile Error → $e");
      return false;
    }
  }

  // Fetch Business Owner Profile
  Future<void> fetchBusinessOwnerProfile() async {
    try {
      _isLoadingProfile = true;
      _errorMessage = null;
      notifyListeners();

      final data = await _service.getBusinessOwnerProfile();

      _response = data;
      _isLoadingProfile = false;
      notifyListeners();
    } catch (e) {
      _isLoadingProfile = false;
      _errorMessage = 'Failed to fetch profile: ${e.toString()}';
      notifyListeners();
    }
  }

  // Refresh profile
  Future<void> refreshProfile() async {
    await fetchBusinessOwnerProfile();
  }
}


