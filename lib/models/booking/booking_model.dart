class BookingModel {
  final String id;
  final String bookingId;
  final String customerName;
  final String serviceName;
  final String date;
  final String time;
  final String location;
  final String status; // pending, completed, cancelled
  final double price;
  final String priceType; // Fixed Price, Hourly, etc.
  final String? customerProfilePicture;
  final String? distance; // e.g., "2.5 km away"
  final String? serviceNotes;
  final String? estimatedDuration; // e.g., "1.5 - 2 hrs"
  final String? paymentType; // e.g., "UPI/Wallet/COD"
  final String? customerPhone;
  // Completed booking fields
  final List<String>? completedServiceNotes; // List of completed tasks
  final List<Map<String, dynamic>>? charges; // List of charge items {label, amount}
  final double? totalCharges;
  final int? customerRating; // 1-5 stars
  final String? customerFeedback;

  BookingModel({
    required this.id,
    required this.bookingId,
    required this.customerName,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
    required this.price,
    this.priceType = 'Fixed Price',
    this.customerProfilePicture,
    this.distance,
    this.serviceNotes,
    this.estimatedDuration,
    this.paymentType,
    this.customerPhone,
    this.completedServiceNotes,
    this.charges,
    this.totalCharges,
    this.customerRating,
    this.customerFeedback,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Format date from "2025-12-15" to readable format
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '';
      try {
        final date = DateTime.parse(dateStr);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final bookingDate = DateTime(date.year, date.month, date.day);
        
        if (bookingDate == today) {
          return 'Today';
        } else if (bookingDate == today.add(const Duration(days: 1))) {
          return 'Tomorrow';
        } else if (bookingDate == today.subtract(const Duration(days: 1))) {
          return 'Yesterday';
        } else {
          return '${date.day}/${date.month}/${date.year}';
        }
      } catch (e) {
        return dateStr;
      }
    }
    
    // Format time from "14:00:00" to "2:00 PM" (ignores seconds and milliseconds)
    String formatTime(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) return '';
      try {
        // Remove seconds and milliseconds if present (e.g., "14:00:00" or "14:00:00.000")
        String cleanTimeStr = timeStr;
        if (cleanTimeStr.contains('.')) {
          // Remove milliseconds part
          cleanTimeStr = cleanTimeStr.split('.').first;
        }
        
        final parts = cleanTimeStr.split(':');
        if (parts.length >= 2) {
          // Only use hour and minute, ignore seconds
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          final period = hour >= 12 ? 'PM' : 'AM';
          final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
        }
        return timeStr;
      } catch (e) {
        return timeStr;
      }
    }
    
    // Helper to safely get nested value
    String? getNestedString(dynamic parent, String key) {
      if (parent is Map<String, dynamic>) {
        return parent[key]?.toString();
      }
      return null;
    }
    
    return BookingModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? json['id']?.toString() ?? '',
      customerName: json['customer_name_display']?.toString() ?? 
                   json['customer_name']?.toString() ?? 
                   (json['customer'] is Map<String, dynamic> 
                       ? getNestedString(json['customer'], 'name')
                       : null) ?? '',
      serviceName: json['service_name']?.toString() ?? 
                  (json['service'] is Map<String, dynamic>
                      ? getNestedString(json['service'], 'name')
                      : null) ?? '',
      date: formatDate(json['booking_date']?.toString() ?? json['date']?.toString() ?? ''),
      time: formatTime(json['booking_time']?.toString() ?? json['time']?.toString() ?? ''),
      location: json['service_address']?.toString() ?? 
               json['location']?.toString() ?? 
               json['address']?.toString() ?? '',
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      price: (json['estimated_price'] != null)
          ? ((json['estimated_price'] is num) 
              ? (json['estimated_price'] as num).toDouble() 
              : double.tryParse(json['estimated_price']?.toString() ?? '0') ?? 0.0)
          : ((json['price'] is num) 
              ? (json['price'] as num).toDouble() 
              : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0),
      priceType: json['payment_status']?.toString() ?? json['price_type']?.toString() ?? 'Fixed Price',
      customerProfilePicture: json['customer_profile_picture']?.toString() ?? 
                             (json['customer'] is Map<String, dynamic>
                                 ? getNestedString(json['customer'], 'profile_picture')
                                 : null),
      distance: json['distance']?.toString(),
      serviceNotes: json['customer_notes']?.toString() ?? 
                   json['service_notes']?.toString() ?? 
                   json['notes']?.toString(),
      estimatedDuration: json['duration_hours'] != null
          ? '${json['duration_hours']?.toString()} hrs'
          : json['estimated_duration']?.toString(),
      paymentType: json['payment_type']?.toString() ?? 'UPI/Wallet/COD',
      customerPhone: json['customer_phone']?.toString() ?? 
                    (json['customer'] is Map<String, dynamic>
                        ? getNestedString(json['customer'], 'phone')
                        : null),
      completedServiceNotes: json['completed_service_notes'] != null
          ? (json['completed_service_notes'] is List
              ? List<String>.from((json['completed_service_notes'] as List).map((e) => e.toString()))
              : null)
          : null,
      charges: json['charges'] != null
          ? (json['charges'] is List
              ? List<Map<String, dynamic>>.from(
                  (json['charges'] as List).map((e) => e is Map<String, dynamic> 
                      ? e 
                      : <String, dynamic>{'label': e.toString(), 'amount': 0.0}))
              : null)
          : null,
      totalCharges: json['total_charges'] != null
          ? (json['total_charges'] is num
              ? (json['total_charges'] as num).toDouble()
              : double.tryParse(json['total_charges']?.toString() ?? '0') ?? 0.0)
          : null,
      customerRating: json['customer_rating'] != null
          ? (json['customer_rating'] is num
              ? (json['customer_rating'] as num).toInt()
              : int.tryParse(json['customer_rating']?.toString() ?? '0'))
          : null,
      customerFeedback: json['customer_feedback']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'customer_name': customerName,
      'service_name': serviceName,
      'date': date,
      'time': time,
      'location': location,
      'status': status,
      'price': price,
      'price_type': priceType,
      'customer_profile_picture': customerProfilePicture,
      'distance': distance,
      'service_notes': serviceNotes,
      'estimated_duration': estimatedDuration,
      'payment_type': paymentType,
      'customer_phone': customerPhone,
      'completed_service_notes': completedServiceNotes,
      'charges': charges,
      'total_charges': totalCharges,
      'customer_rating': customerRating,
      'customer_feedback': customerFeedback,
    };
  }
}

