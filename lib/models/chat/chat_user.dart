class ChatUser {
  final String id;
  final String? email;
  final String? name;
  final String? role;
  final String? profileImage;

  ChatUser({
    required this.id,
    this.email,
    this.name,
    this.role,
    this.profileImage,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString(),
      name: json['name']?.toString(),
      role: json['role']?.toString(),
      profileImage: json['profile_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'profile_image': profileImage,
    };
  }
}




