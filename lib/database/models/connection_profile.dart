import 'package:uuid/uuid.dart';

class ConnectionProfile {
  final UuidValue connectionId;
  final DateTime createdAt;
  final UuidValue userId;
  final String userEmail;
  final String userDisplayId;
  final String userFullName;
  final String userWebsite;
  final UuidValue otherUserId;
  final String otherUserEmail;
  final String otherUserDisplayId;
  final String otherUserFullName;
  final String otherUserWebsite;
  final bool isBlocked;

  ConnectionProfile({
    required this.connectionId,
    required this.createdAt,
    required this.userId,
    required this.userEmail,
    required this.userDisplayId,
    required this.userFullName,
    required this.userWebsite,
    required this.otherUserId,
    required this.otherUserEmail,
    required this.otherUserDisplayId,
    required this.otherUserFullName,
    required this.otherUserWebsite,
    required this.isBlocked,
  });

  factory ConnectionProfile.fromJson(Map<String, dynamic> json) {
    return ConnectionProfile(
      connectionId: UuidValue.fromString(json['connection_id']),
      createdAt: DateTime.parse(json['created_at']),
      userId: UuidValue.fromString(json['user_id']),
      userEmail: json['user_email'] ?? 'No Email', // ✅ Prevents null errors
      userDisplayId: json['user_display_id'] ?? 'Unknown',
      userFullName: json['user_full_name'] ?? 'No Name',
      userWebsite: json['user_website'] ?? '',
      otherUserId: UuidValue.fromString(json['other_user_id']),
      otherUserEmail: json['other_user_email'] ?? 'No Email',
      otherUserDisplayId: json['other_user_display_id'] ?? 'Unknown',
      otherUserFullName: json['other_user_full_name'] ?? 'No Name',
      otherUserWebsite: json['other_user_website'] ?? '',
      isBlocked: json['is_blocked'] ?? false,
    );
  }
}

