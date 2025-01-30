import 'package:uuid/uuid.dart';

class ConnectionProfile {
  final UuidValue connectionId;
  final UuidValue userId; // ✅ This replaces user1Id and user2Id
  final UuidValue otherUserId;
  final DateTime createdAt;
  final String userEmail;
  final String userDisplayId;
  final String userFullName;
  final String userWebsite;
  final String otherUserEmail;
  final String otherUserDisplayId;
  final String otherUserFullName;
  final String otherUserWebsite;

  ConnectionProfile({
    required this.connectionId,
    required this.userId,
    required this.otherUserId,
    required this.createdAt,
    required this.userEmail,
    required this.userDisplayId,
    required this.userFullName,
    required this.userWebsite,
    required this.otherUserEmail,
    required this.otherUserDisplayId,
    required this.otherUserFullName,
    required this.otherUserWebsite,
  });

  factory ConnectionProfile.fromJson(Map<String, dynamic> json) {
    return ConnectionProfile(
      connectionId: UuidValue.fromString(json['connection_id']),
      userId: UuidValue.fromString(json['user_id']),
      otherUserId: UuidValue.fromString(json['other_user_id']),
      createdAt: DateTime.parse(json['created_at']),
      userEmail: json['user_email'] ?? '',
      userDisplayId: json['user_display_id'] ?? '',
      userFullName: json['user_full_name'] ?? '',
      userWebsite: json['user_website'] ?? '',
      otherUserEmail: json['other_user_email'] ?? '',
      otherUserDisplayId: json['other_user_display_id'] ?? '',
      otherUserFullName: json['other_user_full_name'] ?? '',
      otherUserWebsite: json['other_user_website'] ?? '',
    );
  }
}
