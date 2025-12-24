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
import 'complete_profile_step4_page.dart';

/// Complete Profile Page - Step 3 of 5
class CompleteProfileStep3Page extends StatefulWidget {
  const CompleteProfileStep3Page({super.key});

  @override
  State<CompleteProfileStep3Page> createState() => _CompleteProfileStep3PageState();
}

class _CompleteProfileStep3PageState extends State<CompleteProfileStep3Page> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  
  final List<String> _idTypes = ['ID Card', 'Passport', 'Driving License'];

  @override
  void initState() {
    super.initState();
    // Initialize provider after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
      provider.initializeStep3();
    });
  }

  void _handleIdTypeSelection(String idType) {
    final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
    provider.setSelectedIdType(idType);
    // Clear previous analysis result when ID type changes
    provider.clearIdCardAnalysisResult();
  }

  Future<void> _handleIdDocumentUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'], // Only image files for analyze API
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

        // Validate file extension for analyze API (only images allowed)
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

        final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
        provider.setSelectedIdDocument(file);

        // If ID type is "ID Card", analyze the file
        if (provider.selectedIdType == 'ID Card') {
          // Show loading
          final success = await provider.analyzeIdCardFile(file);
          
          if (mounted) {
            if (success && provider.idCardAnalysisResult != null) {
              // Show verification results dialog
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
                    color: AppColors.textPrimary,
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
                    color: AppColors.textSecondary,
                  ),
                ),
                if (details != null) ...[
                  SizedBox(height: AppDimensions.verticalSpaceM),
                  Text(
                    'Extracted Details:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
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
                  color: AppColors.primary,
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
                color: AppColors.textSecondary,
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
                color: AppColors.textPrimary,
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
                color: AppColors.textSecondary,
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
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        final file = File(image.path);
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

  Future<void> _handleNext() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
      
      // Validate step3 required fields
      if (provider.selectedIdType == null || provider.selectedIdType!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an ID type'),
          ),
        );
        return;
      }
      
      if (provider.idDocumentPath == null || provider.idDocumentPath!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload an ID document'),
          ),
        );
        return;
      }
      
      if (provider.photoPath == null || provider.photoPath!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload a recent photo'),
          ),
        );
        return;
      }

      if (provider.isLoading) return;

      try {
        // Prepare file objects from provider
        File? idProofFile = provider.selectedIdDocument;
        File? recentPhoto = provider.selectedPhoto;
        File? logoFile; // Logo is empty for now

        // Create BusinessProfileModel with step 3 data and previous steps data
        final businessProfile = BusinessProfileModel(
          gender: _formatGender(provider.selectedGender),
          dateOfBirth: _formatDateOfBirth(provider.selectedDate),
          alternatePhone: provider.alternatePhone ?? '',
          businessName: '',
          tagline: '',
          description: '',
          yearsOfExperience: 0, // Will be set in step 2/5
          primaryServiceCategory: provider.selectedServiceCategory ?? '',
          serviceCategories: '', // Will be set in step 2/5
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
          idProofType: _formatIdProofType(provider.selectedIdType),
          idProofFile: '', // Will be replaced by actual file in multipart
          recentPhoto: '', // Will be replaced by actual file in multipart
          baseServiceRate: '', // Will be set in step 4/5
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
            // Navigate to Step 4
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CompleteProfileStep4Page(),));
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
        return Scaffold(
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
                                  'Step 3 of 5',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    fontSize: 13.sp,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${(provider.step3Progress * 100).toInt()}%',
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
                                value: provider.step3Progress,
                                backgroundColor: AppColors.borderLight,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                                minHeight: 6.h,
                              ),
                            ),
                        
                        SizedBox(height: AppDimensions.verticalSpaceL),
                        
                        // Verification Documents Container
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
                                  'Verification Documents',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                
                                SizedBox(height: AppDimensions.verticalSpaceS),
                                
                                Text(
                                  'Upload Government ID Proof (Any one)',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
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
                                                ? AppColors.primary 
                                                : AppColors.surfaceVariant,
                                            foregroundColor: isSelected 
                                                ? AppColors.textOnPrimary 
                                                : AppColors.textPrimary,
                                            side: BorderSide(
                                              color: isSelected 
                                                  ? AppColors.primary 
                                                  : AppColors.border,
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
                                InkWell(
                                  onTap: _handleIdDocumentUpload,
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      vertical: AppDimensions.verticalSpaceXL,
                                      horizontal: AppDimensions.paddingM,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.inputRadius,
                                      ),
                                      border: Border.all(
                                        color: provider.selectedIdDocument != null 
                                            ? AppColors.primary 
                                            : AppColors.border,
                                        width: 1.5,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: provider.selectedIdDocument != null
                                        ? Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: AppColors.primary,
                                                size: 24.w,
                                              ),
                                              SizedBox(width: AppDimensions.paddingM),
                                              Expanded(
                                                child: Text(
                                                  provider.selectedIdDocument!.path.split('/').last,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.close,
                                                  size: 20.w,
                                                  color: AppColors.textSecondary,
                                                ),
                                                onPressed: () {
                                                  provider.setSelectedIdDocument(null);
                                                },
                                              ),
                                            ],
                                          )
                                        : Column(
                                            children: [
                                              Icon(
                                                Icons.description_outlined,
                                                size: 48.w,
                                                color: AppColors.iconSecondary,
                                              ),
                                              SizedBox(height: AppDimensions.verticalSpaceM),
                                              Text(
                                                'Click to upload or drag and drop',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              SizedBox(height: AppDimensions.verticalSpaceS),
                                              Text(
                                                'PNG, JPG, PDF up to 5MB',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.textSecondary,
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
                        
                        SizedBox(height: AppDimensions.verticalSpaceL),
                        
                        // Upload Recent Photo Container
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
                                  'Upload Recent Photo (Selfie or Passport style)',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                
                                SizedBox(height: AppDimensions.verticalSpaceL),
                                
                                // Upload Area for Photo
                                InkWell(
                                  onTap: _handlePhotoUpload,
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      vertical: AppDimensions.verticalSpaceXL,
                                      horizontal: AppDimensions.paddingM,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.inputRadius,
                                      ),
                                      border: Border.all(
                                        color: provider.selectedPhoto != null 
                                            ? AppColors.primary 
                                            : AppColors.border,
                                        width: 1.5,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: provider.selectedPhoto != null
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
                                                        color: AppColors.textPrimary,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.check_circle,
                                                          color: AppColors.primary,
                                                          size: 16.w,
                                                        ),
                                                        SizedBox(width: 4.w),
                                                        Text(
                                                          'Photo selected',
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: AppColors.primary,
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
                                                  color: AppColors.textSecondary,
                                                ),
                                                onPressed: () {
                                                  provider.setSelectedPhoto(null);
                                                },
                                              ),
                                            ],
                                          )
                                        : Column(
                                            children: [
                                              Icon(
                                                Icons.camera_alt_outlined,
                                                size: 48.w,
                                                color: AppColors.iconSecondary,
                                              ),
                                              SizedBox(height: AppDimensions.verticalSpaceM),
                                              Text(
                                                'Click to upload or drag and drop',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              SizedBox(height: AppDimensions.verticalSpaceS),
                                              Text(
                                                'PNG, JPG, PDF up to 5MB',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.textSecondary,
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
        );
      },
    );
  }
}

