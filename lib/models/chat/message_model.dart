class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderEmail;
  final String? senderRole;
  final String? senderProfileImageUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRead;
  final bool isSentByMe; // This will be set based on current user ID

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderEmail,
    this.senderRole,
    this.senderProfileImageUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.isRead,
    required this.isSentByMe,
  });

  // Helper method to parse UTC timestamp and convert to local time
  static DateTime _parseToLocalTime(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      // If the string ends with 'Z' or is in UTC format, convert to local
      if (dateString.endsWith('Z') || dateString.contains('+00:00') || dateTime.isUtc) {
        return dateTime.toLocal();
      }
      // If already in local time, return as is
      return dateTime;
    } catch (e) {
      // If parsing fails, return current time
      return DateTime.now();
    }
  }

  // Factory constructor for API responses
  factory MessageModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final senderId = json['sender']?.toString() ?? json['sender_id']?.toString() ?? '';
    final roomId = json['room']?.toString() ?? json['room_id']?.toString() ?? '';
    final currentUser = currentUserId ?? '';
    
    return MessageModel(
      id: json['id']?.toString() ?? '',
      roomId: roomId,
      senderId: senderId,
      senderName: json['sender_name']?.toString() ?? '',
      senderEmail: json['sender_email']?.toString(),
      senderRole: json['sender_role']?.toString(),
      senderProfileImageUrl: json['sender_profile_image']?.toString(),
      content: json['content']?.toString() ?? json['message']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? _parseToLocalTime(json['created_at'].toString())
          : (json['timestamp'] != null
              ? _parseToLocalTime(json['timestamp'].toString())
              : DateTime.now()),
      updatedAt: json['updated_at'] != null
          ? _parseToLocalTime(json['updated_at'].toString())
          : DateTime.now(),
      isRead: json['is_read'] == true,
      isSentByMe: currentUser.isNotEmpty ? senderId == currentUser : (json['is_sent_by_me'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_email': senderEmail,
      'sender_role': senderRole,
      'sender_profile_image': senderProfileImageUrl,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_read': isRead,
      'is_sent_by_me': isSentByMe,
    };
  }

  // Getter for backward compatibility
  String get message => content;
  DateTime get timestamp => createdAt;
}

