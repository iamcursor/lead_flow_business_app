class ChangePasswordModel {
  final String oldPassword;
  final String newPassword;

  ChangePasswordModel({
    required this.oldPassword,
    required this.newPassword,
  });

  factory ChangePasswordModel.fromJson(Map<String, dynamic> json) {
    return ChangePasswordModel(
      oldPassword: json['old_password'] ?? '',
      newPassword: json['new_password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'old_password': oldPassword,
      'new_password': newPassword,
    };
  }
}
