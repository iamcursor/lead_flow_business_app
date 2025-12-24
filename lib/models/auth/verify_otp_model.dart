class VerifyOtpModel {
  final String email;
  final String otp;

  VerifyOtpModel({
    required this.email,
    required this.otp,
  });

  // Factory constructor to create an instance from JSON
  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpModel(
      email: json['email'] as String,
      otp: json['otp'] as String,
    );
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}
