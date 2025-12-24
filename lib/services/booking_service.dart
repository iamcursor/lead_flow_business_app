import 'package:flutter/foundation.dart';
import '../common/constants/app_url.dart';
import '../common/utils/request_provider.dart';
import '../common/utils/app_excpetions.dart';
import '../models/booking/booking_model.dart';

class BookingService {
  // Get all bookings for the business owner
  Future<List<BookingModel>> getBookings() async {
    try {
      final data = await RequestProvider.get(
        url: AppUrl.bookings,
      );

      if (data == null) {
        throw UnknownException('Get bookings failed: No response from server');
      }

      if (data is List) {
        final List<dynamic> dataList = data;
        return dataList.map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return BookingModel.fromJson(item);
            } else if (item is Map) {
              // Handle case where map might not be properly typed
              return BookingModel.fromJson(Map<String, dynamic>.from(item));
            } else {
              throw FormatException('Invalid booking item format: $item');
            }
          } catch (e) {
            throw FormatException('Error parsing booking: $e');
          }
        }).toList();
      } else if (data is Map<String, dynamic>) {
        // If API returns a map with a 'results' or 'data' key
        if (data.containsKey('results')) {
          final results = data['results'];
          if (results is List) {
            final List<dynamic> dataList = results;
            return dataList.map((item) {
              try {
                if (item is Map<String, dynamic>) {
                  return BookingModel.fromJson(item);
                } else if (item is Map) {
                  return BookingModel.fromJson(Map<String, dynamic>.from(item));
                } else {
                  throw FormatException('Invalid booking item format: $item');
                }
              } catch (e) {
                throw FormatException('Error parsing booking: $e');
              }
            }).toList();
          }
        } else if (data.containsKey('data')) {
          final dataValue = data['data'];
          if (dataValue is List) {
            final List<dynamic> dataList = dataValue;
            return dataList.map((item) {
              try {
                if (item is Map<String, dynamic>) {
                  return BookingModel.fromJson(item);
                } else if (item is Map) {
                  return BookingModel.fromJson(Map<String, dynamic>.from(item));
                } else {
                  throw FormatException('Invalid booking item format: $item');
                }
              } catch (e) {
                throw FormatException('Error parsing booking: $e');
              }
            }).toList();
          }
        }
      }
      throw UnknownException('Invalid response format');
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Get bookings failed: ${e.toString()}');
    }
  }

  // Update booking status
  Future<BookingModel> updateBookingStatus({
    required String bookingId,
    required String status,
    String? businessNotes,
    String? finalPrice,
  }) async {
    try {
      final body = <String, dynamic>{
        'status': status,
      };

      if (businessNotes != null && businessNotes.isNotEmpty) {
        body['business_notes'] = businessNotes;
      }

      if (finalPrice != null && finalPrice.isNotEmpty) {
        body['final_price'] = finalPrice;
      }

      final data = await RequestProvider.patch(
        url: AppUrl.updateBookingStatus(bookingId),
        body: body,
      );

      if (data == null) {
        throw UnknownException('Update booking status failed: No response from server');
      }

      if (data is Map<String, dynamic>) {
        return BookingModel.fromJson(data);
      } else if (data is Map) {
        return BookingModel.fromJson(Map<String, dynamic>.from(data));
      }

      throw UnknownException('Invalid response format: ${data.runtimeType}');
    } on NetworkExceptions catch (e) {

      rethrow;
    } catch (e) {

      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Update booking status failed: ${e.toString()}');
    }
  }
}
