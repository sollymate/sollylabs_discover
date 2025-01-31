import 'package:uuid/uuid.dart';

class CommunityProfile {
  final UuidValue userId;
  final String? email;
  final String? displayId;
  final String? fullName;
  final String? avatarUrl;
  final String? website;
  final DateTime? updatedAt;
  final bool isConnected;
  final bool isBlocked;
  final bool isBlockedBy;

  CommunityProfile({
    required this.userId,
    this.email,
    this.displayId,
    this.fullName,
    this.avatarUrl,
    this.website,
    this.updatedAt,
    required this.isConnected,
    required this.isBlocked,
    required this.isBlockedBy,
  });

  factory CommunityProfile.fromJson(Map<String, dynamic> json) {
    return CommunityProfile(
      userId: UuidValue.fromString(json['user_id']),
      email: json['email'],
      displayId: json['display_id'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      website: json['website'],
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isConnected: json['is_connected'] ?? false,
      isBlocked: json['is_blocked'] ?? false,
      isBlockedBy: json['is_blocked_by'] ?? false,
    );
  }
}
