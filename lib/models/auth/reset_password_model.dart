class ResetPasswordModel {
  final String email;
  final String newPassword;

  ResetPasswordModel({
    required this.email,
    required this.newPassword,
  });

  // Convert JSON to Model
  factory ResetPasswordModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordModel(
      email: json['email'] ?? '',
      newPassword: json['new_password'] ?? '',
    );
  }

  // Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'new_password': newPassword,
    };
  }
}
