import 'package:uuid/uuid.dart';

class Profile {
  final UuidValue id; // Primary key, which is also the user_id in auth.users
  final DateTime? updatedAt;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? website;
  final String? displayId;
  final String? email;

  Profile({
    required this.id,
    this.updatedAt,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.website,
    this.displayId,
    this.email,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: UuidValue.fromString(json['id']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      website: json['website'],
      displayId: json['display_id'],
      email: json['email'],
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
    };
  }

  Profile copyWith({
    UuidValue? id,
    DateTime? updatedAt,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? website,
    String? displayId,
    String? email,
  }) {
    return Profile(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      website: website ?? this.website,
      displayId: displayId ?? this.displayId,
      email: email ?? this.email,
    );
  }
}

// import 'package:uuid/uuid.dart';
//
// class Profile {
//   final UuidValue id;
//   final DateTime? updatedAt;
//   final String? username;
//   final String? fullName;
//   final String? avatarUrl;
//   final String? website;
//   final String? displayId;
//   final String? email;
//
//   Profile({
//     required this.id,
//     this.updatedAt,
//     this.username,
//     this.fullName,
//     this.avatarUrl,
//     this.website,
//     this.displayId,
//     this.email,
//   });
//
//   factory Profile.fromJson(Map<String, dynamic> json) {
//     return Profile(
//       id: UuidValue.fromString(json['id']),
//       updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
//       username: json['username'],
//       fullName: json['full_name'],
//       avatarUrl: json['avatar_url'],
//       website: json['website'],
//       displayId: json['display_id'],
//       email: json['email'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id.uuid,
//       'updated_at': updatedAt?.toIso8601String(),
//       'username': username,
//       'full_name': fullName,
//       'avatar_url': avatarUrl,
//       'website': website,
//       'display_id': displayId,
//       'email': email,
//     };
//   }
// }
