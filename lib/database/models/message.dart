import 'package:uuid/uuid.dart';

class Message {
  final UuidValue id;
  final UuidValue connectionId;
  final UuidValue senderId;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Message({
    required this.id,
    required this.connectionId,
    required this.senderId,
    this.message,
    this.createdAt,
    this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: UuidValue.fromString(json['id']),
      connectionId: UuidValue.fromString(json['connection_id']),
      senderId: UuidValue.fromString(json['sender_id']),
      message: json['message'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.uuid,
      'connection_id': connectionId.uuid,
      'sender_id': senderId.uuid,
      'message': message,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
