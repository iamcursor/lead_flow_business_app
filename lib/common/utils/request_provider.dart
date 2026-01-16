import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lead_flow_business/common/utils/utils.dart';
import 'package:lead_flow_business/styles/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';



import 'app_excpetions.dart';

class RequestProvider {
  // Singleton client with timeout
  static final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 120);

  /// Centralized header generator
  // static Future<Map<String, String>> _getHeaders() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token') ?? '';
  //   final cookie = prefs.getString('Cookie') ?? '';
  //
  //   return {
  //     'Content-Type': 'application/json',
  //     'Accept': 'application/json',
  //     'Authorization': 'Bearer $token',
  //     if (cookie.isNotEmpty) 'Cookie': cookie,
  //     'User-Agent': 'MobileApp/1.0',
  //   };
  // }

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final cookie = prefs.getString('Cookie') ?? '';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'MobileApp/1.0',
    };

    // Only add Authorization if token is not empty
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Only add Cookie if it exists
    if (cookie.isNotEmpty) {
      headers['Cookie'] = cookie;
    }

    return headers;
  }

  /// Save cookie from set-cookie header (for login/device auth endpoints)
  static Future<void> _saveCookieFromResponse(http.Response response) async {
    final url = response.request?.url.toString() ?? '';
    if (!url.contains('LogInDeviceFromApp') && !url.contains('DeviceAuthenticate')) {
      return;
    }

    final setCookie = response.headers['set-cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      final cookieValue = setCookie.split(';').first;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('Cookie', cookieValue);
      debugPrint('Cookie saved: $cookieValue');
    }
  }

  /// Centralized response handler
  static Future<dynamic> _handleResponse(http.Response response) async {
    await _saveCookieFromResponse(response);

    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return response.body; // Return raw body if not JSON
        }

      case 400:
        throw BadRequestException(response.body);
      case 401:
        throw UnauthorizedException(response.body);
      case 403:
        throw ForbiddenException(response.body);
      case 404:
        throw NotFoundException(response.body);
      case 405:
        throw MethodNotAllowedException(response.body);
      case 500:
        throw InternalServerErrorException(response.body);
      default:
        throw FetchDataException(
          'Server error: ${response.statusCode}\n${response.body}',
        );
    }
  }

  /// Generic API call wrapper with error handling and toast
  static Future<T?> safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on SocketException {
      Utils.toastMessage(message: 'No internet connection', color: AppColors.error);
      return null;
    } on TimeoutException {
      Utils.toastMessage(
        message: 'Request timed out. Please try again.',
        color: AppColors.error,
      );
      return null;
    } on FetchDataException catch (e) {
      Utils.toastMessage(message: e.toString(), color: AppColors.error);
      return null;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      Utils.toastMessage(message: 'Something went wrong', color: AppColors.error);
      return null;
    }
  }

  // ====================== HTTP METHODS ======================

  /// GET Request
  static Future<dynamic> get({
    required String url,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await safeApiCall(() async {
      final headers = await _getHeaders();
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);

      debugPrint('GET → $uri');
      debugPrint('Headers: $headers');

      final response = await _client.get(uri, headers: headers).timeout(_timeout);
      debugPrint('GET ← ${response.statusCode}');

      return await _handleResponse(response);
    });
  }

  /// POST Request
  static Future<dynamic> post({
    required String url,
    dynamic body,
  }) async {
    return await safeApiCall(() async {
      final headers = await _getHeaders();
      final jsonBody = body is String ? body : jsonEncode(body);

      debugPrint('POST → $url');

      final response = await _client
          .post(Uri.parse(url), headers: headers, body: jsonBody)
          .timeout(_timeout);

      debugPrint('POST ← ${response.statusCode}');
      
      // Print response body on single line
      try {
        if (response.body.isNotEmpty) {
          final parsed = jsonDecode(response.body);
          final formatted = jsonEncode(parsed);
          debugPrint('Response: $formatted');
        } else {
          debugPrint('Response: empty');
        }
      } catch (e) {
        // If formatting fails, just print the raw response body
        debugPrint('Response: ${response.body}');
      }
      
      return await _handleResponse(response);
    });
  }

  /// PUT Request
  static Future<dynamic> put({
    required String url,
    dynamic body,
  }) async {
    return await safeApiCall(() async {
      final headers = await _getHeaders();
      final jsonBody = body is String ? body : jsonEncode(body);

      debugPrint('PUT → $url');
      debugPrint('Body: $jsonBody');

      final response = await _client
          .put(Uri.parse(url), headers: headers, body: jsonBody)
          .timeout(_timeout);

      debugPrint('PUT ← ${response.statusCode}');
      return await _handleResponse(response);
    });
  }

  /// PATCH Request
  static Future<dynamic> patch({
    required String url,
    dynamic body,
  }) async {
    return await safeApiCall(() async {
      final headers = await _getHeaders();
      final jsonBody = body is String ? body : jsonEncode(body);

      debugPrint('PATCH → $url');
      debugPrint('Body: $jsonBody');

      final response = await _client
          .patch(Uri.parse(url), headers: headers, body: jsonBody)
          .timeout(_timeout);

      debugPrint('PATCH ← ${response.statusCode}');
      return await _handleResponse(response);
    });
  }

  /// DELETE Request
  static Future<dynamic> delete({
    required String url,
  }) async {
    return await safeApiCall(() async {
      final headers = await _getHeaders();

      debugPrint('DELETE → $url');

      final response = await _client.delete(Uri.parse(url), headers: headers).timeout(_timeout);
      debugPrint('DELETE ← ${response.statusCode}');

      return await _handleResponse(response);
    });
  }

  /// Check if URL is a public endpoint that doesn't require authentication
  static bool _isPublicEndpoint(String url) {
    final publicEndpoints = [
      '/users/login/',
      '/users/signup/',
      '/users/send-otp/',
      '/users/verify-otp/',
      '/users/google-signin/business-owner/',
    ];
    return publicEndpoints.any((endpoint) => url.contains(endpoint));
  }

  /// Get content type from file name extension
  static http.MediaType? _getContentTypeFromFileName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return http.MediaType('image', 'jpeg');
      case 'png':
        return http.MediaType('image', 'png');
      case 'gif':
        return http.MediaType('image', 'gif');
      case 'webp':
        return http.MediaType('image', 'webp');
      case 'pdf':
        return http.MediaType('application', 'pdf');
      default:
        return null; // Let http package detect it
    }
  }

  /// Truncate filename to 100 characters while preserving extension
  static String _truncateFileName(String fileName) {
    if (fileName.length <= 100) {
      return fileName;
    }
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1) {
      // No extension, just truncate
      return fileName.substring(0, 100);
    }
    final extension = fileName.substring(lastDotIndex);
    final nameWithoutExt = fileName.substring(0, lastDotIndex);
    // Truncate name part to leave room for extension
    final maxNameLength = 100 - extension.length;
    return '${nameWithoutExt.substring(0, maxNameLength)}$extension';
  }

  /// POST Request with Multipart Form Data
  static Future<dynamic> postMultipart({
    required String url,
    required Map<String, dynamic> fields,
    Map<String, File>? files,
  }) async {
    return await safeApiCall(() async {
      final headers = await _getHeaders();
      // Remove Content-Type for multipart (http package will set it with boundary)
      headers.remove('Content-Type');

      debugPrint('POST (multipart) → $url');

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);

      // Add fields
      fields.forEach((key, value) {
        if (value != null) {
          if (value is File) {
            // File will be handled separately
            return;
          } else if (value is List) {
            // Handle lists (e.g., service_categories)
            for (var item in value) {
              request.fields.addAll({'$key[]': item.toString()});
            }
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          if (await entry.value.exists()) {
            final fullFileName = entry.value.path.split('/').last;
            final fileName = _truncateFileName(fullFileName);
            final contentType = _getContentTypeFromFileName(fileName);
            request.files.add(
              await http.MultipartFile.fromPath(
                entry.key, 
                entry.value.path, 
                filename: fileName,
                contentType: contentType,
              ),
            );
          }
        }
      }

      // Also add files from fields if they are File objects
      for (final entry in fields.entries) {
        if (entry.value is File && await (entry.value as File).exists()) {
          final file = entry.value as File;
          final fullFileName = file.path.split('/').last;
          final fileName = _truncateFileName(fullFileName);
          final contentType = _getContentTypeFromFileName(fileName);
          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key, 
              file.path, 
              filename: fileName,
              contentType: contentType,
            ),
          );
        }
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('POST (multipart) ← ${response.statusCode}');

      return await _handleResponse(response);
    });
  }

  /// PUT Request with Multipart Form Data
  static Future<dynamic> putMultipart({
    required String url,
    required Map<String, dynamic> fields,
    Map<String, File>? files,
  }) async {
    return await safeApiCall(() async {
      final headers = await _getHeaders();
      // Remove Content-Type for multipart (http package will set it with boundary)
      headers.remove('Content-Type');

      debugPrint('PUT (multipart) → $url');

      final request = http.MultipartRequest('PUT', Uri.parse(url));
      request.headers.addAll(headers);

      // Add fields
      fields.forEach((key, value) {
        if (value != null) {
          if (value is File) {
            // File will be handled separately
            return;
          } else if (value is List) {
            // Handle lists (e.g., service_categories)
            for (var item in value) {
              request.fields.addAll({'$key[]': item.toString()});
            }
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          if (await entry.value.exists()) {
            final fullFileName = entry.value.path.split('/').last;
            final fileName = _truncateFileName(fullFileName);
            final contentType = _getContentTypeFromFileName(fileName);
            request.files.add(
              await http.MultipartFile.fromPath(
                entry.key, 
                entry.value.path, 
                filename: fileName,
                contentType: contentType,
              ),
            );
          }
        }
      }

      // Also add files from fields if they are File objects
      for (final entry in fields.entries) {
        if (entry.value is File && await (entry.value as File).exists()) {
          final file = entry.value as File;
          final fullFileName = file.path.split('/').last;
          final fileName = _truncateFileName(fullFileName);
          final contentType = _getContentTypeFromFileName(fileName);
          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key, 
              file.path, 
              filename: fileName,
              contentType: contentType,
            ),
          );
        }
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('PUT (multipart) ← ${response.statusCode}');

      return await _handleResponse(response);
    });
  }

  /// PATCH Request with Multipart Form Data
  static Future<dynamic> patchMultipart({
    required String url,
    required Map<String, dynamic> fields,
    Map<String, File>? files,
  }) async {
    return await safeApiCall(() async {
      final headers = await _getHeaders();
      // Remove Content-Type for multipart (http package will set it with boundary)
      headers.remove('Content-Type');

      debugPrint('PATCH (multipart) → $url');

      final request = http.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll(headers);

      // Add fields
      fields.forEach((key, value) {
        if (value != null) {
          if (value is File) {
            // File will be handled separately
            return;
          } else if (value is List) {
            // Handle lists (e.g., service_categories)
            for (var item in value) {
              request.fields.addAll({'$key[]': item.toString()});
            }
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          if (await entry.value.exists()) {
            final fullFileName = entry.value.path.split('/').last;
            final fileName = _truncateFileName(fullFileName);
            final contentType = _getContentTypeFromFileName(fileName);
            request.files.add(
              await http.MultipartFile.fromPath(
                entry.key, 
                entry.value.path, 
                filename: fileName,
                contentType: contentType,
              ),
            );
          }
        }
      }

      // Also add files from fields if they are File objects
      for (final entry in fields.entries) {
        if (entry.value is File && await (entry.value as File).exists()) {
          final file = entry.value as File;
          final fullFileName = file.path.split('/').last;
          final fileName = _truncateFileName(fullFileName);
          final contentType = _getContentTypeFromFileName(fileName);
          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key, 
              file.path, 
              filename: fileName,
              contentType: contentType,
            ),
          );
        }
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('PATCH (multipart) ← ${response.statusCode}');

      return await _handleResponse(response);
    });
  }
}