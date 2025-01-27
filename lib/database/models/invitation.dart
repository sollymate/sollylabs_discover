import 'package:uuid/uuid.dart';

enum InvitationStatus {
  pending,
  accepted,
  declined,
}

class Invitation {
  final UuidValue id;
  final UuidValue projectId;
  final String senderId;
  final String recipientEmail;
  final String role;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Invitation({required this.id, required this.projectId, required this.senderId, required this.recipientEmail, required this.role, required this.status, required this.createdAt, this.updatedAt});

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: UuidValue.fromString(json['id']),
      projectId: UuidValue.fromString(json['project_id']),
      senderId: json['sender_id'],
      recipientEmail: json['recipient_email'],
      role: json['role'],
      status: InvitationStatus.values.firstWhere((e) => e.toString().split('.').last == json['status']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.uuid,
      'project_id': projectId.uuid,
      'sender_id': senderId,
      'recipient_email': recipientEmail,
      'role': role,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
