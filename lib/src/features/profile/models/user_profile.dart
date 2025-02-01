import 'package:uuid/uuid.dart';

class UserProfile {
  final UuidValue id;
  final DateTime? updatedAt;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? website;
  final String? displayId;
  final String? email;
  final bool isConnected; // ✅ New field

  UserProfile({
    required this.id,
    this.updatedAt,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.website,
    this.displayId,
    this.email,
    this.isConnected = false, // ✅ Default to false
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: UuidValue.fromString(json['id']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      website: json['website'],
      displayId: json['display_id'],
      email: json['email'],
      isConnected: json['is_connected'] ?? false, // ✅ Map from DB
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.uuid,
      'updated_at': updatedAt?.toIso8601String(),
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'website': website,
      'display_id': displayId,
      'email': email,
      'is_connected': isConnected, // ✅ Include in JSON
    };
  }

  // ✅ **Added copyWith Method**
  UserProfile copyWith({
    UuidValue? id,
    DateTime? updatedAt,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? website,
    String? displayId,
    String? email,
    bool? isConnected,
  }) {
    return UserProfile(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      website: website ?? this.website,
      displayId: displayId ?? this.displayId,
      email: email ?? this.email,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
