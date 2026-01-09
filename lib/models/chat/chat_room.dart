import 'chat_message.dart';
import 'chat_user.dart';

class ChatRoom {
  final String id;
  final String businessOwner;
  final String? businessOwnerEmail;
  final String? businessOwnerName;
  final String? potentialCustomer;
  final String? potentialCustomerEmail;
  final String? potentialCustomerName;
  final ChatMessage? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;
  final ChatUser? otherUser;
  final String? createdAt;
  final String? updatedAt;
  final bool isActive;

  ChatRoom({
    required this.id,
    required this.businessOwner,
    this.businessOwnerEmail,
    this.businessOwnerName,
    this.potentialCustomer,
    this.potentialCustomerEmail,
    this.potentialCustomerName,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.otherUser,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id']?.toString() ?? '',
      businessOwner: json['business_owner']?.toString() ?? '',
      businessOwnerEmail: json['business_owner_email']?.toString(),
      businessOwnerName: json['business_owner_name']?.toString(),
      potentialCustomer: json['potential_customer']?.toString(),
      potentialCustomerEmail: json['potential_customer_email']?.toString(),
      potentialCustomerName: json['potential_customer_name']?.toString(),
      lastMessage: json['last_message'] != null && json['last_message'] is Map<String, dynamic>
          ? ChatMessage.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      lastMessageTime: json['last_message_time']?.toString(),
      unreadCount: json['unread_count'] != null
          ? (json['unread_count'] is num
              ? (json['unread_count'] as num).toInt()
              : int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0)
          : 0,
      otherUser: json['other_user'] != null && json['other_user'] is Map<String, dynamic>
          ? ChatUser.fromJson(json['other_user'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_owner': businessOwner,
      'business_owner_email': businessOwnerEmail,
      'business_owner_name': businessOwnerName,
      'potential_customer': potentialCustomer,
      'potential_customer_email': potentialCustomerEmail,
      'potential_customer_name': potentialCustomerName,
      'last_message': lastMessage?.toJson(),
      'last_message_time': lastMessageTime,
      'unread_count': unreadCount,
      'other_user': otherUser?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_active': isActive,
    };
  }
}



