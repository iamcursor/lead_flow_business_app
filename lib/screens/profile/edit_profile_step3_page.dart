import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/business_owner_provider.dart';
import '../../models/business_owner_profile/business_profile.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import 'edit_profile_step4_page.dart';

/// Edit Profile Page - Step 3
class EditProfileStep3Page extends StatefulWidget {
  const EditProfileStep3Page({super.key});

  @override
  State<EditProfileStep3Page> createState() => _EditProfileStep3PageState();
}

class _EditProfileStep3PageState extends State<EditProfileStep3Page> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  
  final List<String> _idTypes = ['ID Card', 'Passport', 'Driving License'];
  
  // ValueNotifiers to track if we should show network images
  final ValueNotifier<String?> _idProofUrlNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _recentPhotoUrlNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    // Initialize provider after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
      provider.initializeStep3();
      _loadProfileData(provider);
    });
  }

  @override
  void dispose() {
    _idProofUrlNotifier.dispose();
    _recentPhotoUrlNotifier.dispose();
    super.dispose();
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
    
    // Get ID proof type from API response
    final idProofType = businessProfile?['id_proof_type']?.toString();
    if (idProofType != null && idProofType.isNotEmpty) {
      // Convert from API format (id_card, driving_license, passport) to display format
      String displayIdType = idProofType
          .split('_')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
      
      // Handle special cases
      if (displayIdType.toLowerCase() == 'id card') {
        displayIdType = 'ID Card';
      } else if (displayIdType.toLowerCase() == 'driving license') {
        displayIdType = 'Driving License';
      } else if (displayIdType.toLowerCase() == 'passport') {
        displayIdType = 'Passport';
      }
      
      if (_idTypes.contains(displayIdType)) {
        provider.setSelectedIdType(displayIdType);
      }
    }
    
    // Get ID proof file URL from API response
    final idProofFileUrl = businessProfile?['id_proof_file']?.toString();
    if (idProofFileUrl != null && idProofFileUrl.isNotEmpty) {
      _idProofUrlNotifier.value = idProofFileUrl;
    }
    
    // Get recent photo URL from API response
    final recentPhotoUrl = businessProfile?['recent_photo']?.toString();
    if (recentPhotoUrl != null && recentPhotoUrl.isNotEmpty) {
      _recentPhotoUrlNotifier.value = recentPhotoUrl;
    }
  }

  void _handleIdTypeSelection(String idType) {
    final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
    provider.setSelectedIdType(idType);
    // Clear previous analysis result when ID type changes
    provider.clearIdCardAnalysisResult();
  }

  Future<void> _handleIdDocumentUpload() async {
    final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
    
    // Check if ID type is selected first
    if (provider.selectedIdType == null || provider.selectedIdType!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select id type'),
          ),
        );
      }
      return;
    }
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();
        const maxSize = 5 * 1024 * 1024; // 5MB

        if (fileSize > maxSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size must be less than 5MB'),
              ),
            );
          }
          return;
        }

        final fileName = file.path.toLowerCase();
        final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
        final hasValidExtension = validExtensions.any((ext) => fileName.endsWith(ext));
        
        if (!hasValidExtension) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select an image file (JPG, PNG, GIF, or WEBP)'),
              ),
            );
          }
          return;
        }

        provider.setSelectedIdDocument(file);
        // Clear network image URL when new file is selected
        _idProofUrlNotifier.value = null;

        // If ID type is "ID Card", analyze the file
        if (provider.selectedIdType == 'ID Card') {
          final success = await provider.analyzeIdCardFile(file);
          
          if (mounted) {
            if (success && provider.idCardAnalysisResult != null) {
              _showIdCardVerificationDialog(provider.idCardAnalysisResult!);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to analyze ID card. Please try again.'),
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ID document selected successfully'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: ${e.toString()}'),
          ),
        );
      }
    }
  }

  List<String> _validateIdCardAnalysis(Map<String, dynamic> analysisResult) {
    final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
    final details = analysisResult['details'] as Map<String, dynamic>?;
    final List<String> errors = [];
    
    if (details == null || details['extracted_cnic_details'] == null) {
      errors.add('ID card information could not be extracted. Please ensure the ID card image is clear and try again.');
      return errors;
    }
    
    final extractedDetails = details['extracted_cnic_details'] as Map<String, dynamic>;
    
    final extractedName = extractedDetails['name']?.toString()?.trim();
    final extractedDob = extractedDetails['date_of_birth']?.toString()?.trim();
    final extractedGender = extractedDetails['gender']?.toString()?.trim();
    
    if (extractedName == null || extractedName.isEmpty) {
      errors.add('Name is missing from ID card');
    }
    if (extractedDob == null || extractedDob.isEmpty) {
      errors.add('Date of birth is missing from ID card');
    }
    if (extractedGender == null || extractedGender.isEmpty) {
      errors.add('Gender is missing from ID card');
    }
    
    if (errors.isNotEmpty) {
      return errors;
    }
    
    final userName = provider.fullName?.trim() ?? '';
    final userDob = provider.selectedDate;
    final userGender = provider.selectedGender?.trim() ?? '';
    
    String normalizeName(String name) {
      return name.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    
    String normalizeGender(String gender) {
      return gender.toLowerCase().trim();
    }
    
    DateTime? parseExtractedDob(String? dobString) {
      if (dobString == null || dobString.isEmpty) return null;
      try {
        final parts = dobString.replaceAll('/', '-').split('-');
        if (parts.length == 3) {
          List<int?> yearMonthDay = [];
          for (var part in parts) {
            yearMonthDay.add(int.tryParse(part.trim()));
          }
          
          if (yearMonthDay[0] != null && yearMonthDay[1] != null && yearMonthDay[2] != null) {
            if (yearMonthDay[0]! > 1900 && yearMonthDay[0]! < 2100) {
              return DateTime(yearMonthDay[0]!, yearMonthDay[1]!, yearMonthDay[2]!);
            }
            if (yearMonthDay[2]! > 1900 && yearMonthDay[2]! < 2100) {
              return DateTime(yearMonthDay[2]!, yearMonthDay[1]!, yearMonthDay[0]!);
            }
            if (yearMonthDay[2]! > 1900 && yearMonthDay[2]! < 2100) {
              return DateTime(yearMonthDay[2]!, yearMonthDay[0]!, yearMonthDay[1]!);
            }
          }
        }
        return DateTime.parse(dobString);
      } catch (_) {
        return null;
      }
    }
    
    if (userName.isNotEmpty && extractedName != null && extractedName.isNotEmpty) {
      if (normalizeName(userName) != normalizeName(extractedName)) {
        errors.add('Name does not match');
      }
    }
    
    if (userDob != null && extractedDob != null && extractedDob.isNotEmpty) {
      final extractedDobDate = parseExtractedDob(extractedDob);
      if (extractedDobDate != null) {
        if (userDob.year != extractedDobDate.year ||
            userDob.month != extractedDobDate.month ||
            userDob.day != extractedDobDate.day) {
          errors.add('Date of birth does not match');
        }
      }
    }
    
    if (userGender.isNotEmpty && extractedGender != null && extractedGender.isNotEmpty) {
      final normalizedUserGender = normalizeGender(userGender);
      final normalizedExtractedGender = normalizeGender(extractedGender);
      
      final genderMap = {
        'male': ['male', 'm', 'man', 'masculine'],
        'female': ['female', 'f', 'woman', 'feminine'],
      };
      
      bool gendersMatch = false;
      for (var key in genderMap.keys) {
        if (genderMap[key]!.contains(normalizedUserGender) && 
            genderMap[key]!.contains(normalizedExtractedGender)) {
          gendersMatch = true;
          break;
        }
      }
      
      if (!gendersMatch && normalizedUserGender != normalizedExtractedGender) {
        errors.add('Gender does not match');
      }
    }
    
    return errors;
  }

  void _showIdCardVerificationDialog(Map<String, dynamic> analysisResult) {
    final verified = analysisResult['verified'] as bool? ?? false;
    final message = analysisResult['message'] as String? ?? '';
    final details = analysisResult['details'] as Map<String, dynamic>?;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
          ),
          title: Row(
            children: [
              Icon(
                verified ? Icons.check_circle : Icons.error,
                color: verified ? AppColors.success : AppColors.error,
                size: 24.w,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  verified ? 'Verification Successful' : 'Verification Failed',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (details != null) ...[
                  SizedBox(height: AppDimensions.verticalSpaceM),
                  Text(
                    'Extracted Details:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AppDimensions.verticalSpaceS),
                  if (details['extracted_cnic_details'] != null) ...[
                    _buildDetailRow('Name', details['extracted_cnic_details']['name']?.toString() ?? 'N/A'),
                    _buildDetailRow('CNIC', details['extracted_cnic_details']['cnic_number']?.toString() ?? 'N/A'),
                    _buildDetailRow('Date of Birth', details['extracted_cnic_details']['date_of_birth']?.toString() ?? 'N/A'),
                    _buildDetailRow('Gender', details['extracted_cnic_details']['gender']?.toString() ?? 'N/A'),
                  ],
                  if (details['match_details'] != null) ...[
                    SizedBox(height: AppDimensions.verticalSpaceM),
                    Text(
                      'Match Status:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.verticalSpaceS),
                    _buildMatchRow('Name', details['match_details']['name_match'] as bool? ?? false),
                    _buildMatchRow('Date of Birth', details['match_details']['dob_match'] as bool? ?? false),
                    _buildMatchRow('Gender', details['match_details']['gender_match'] as bool? ?? false),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.verticalSpaceXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchRow(String label, bool matched) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.verticalSpaceXS),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Icon(
            matched ? Icons.check_circle : Icons.cancel,
            color: matched ? AppColors.success : AppColors.error,
            size: 16.w,
          ),
          SizedBox(width: 4.w),
          Text(
            matched ? 'Matched' : 'Not Matched',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: matched ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePhotoUpload() async {
    // Show dialog to choose between camera and gallery
    if (!mounted) return;
    
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.dialogRadius),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(AppDimensions.paddingM),
                child: Text(
                  'Select Photo Source',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  'Take Photo',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              SizedBox(height: AppDimensions.verticalSpaceS),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      // Use very aggressive compression for camera images to reduce file size and prevent errors
      final int imageQuality = source == ImageSource.camera ? 50 : 85;
      final double maxWidth = source == ImageSource.camera ? 800.0 : 1920.0;
      final double maxHeight = source == ImageSource.camera ? 800.0 : 1920.0;
      
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (image != null) {
        File file = File(image.path);
        
        // Check if file exists (important for camera images)
        if (!await file.exists()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image file not found. Please try again.'),
              ),
            );
          }
          return;
        }
        
        // Wait a bit for camera images to be fully written
        if (source == ImageSource.camera) {
          await Future.delayed(const Duration(milliseconds: 300));
          if (!await file.exists()) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image file not ready. Please try again.'),
                ),
              );
            }
            return;
          }
          
          // For camera images, create a new file with a shorter name to avoid database errors
          final originalPath = file.path;
          final extension = originalPath.split('.').last.toLowerCase();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final newFileName = 'photo_$timestamp.$extension';
          final directory = originalPath.substring(0, originalPath.lastIndexOf('/'));
          final newPath = '$directory/$newFileName';
          
          // Copy to new file with shorter name
          final newFile = await file.copy(newPath);
          
          // Delete original file if it's different
          if (originalPath != newPath && await file.exists()) {
            try {
              await file.delete();
            } catch (e) {
              // Ignore deletion errors
            }
          }
          
          file = newFile;
        }
        
        final fileSize = await file.length();
        const maxSize = 5 * 1024 * 1024; // 5MB

        if (fileSize > maxSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image size must be less than 5MB'),
              ),
            );
          }
          return;
        }

        final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
        provider.setSelectedPhoto(file);
        // Clear network image URL when new file is selected
        _recentPhotoUrlNotifier.value = null;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo selected successfully'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
          ),
        );
      }
    }
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

  Future<void> _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
      
      // Validate step3 required fields
      if (provider.selectedIdType == null || provider.selectedIdType!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload documents'),
          ),
        );
        return;
      }
      
      // Check if either new file is selected or existing URL exists
      final hasIdDocument = provider.selectedIdDocument != null || 
                           (_idProofUrlNotifier.value != null && _idProofUrlNotifier.value!.isNotEmpty);
      
      if (!hasIdDocument) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload an ID document'),
          ),
        );
        return;
      }
      
      // Check if either new photo is selected or existing URL exists
      final hasPhoto = provider.selectedPhoto != null || 
                      (_recentPhotoUrlNotifier.value != null && _recentPhotoUrlNotifier.value!.isNotEmpty);
      
      if (!hasPhoto) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload a recent photo'),
          ),
        );
        return;
      }
      
      // If ID type is "ID Card" and new file is uploaded, validate that analysis matches user input
      if (provider.selectedIdType == 'ID Card' && 
          provider.selectedIdDocument != null && 
          provider.idCardAnalysisResult != null) {
        final validationErrors = _validateIdCardAnalysis(provider.idCardAnalysisResult!);
        if (validationErrors.isNotEmpty) {
          String errorMessage = 'Please correct information according to ID card:\n';
          errorMessage += validationErrors.map((error) => '• $error').join('\n');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'OK',
                textColor: AppColors.textOnPrimary,
                onPressed: () {},
              ),
            ),
          );
          return;
        }
      }

      if (provider.isLoading) return;

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

        // Prepare file objects - use new files if selected, otherwise null (will keep existing)
        File? idProofFile = provider.selectedIdDocument;
        File? recentPhoto = provider.selectedPhoto;
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
          businessHours: existingProfileData?['business_hours']?.toString() ?? '',
          maxLeadDistanceMiles: (provider.serviceRadius / 1.60934).round(),
          autoRespondEnabled: existingProfileData?['auto_respond_enabled'] ?? false,
          autoRespondMessage: existingProfileData?['auto_respond_message']?.toString() ?? '',
          subscriptionTier: existingProfileData?['subscription_tier']?.toString() ?? 'basic',
          availabilityStatus: existingProfileData?['availability_status']?.toString() ?? '',
          logo: existingProfileData?['logo']?.toString() ?? '',
          gallery: existingProfileData?['gallery']?.toString() ?? '',
          idProofType: _formatIdProofType(provider.selectedIdType),
          idProofFile: existingProfileData?['id_proof_file']?.toString() ?? '',
          recentPhoto: existingProfileData?['recent_photo']?.toString() ?? '',
          baseServiceRate: existingProfileData?['base_service_rate']?.toString() ?? '',
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
            // Navigate to Edit Profile Step 4
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileStep4Page()),
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
                            
                            SizedBox(height: AppDimensions.verticalSpaceL),
                            
                            // Verification Documents Container
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
                                      'Verification Documents',
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    
                                    SizedBox(height: AppDimensions.verticalSpaceS),
                                    
                                    Text(
                                      'Upload Government ID Proof (Any one)',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    
                                    SizedBox(height: AppDimensions.verticalSpaceM),
                                    
                                    // ID Type Buttons
                                    Row(
                                      children: _idTypes.map((String idType) {
                                        final isSelected = provider.selectedIdType == idType;
                                        return Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              right: idType != _idTypes.last 
                                                  ? AppDimensions.paddingS 
                                                  : 0,
                                            ),
                                            child: OutlinedButton(
                                              onPressed: () => _handleIdTypeSelection(idType),
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: isSelected 
                                                    ? Theme.of(context).colorScheme.primary 
                                                    : Theme.of(context).colorScheme.surfaceVariant,
                                                foregroundColor: isSelected 
                                                    ? Theme.of(context).colorScheme.onPrimary 
                                                    : Theme.of(context).colorScheme.onSurface,
                                                side: BorderSide(
                                                  color: isSelected 
                                                      ? Theme.of(context).colorScheme.primary 
                                                      : Theme.of(context).colorScheme.outline,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                    AppDimensions.inputRadius,
                                                  ),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: AppDimensions.paddingM,
                                                ),
                                              ),
                                              child: Text(
                                                idType,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    
                                    SizedBox(height: AppDimensions.verticalSpaceL),
                                    
                                    // Upload Area for ID Document
                                    ValueListenableBuilder<String?>(
                                      valueListenable: _idProofUrlNotifier,
                                      builder: (context, idProofUrl, child) {
                                        final hasFile = provider.selectedIdDocument != null;
                                        final hasUrl = idProofUrl != null && idProofUrl.isNotEmpty;
                                        
                                        return InkWell(
                                          onTap: _handleIdDocumentUpload,
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                              vertical: AppDimensions.verticalSpaceXL,
                                              horizontal: AppDimensions.paddingM,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.surface,
                                              borderRadius: BorderRadius.circular(
                                                AppDimensions.inputRadius,
                                              ),
                                              border: Border.all(
                                                color: (hasFile || hasUrl)
                                                    ? Theme.of(context).colorScheme.primary 
                                                    : Theme.of(context).colorScheme.outline,
                                                width: 1.5,
                                                style: BorderStyle.solid,
                                              ),
                                            ),
                                            child: hasFile
                                                ? Row(
                                                    children: [
                                                      Icon(
                                                        Icons.check_circle,
                                                        color: Theme.of(context).colorScheme.primary,
                                                        size: 24.w,
                                                      ),
                                                      SizedBox(width: AppDimensions.paddingM),
                                                      Expanded(
                                                        child: Text(
                                                          provider.selectedIdDocument!.path.split('/').last,
                                                          style: TextStyle(
                                                            fontSize: 14.sp,
                                                            fontWeight: FontWeight.w500,
                                                            color: Theme.of(context).colorScheme.onSurface,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.close,
                                                          size: 20.w,
                                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                        ),
                                                        onPressed: () {
                                                          provider.setSelectedIdDocument(null);
                                                        },
                                                      ),
                                                    ],
                                                  )
                                                : hasUrl
                                                    ? Row(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius: BorderRadius.circular(8.r),
                                                            child: Image.network(
                                                              idProofUrl,
                                                              width: 60.w,
                                                              height: 60.w,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context, error, stackTrace) {
                                                                return Icon(
                                                                  Icons.description_outlined,
                                                                  size: 48.w,
                                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                                );
                                                              },
                                                              loadingBuilder: (context, child, loadingProgress) {
                                                                if (loadingProgress == null) return child;
                                                                return SizedBox(
                                                                  width: 60.w,
                                                                  height: 60.w,
                                                                  child: Center(
                                                                    child: CircularProgressIndicator(
                                                                      value: loadingProgress.expectedTotalBytes != null
                                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                                              loadingProgress.expectedTotalBytes!
                                                                          : null,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          SizedBox(width: AppDimensions.paddingM),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  'ID Document',
                                                                  style: TextStyle(
                                                                    fontSize: 14.sp,
                                                                    fontWeight: FontWeight.w500,
                                                                    color: Theme.of(context).colorScheme.onSurface,
                                                                  ),
                                                                ),
                                                                SizedBox(height: 4.h),
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons.check_circle,
                                                                      color: Theme.of(context).colorScheme.primary,
                                                                      size: 16.w,
                                                                    ),
                                                                    SizedBox(width: 4.w),
                                                                    Text(
                                                                      'Uploaded',
                                                                      style: TextStyle(
                                                                        fontSize: 12.sp,
                                                                        color: Theme.of(context).colorScheme.primary,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.close,
                                                              size: 20.w,
                                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                            ),
                                                            onPressed: () {
                                                              _idProofUrlNotifier.value = null;
                                                            },
                                                          ),
                                                        ],
                                                      )
                                                    : Column(
                                                        children: [
                                                          Icon(
                                                            Icons.description_outlined,
                                                            size: 48.w,
                                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                          ),
                                                          SizedBox(height: AppDimensions.verticalSpaceM),
                                                          Text(
                                                            'Click to upload or drag and drop',
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              fontWeight: FontWeight.w400,
                                                              color: Theme.of(context).colorScheme.onSurface,
                                                            ),
                                                          ),
                                                          SizedBox(height: AppDimensions.verticalSpaceS),
                                                          Text(
                                                            'PNG, JPG, PDF up to 5MB',
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              fontWeight: FontWeight.w400,
                                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            SizedBox(height: AppDimensions.verticalSpaceL),
                            
                            // Upload Recent Photo Container
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
                                      'Upload Recent Photo (Selfie or Passport style)',
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    
                                    SizedBox(height: AppDimensions.verticalSpaceL),
                                    
                                    // Upload Area for Photo
                                    ValueListenableBuilder<String?>(
                                      valueListenable: _recentPhotoUrlNotifier,
                                      builder: (context, photoUrl, child) {
                                        final hasFile = provider.selectedPhoto != null;
                                        final hasUrl = photoUrl != null && photoUrl.isNotEmpty;
                                        
                                        return InkWell(
                                          onTap: _handlePhotoUpload,
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                              vertical: AppDimensions.verticalSpaceXL,
                                              horizontal: AppDimensions.paddingM,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.surface,
                                              borderRadius: BorderRadius.circular(
                                                AppDimensions.inputRadius,
                                              ),
                                              border: Border.all(
                                                color: (hasFile || hasUrl)
                                                    ? Theme.of(context).colorScheme.primary 
                                                    : Theme.of(context).colorScheme.outline,
                                                width: 1.5,
                                                style: BorderStyle.solid,
                                              ),
                                            ),
                                            child: hasFile
                                                ? Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.circular(8.r),
                                                        child: Image.file(
                                                          provider.selectedPhoto!,
                                                          width: 60.w,
                                                          height: 60.w,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      SizedBox(width: AppDimensions.paddingM),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              provider.selectedPhoto!.path.split('/').last,
                                                              style: TextStyle(
                                                                fontSize: 14.sp,
                                                                fontWeight: FontWeight.w500,
                                                                color: Theme.of(context).colorScheme.onSurface,
                                                              ),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            SizedBox(height: 4.h),
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.check_circle,
                                                                  color: Theme.of(context).colorScheme.primary,
                                                                  size: 16.w,
                                                                ),
                                                                SizedBox(width: 4.w),
                                                                Text(
                                                                  'Photo selected',
                                                                  style: TextStyle(
                                                                    fontSize: 12.sp,
                                                                    color: Theme.of(context).colorScheme.primary,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.close,
                                                          size: 20.w,
                                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                        ),
                                                        onPressed: () {
                                                          provider.setSelectedPhoto(null);
                                                        },
                                                      ),
                                                    ],
                                                  )
                                                : hasUrl
                                                    ? Row(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius: BorderRadius.circular(8.r),
                                                            child: Image.network(
                                                              photoUrl,
                                                              width: 60.w,
                                                              height: 60.w,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context, error, stackTrace) {
                                                                return Icon(
                                                                  Icons.camera_alt_outlined,
                                                                  size: 48.w,
                                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                                );
                                                              },
                                                              loadingBuilder: (context, child, loadingProgress) {
                                                                if (loadingProgress == null) return child;
                                                                return SizedBox(
                                                                  width: 60.w,
                                                                  height: 60.w,
                                                                  child: Center(
                                                                    child: CircularProgressIndicator(
                                                                      value: loadingProgress.expectedTotalBytes != null
                                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                                              loadingProgress.expectedTotalBytes!
                                                                          : null,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          SizedBox(width: AppDimensions.paddingM),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  'Recent Photo',
                                                                  style: TextStyle(
                                                                    fontSize: 14.sp,
                                                                    fontWeight: FontWeight.w500,
                                                                    color: Theme.of(context).colorScheme.onSurface,
                                                                  ),
                                                                ),
                                                                SizedBox(height: 4.h),
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons.check_circle,
                                                                      color: Theme.of(context).colorScheme.primary,
                                                                      size: 16.w,
                                                                    ),
                                                                    SizedBox(width: 4.w),
                                                                    Text(
                                                                      'Uploaded',
                                                                      style: TextStyle(
                                                                        fontSize: 12.sp,
                                                                        color: Theme.of(context).colorScheme.primary,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.close,
                                                              size: 20.w,
                                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                            ),
                                                            onPressed: () {
                                                              _recentPhotoUrlNotifier.value = null;
                                                            },
                                                          ),
                                                        ],
                                                      )
                                                    : Column(
                                                        children: [
                                                          Icon(
                                                            Icons.camera_alt_outlined,
                                                            size: 48.w,
                                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                          ),
                                                          SizedBox(height: AppDimensions.verticalSpaceM),
                                                          Text(
                                                            'Click to upload or drag and drop',
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              fontWeight: FontWeight.w400,
                                                              color: Theme.of(context).colorScheme.onSurface,
                                                            ),
                                                          ),
                                                          SizedBox(height: AppDimensions.verticalSpaceS),
                                                          Text(
                                                            'PNG, JPG, PDF up to 5MB',
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              fontWeight: FontWeight.w400,
                                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                          ),
                                        );
                                      },
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

