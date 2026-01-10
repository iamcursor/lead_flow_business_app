import 'dart:io';
import 'dart:convert';

import 'package:lead_flow_business/common/constants/app_url.dart';

import '../common/utils/request_provider.dart';
import '../common/utils/app_excpetions.dart';

import '../models/business_owner_profile/business_profile.dart';
import '../models/business_owner_profile/change_password_model.dart';

class BusinessProfileService {
  // Get Business Owner Profile
  Future<Map<String, dynamic>> getBusinessOwnerProfile() async {
    try {
      final data = await RequestProvider.get(
        url: AppUrl.getBusinessOwnerProfile,
      );

      if (data == null) {
        throw UnknownException('Get business owner profile failed: No response from server');
      }

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw UnknownException('Invalid response format');
      }
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Get business owner profile failed: ${e.toString()}');
    }
  }

  // Analyze ID Card File
  Future<Map<String, dynamic>> analyzeIdCardFile(File idCardFile) async {
    try {
      if (!await idCardFile.exists()) {
        throw UnknownException('ID card file does not exist');
      }

      final fields = <String, dynamic>{};
      final files = <String, File>{
        'file': idCardFile,
      };

      final data = await RequestProvider.postMultipart(
        url: AppUrl.analyzeFile,
        fields: fields,
        files: files,
      );

      if (data == null) {
        throw UnknownException('Analyze file failed: No response from server');
      }

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw UnknownException('Invalid response format');
      }
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Analyze file failed: ${e.toString()}');
    }
  }

  // Create / Update Business Profile with files (multipart/form-data)
  Future<Map<String, dynamic>> updateBusinessProfileWithFiles(
    BusinessProfileModel model, {
    String? name,
    String? phone,
    File? idProofFile,
    File? recentPhoto,
    File? logoFile,
    String? profileId,
  }) async {
    try {
      final jsonData = model.toJson();
      
      // Convert service_category_ids from string to array (SEND IDs, NOT NAMES)
      List<String> categoryIds = [];
      
      // Add selected sub-service IDs from service_category_ids field
      if (jsonData['service_category_ids'] != null && jsonData['service_category_ids'].toString().isNotEmpty) {
        final selectedCategoryIds = jsonData['service_category_ids'].toString()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        categoryIds.addAll(selectedCategoryIds);
      }
      
      // Replace service_categories with IDs (backend expects this field to contain IDs)
      jsonData['service_categories'] = categoryIds;
      
      // Replace primary_service_category with ID (backend expects ID)
      if (jsonData['primary_service_category_id'] != null && jsonData['primary_service_category_id'].toString().isNotEmpty) {
        jsonData['primary_service_category'] = jsonData['primary_service_category_id'];
      }
      // Remove the ID field as we've copied it to the main field
      jsonData.remove('primary_service_category_id');
      jsonData.remove('service_category_ids'); // Remove the helper field
      
      // Convert services_offered from string to array
      if (jsonData['services_offered'] != null && jsonData['services_offered'].toString().isNotEmpty) {
        final services = jsonData['services_offered'].toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        jsonData['services_offered'] = services;
      } else {
        jsonData['services_offered'] = [];
      }
      
      // Convert business_hours from string to object
      Map<String, String> businessHoursMap = {};
      if (jsonData['business_hours'] != null && jsonData['business_hours'].toString().isNotEmpty) {
        final hoursStr = jsonData['business_hours'].toString();
        // Parse "17:47 - 20:47" format
        if (hoursStr.contains(' - ')) {
          final parts = hoursStr.split(' - ');
          if (parts.length == 2) {
            businessHoursMap = {
              'start_time': parts[0].trim(),
              'end_time': parts[1].trim(),
            };
          }
        }
      }
      // For FormData with nested objects, convert to JSON string
      jsonData['business_hours'] = businessHoursMap.isNotEmpty 
          ? jsonEncode(businessHoursMap) 
          : jsonEncode({});
      
      // Add name field if provided
      if (name != null && name.isNotEmpty) {
        jsonData['name'] = name;
      }
      
      // Add phone field if provided
      if (phone != null && phone.isNotEmpty) {
        jsonData['phone'] = phone;
      }
      
      final formDataMap = <String, dynamic>{};
      
      // Add profile ID if provided (required for update)
      if (profileId != null && profileId.isNotEmpty) {
        formDataMap['id'] = profileId;
      }
      
      // Copy all fields except arrays and objects which need special handling
      // Also filter out empty strings for fields with validation constraints
      // IMPORTANT: Skip file fields (logo, id_proof_file, recent_photo) as they are sent separately as files
      final fileFields = ['logo', 'id_proof_file', 'recent_photo', 'gallery'];
      
      jsonData.forEach((key, value) {
        // Skip file fields - they should only be sent as files, not as form fields
        if (fileFields.contains(key)) {
          return; // Skip this field - it will be sent as a file if provided
        }
        
        // Skip empty strings for fields that have validation constraints
        if (value is String && value.isEmpty) {
          // Fields that should not be sent as empty strings
          final fieldsToSkipWhenEmpty = [
            'availability_status',
            'id_proof_type',
            'base_service_rate',
            'business_hours',
          ];
          if (fieldsToSkipWhenEmpty.contains(key)) {
            return; // Skip this field
          }
        }
        
        if (key == 'service_categories' || key == 'services_offered') {
          // These are already Lists
          formDataMap[key] = value;
        } else if (key == 'business_hours') {
          // business_hours is already a JSON string, but only add if not empty
          if (value != null && value.toString().isNotEmpty && value.toString() != '{}') {
            formDataMap[key] = value;
          }
        } else {
          formDataMap[key] = value;
        }
      });

      // Prepare files map
      final filesMap = <String, File>{};
      if (idProofFile != null && await idProofFile.exists()) {
        filesMap['id_proof_file'] = idProofFile;
      }
      if (recentPhoto != null && await recentPhoto.exists()) {
        filesMap['recent_photo'] = recentPhoto;
      }
      if (logoFile != null && await logoFile.exists()) {
        filesMap['logo'] = logoFile;
      }

      // Remove empty string fields that have validation constraints
      final fieldsToRemoveIfEmpty = [
        'availability_status',
        'id_proof_type',
        'base_service_rate',
      ];
      for (final field in fieldsToRemoveIfEmpty) {
        if (formDataMap.containsKey(field) && 
            formDataMap[field] is String && 
            (formDataMap[field] as String).isEmpty) {
          formDataMap.remove(field);
        }
      }

      final data = await RequestProvider.putMultipart(
        url: AppUrl.updateBusinessOwnerProfile,
        fields: formDataMap,
        files: filesMap.isNotEmpty ? filesMap : null,
      );

      if (data == null) {
        throw UnknownException('Business profile update failed: No response from server');
      }

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw UnknownException('Invalid response format');
      }
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Business profile update failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> changePassword(ChangePasswordModel model) async {
    try {
      final data = await RequestProvider.put(
        url: AppUrl.changePassword,
        body: model.toJson(),
      );

      if (data == null) {
        throw UnknownException('Change password failed: No response from server');
      }

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw UnknownException('Invalid response format');
      }
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Change password failed: ${e.toString()}');
    }
  }

  // Update Profile with PATCH request (for basic profile fields)
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? serviceCategory,
    String? serviceCategoryId, // Add ID parameter
    String? city,
    File? recentPhoto,
  }) async {
    try {
      final formDataMap = <String, dynamic>{};

      // Add fields if provided
      if (name != null && name.isNotEmpty) {
        formDataMap['name'] = name;
      }
      if (email != null && email.isNotEmpty) {
        formDataMap['email'] = email;
      }
      if (phone != null && phone.isNotEmpty) {
        formDataMap['phone'] = phone;
      }
      // Send ID instead of name if available
      if (serviceCategoryId != null && serviceCategoryId.isNotEmpty) {
        formDataMap['primary_service_category'] = serviceCategoryId;
      } else if (serviceCategory != null && serviceCategory.isNotEmpty) {
        // Fallback to name if ID not available (for backward compatibility)
        formDataMap['primary_service_category'] = serviceCategory;
      }
      if (city != null && city.isNotEmpty) {
        formDataMap['city'] = city;
      }

      // Prepare files map
      final filesMap = <String, File>{};
      if (recentPhoto != null && await recentPhoto.exists()) {
        filesMap['recent_photo'] = recentPhoto;
      }

      final data = await RequestProvider.patchMultipart(
        url: AppUrl.updateBusinessOwnerProfile,
        fields: formDataMap,
        files: filesMap.isNotEmpty ? filesMap : null,
      );

      if (data == null) {
        throw UnknownException('Profile update failed: No response from server');
      }

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw UnknownException('Invalid response format');
      }
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Profile update failed: ${e.toString()}');
    }
  }
}