// import 'package:uuid/uuid.dart';
//
// class ConnectionProfile {
//   final UuidValue connectionId;
//   final DateTime createdAt;
//   final UuidValue userId;
//   final String userEmail;
//   final String? userDisplayId;
//   final String? userFullName;
//   final String? userWebsite;
//   final UuidValue otherUserId;
//   final String otherUserEmail;
//   final String? otherUserDisplayId;
//   final String? otherUserFullName;
//   final String? otherUserWebsite;
//   final bool isBlocked;
//
//   ConnectionProfile({
//     required this.connectionId,
//     required this.createdAt,
//     required this.userId,
//     required this.userEmail,
//     this.userDisplayId,
//     this.userFullName,
//     this.userWebsite,
//     required this.otherUserId,
//     required this.otherUserEmail,
//     this.otherUserDisplayId,
//     this.otherUserFullName,
//     this.otherUserWebsite,
//     required this.isBlocked,
//   });
//
//   factory ConnectionProfile.fromJson(Map<String, dynamic> json) {
//     return ConnectionProfile(
//       connectionId: UuidValue.fromString(json['connection_id']),
//       createdAt: DateTime.parse(json['created_at']),
//       userId: UuidValue.fromString(json['user_id']),
//       userEmail: json['user_email'],
//       userDisplayId: json['user_display_id'],
//       userFullName: json['user_full_name'],
//       userWebsite: json['user_website'],
//       otherUserId: UuidValue.fromString(json['other_user_id']),
//       otherUserEmail: json['other_user_email'],
//       otherUserDisplayId: json['other_user_display_id'],
//       otherUserFullName: json['other_user_full_name'],
//       otherUserWebsite: json['other_user_website'],
//       isBlocked: json['is_blocked'] ?? false,
//     );
//   }
// }
//
// // import 'package:uuid/uuid.dart';
// //
// // class ConnectionProfile {
// //   final UuidValue connectionId;
// //   final UuidValue userId;
// //   final UuidValue otherUserId;
// //   final DateTime createdAt;
// //   final String userEmail;
// //   final String userDisplayId;
// //   final String userFullName;
// //   final String userWebsite;
// //   final String otherUserEmail;
// //   final String otherUserDisplayId;
// //   final String otherUserFullName;
// //   final String otherUserWebsite;
// //   final bool isBlocked; // ✅ New field to track blocked status
// //
// //   ConnectionProfile({
// //     required this.connectionId,
// //     required this.userId,
// //     required this.otherUserId,
// //     required this.createdAt,
// //     required this.userEmail,
// //     required this.userDisplayId,
// //     required this.userFullName,
// //     required this.userWebsite,
// //     required this.otherUserEmail,
// //     required this.otherUserDisplayId,
// //     required this.otherUserFullName,
// //     required this.otherUserWebsite,
// //     required this.isBlocked,
// //   });
// //
// //   factory ConnectionProfile.fromJson(Map<String, dynamic> json) {
// //     return ConnectionProfile(
// //       connectionId: UuidValue.fromString(json['connection_id']),
// //       userId: UuidValue.fromString(json['user_id']),
// //       otherUserId: UuidValue.fromString(json['other_user_id']),
// //       createdAt: DateTime.parse(json['created_at']),
// //       userEmail: json['user_email'] ?? '',
// //       userDisplayId: json['user_display_id'] ?? '',
// //       userFullName: json['user_full_name'] ?? '',
// //       userWebsite: json['user_website'] ?? '',
// //       otherUserEmail: json['other_user_email'] ?? '',
// //       otherUserDisplayId: json['other_user_display_id'] ?? '',
// //       otherUserFullName: json['other_user_full_name'] ?? '',
// //       otherUserWebsite: json['other_user_website'] ?? '',
// //       isBlocked: json['is_blocked'] ?? false, // ✅ Default to false if null
// //     );
// //   }
// // }
// //
// // // import 'package:uuid/uuid.dart';
// // //
// // // class ConnectionProfile {
// // //   final UuidValue connectionId;
// // //   final UuidValue userId;
// // //   final UuidValue otherUserId;
// // //   final DateTime createdAt;
// // //   final String? otherUserEmail;
// // //   final String? otherUserDisplayId;
// // //   final String? otherUserFullName;
// // //   final String? otherUserWebsite;
// // //   final bool isBlocked; // ✅ New field to track blocked status
// // //
// // //   ConnectionProfile({
// // //     required this.connectionId,
// // //     required this.userId,
// // //     required this.otherUserId,
// // //     required this.createdAt,
// // //     this.otherUserEmail,
// // //     this.otherUserDisplayId,
// // //     this.otherUserFullName,
// // //     this.otherUserWebsite,
// // //     required this.isBlocked, // ✅ Now required in constructor
// // //   });
// // //
// // //   factory ConnectionProfile.fromJson(Map<String, dynamic> json) {
// // //     return ConnectionProfile(
// // //       connectionId: UuidValue.fromString(json['connection_id']),
// // //       userId: UuidValue.fromString(json['user_id']),
// // //       otherUserId: UuidValue.fromString(json['other_user_id']),
// // //       createdAt: DateTime.parse(json['created_at']),
// // //       otherUserEmail: json['other_user_email'] ?? '',
// // //       otherUserDisplayId: json['other_user_display_id'] ?? '',
// // //       otherUserFullName: json['other_user_full_name'] ?? '',
// // //       otherUserWebsite: json['other_user_website'] ?? '',
// // //       isBlocked: json['is_blocked'] ?? false, // ✅ Ensure default value if null
// // //     );
// // //   }
// // // }
// // //
// // // // import 'package:uuid/uuid.dart';
// // // //
// // // // class ConnectionProfile {
// // // //   final UuidValue connectionId;
// // // //   final UuidValue userId; // ✅ This replaces user1Id and user2Id
// // // //   final UuidValue otherUserId;
// // // //   final DateTime createdAt;
// // // //   final String userEmail;
// // // //   final String userDisplayId;
// // // //   final String userFullName;
// // // //   final String userWebsite;
// // // //   final String otherUserEmail;
// // // //   final String otherUserDisplayId;
// // // //   final String otherUserFullName;
// // // //   final String otherUserWebsite;
// // // //
// // // //   ConnectionProfile({
// // // //     required this.connectionId,
// // // //     required this.userId,
// // // //     required this.otherUserId,
// // // //     required this.createdAt,
// // // //     required this.userEmail,
// // // //     required this.userDisplayId,
// // // //     required this.userFullName,
// // // //     required this.userWebsite,
// // // //     required this.otherUserEmail,
// // // //     required this.otherUserDisplayId,
// // // //     required this.otherUserFullName,
// // // //     required this.otherUserWebsite,
// // // //   });
// // // //
// // // //   factory ConnectionProfile.fromJson(Map<String, dynamic> json) {
// // // //     return ConnectionProfile(
// // // //       connectionId: UuidValue.fromString(json['connection_id']),
// // // //       userId: UuidValue.fromString(json['user_id']),
// // // //       otherUserId: UuidValue.fromString(json['other_user_id']),
// // // //       createdAt: DateTime.parse(json['created_at']),
// // // //       userEmail: json['user_email'] ?? '',
// // // //       userDisplayId: json['user_display_id'] ?? '',
// // // //       userFullName: json['user_full_name'] ?? '',
// // // //       userWebsite: json['user_website'] ?? '',
// // // //       otherUserEmail: json['other_user_email'] ?? '',
// // // //       otherUserDisplayId: json['other_user_display_id'] ?? '',
// // // //       otherUserFullName: json['other_user_full_name'] ?? '',
// // // //       otherUserWebsite: json['other_user_website'] ?? '',
// // // //     );
// // // //   }
// // // // }
