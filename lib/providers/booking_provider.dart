import 'package:flutter/foundation.dart';
import '../models/booking/booking_model.dart';
import '../services/booking_service.dart';


class BookingProvider with ChangeNotifier {
  final BookingService _service = BookingService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => List.unmodifiable(_bookings);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Get all bookings
  Future<void> fetchBookings() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final bookings = await _service.getBookings();

      _bookings = bookings;
      _isLoading = false;
      notifyListeners();
    }  catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch bookings: ${e.toString()}';
      notifyListeners();
    }
  }

  // Refresh bookings
  Future<void> refreshBookings() async {
    await fetchBookings();
  }

  // Update booking status
  Future<bool> updateBookingStatus({
    required String bookingId,
    required String status,
    String? businessNotes,
    String? finalPrice,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedBooking = await _service.updateBookingStatus(
        bookingId: bookingId,
        status: status,
        businessNotes: businessNotes,
        finalPrice: finalPrice,
      );

      // Update the booking in the list
      final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
      if (index != -1) {
        _bookings[index] = updatedBooking;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update booking status: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}



