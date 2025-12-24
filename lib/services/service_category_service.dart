import 'package:lead_flow_business/common/constants/app_url.dart';

import '../common/utils/request_provider.dart';
import '../common/utils/app_excpetions.dart';
import '../models/service_category/service_category_model.dart';
import '../models/service_category/sub_category_model.dart';

/// Service Category Service
/// Handles service category API calls
class ServiceCategoryService {
  /// Get main service categories
  Future<List<ServiceCategoryModel>> getMainCategories() async {
    try {
      final data = await RequestProvider.get(
        url: AppUrl.mainServiceCategories,
      );

      if (data == null) {
        throw UnknownException('Failed to fetch service categories: No response from server');
      }

      if (data is List) {
        final List<dynamic> dataList = data;
        return dataList
            .map((json) => ServiceCategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic>) {
        // Handle case where API returns wrapped in an object
        if (data.containsKey('results') && data['results'] is List) {
          final List<dynamic> dataList = data['results'] as List<dynamic>;
          return dataList
              .map((json) => ServiceCategoryModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data.containsKey('data') && data['data'] is List) {
          final List<dynamic> dataList = data['data'] as List<dynamic>;
          return dataList
              .map((json) => ServiceCategoryModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw UnknownException('Invalid response format');
        }
      } else {
        throw UnknownException('Invalid response format');
      }
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Failed to fetch service categories: ${e.toString()}');
    }
  }

  /// Get sub-categories by main category ID
  Future<List<SubCategoryModel>> getSubCategoriesByMainCategory(String mainCategoryId) async {
    try {
      final data = await RequestProvider.get(
        url: AppUrl.subServiceCategories,
        queryParameters: {'main_category': mainCategoryId},
      );

      if (data == null) {
        throw UnknownException('Failed to fetch sub-categories: No response from server');
      }

      if (data is List) {
        final List<dynamic> dataList = data;
        return dataList
            .map((json) => SubCategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic>) {
        // Handle case where API returns wrapped in an object
        if (data.containsKey('results') && data['results'] is List) {
          final List<dynamic> dataList = data['results'] as List<dynamic>;
          return dataList
              .map((json) => SubCategoryModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data.containsKey('data') && data['data'] is List) {
          final List<dynamic> dataList = data['data'] as List<dynamic>;
          return dataList
              .map((json) => SubCategoryModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw UnknownException('Invalid response format');
        }
      } else {
        throw UnknownException('Invalid response format');
      }
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Failed to fetch sub-categories: ${e.toString()}');
    }
  }
}
