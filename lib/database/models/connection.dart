class Connection {
  final String id;
  final String user1Id;
  final String user2Id;
  final String userEmail; // Email of the other user in the connection

  Connection({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.userEmail,
  });

  factory Connection.fromJson(Map<String, dynamic> json, String currentUserId) {
    return Connection(
      id: json['id'],
      user1Id: json['user1_id'],
      user2Id: json['user2_id'],
      userEmail: json['user1_id'] == currentUserId ? json['user2']['email'] : json['user1']['email'],
    );
  }
}

// import 'package:uuid/uuid.dart';
//
// class Connection {
//   final UuidValue id;
//   final UuidValue user1Id;
//   final UuidValue user2Id;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//
//   Connection({
//     required this.id,
//     required this.user1Id,
//     required this.user2Id,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   factory Connection.fromJson(Map<String, dynamic> json) {
//     return Connection(
//       id: UuidValue.fromString(json['id']),
//       user1Id: UuidValue.fromString(json['user1_id']),
//       user2Id: UuidValue.fromString(json['user2_id']),
//       createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
//       updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id.uuid,
//       'user1_id': user1Id.uuid,
//       'user2_id': user2Id.uuid,
//       'created_at': createdAt?.toIso8601String(),
//       'updated_at': updatedAt?.toIso8601String(),
//     };
//   }
// }
