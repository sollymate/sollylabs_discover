import 'package:uuid/uuid.dart';

class NetworkModel {
  final UuidValue networkId;
  final UuidValue userId;
  final UuidValue otherUserId;
  final String otherUserEmail;
  final String otherUserDisplayId;
  final String otherUserFullName;
  final String otherUserWebsite;
  final bool isBlocked;

  NetworkModel({
    required this.networkId,
    required this.userId,
    required this.otherUserId,
    required this.otherUserEmail,
    required this.otherUserDisplayId,
    required this.otherUserFullName,
    required this.otherUserWebsite,
    required this.isBlocked,
  });

  factory NetworkModel.fromJson(Map<String, dynamic> json) {
    return NetworkModel(
      networkId: UuidValue.fromString(json['connection_id']),
      userId: UuidValue.fromString(json['user_id']),
      otherUserId: UuidValue.fromString(json['other_user_id']),
      otherUserEmail: json['other_user_email'] ?? 'No Email',
      otherUserDisplayId: json['other_user_display_id'] ?? 'Unknown',
      otherUserFullName: json['other_user_full_name'] ?? 'No Name',
      otherUserWebsite: json['other_user_website'] ?? '',
      isBlocked: json['is_blocked'] ?? false,
    );
  }
}
