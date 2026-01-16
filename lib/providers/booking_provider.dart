import 'package:flutter/foundation.dart';
import '../models/booking/booking_model.dart';
import '../services/booking_service.dart';

class ExtraCharge {
  final String name;
  final double price;

  ExtraCharge({
    required this.name,
    required this.price,
  });
}

class BookingProvider with ChangeNotifier {
  final BookingService _service = BookingService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => List.unmodifiable(_bookings);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Booking details state
  bool _isUpdatingStatus = false;
  bool get isUpdatingStatus => _isUpdatingStatus;

  final List<String> _serviceNotes = [];
  List<String> get serviceNotes => List.unmodifiable(_serviceNotes);

  final List<ExtraCharge> _extraCharges = [];
  List<ExtraCharge> get extraCharges => List.unmodifiable(_extraCharges);

  // Booking details methods
  void addServiceNote(String note) {
    _serviceNotes.add(note);
    notifyListeners();
  }

  void addExtraCharge(ExtraCharge charge) {
    _extraCharges.add(charge);
    notifyListeners();
  }

  void clearBookingDetails() {
    _serviceNotes.clear();
    _extraCharges.clear();
    _isUpdatingStatus = false;
    notifyListeners();
  }

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

  BookingModel? _lastUpdatedBooking;
  BookingModel? get lastUpdatedBooking => _lastUpdatedBooking;

  // Update booking status
  Future<BookingModel?> updateBookingStatus({
    required String bookingId,
    required String status,
    String? businessNotes,
    String? finalPrice,
  }) async {
    try {
      _isUpdatingStatus = true;
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

      _lastUpdatedBooking = updatedBooking;
      _isUpdatingStatus = false;
      _isLoading = false;
      notifyListeners();
      return updatedBooking;
    } catch (e) {
      _isUpdatingStatus = false;
      _isLoading = false;
      _errorMessage = 'Failed to update booking status: ${e.toString()}';
      _lastUpdatedBooking = null;
      notifyListeners();
      return null;
    }
  }

  // Confirm booking
  Future<BookingModel?> confirmBooking({
    required String bookingId,
  }) async {
    try {
      _isUpdatingStatus = true;
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedBooking = await _service.confirmBooking(
        bookingId: bookingId,
      );

      // Update the booking in the list
      final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
      if (index != -1) {
        _bookings[index] = updatedBooking;
      }

      _lastUpdatedBooking = updatedBooking;
      _isUpdatingStatus = false;
      _isLoading = false;
      notifyListeners();
      return updatedBooking;
    } catch (e) {
      _isUpdatingStatus = false;
      _isLoading = false;
      _errorMessage = 'Failed to confirm booking: ${e.toString()}';
      _lastUpdatedBooking = null;
      notifyListeners();
      return null;
    }
  }
}



