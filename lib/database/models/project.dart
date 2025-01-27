import 'package:uuid/uuid.dart';

class Project {
  final UuidValue id;
  final String projectName;
  final String? projectInfo;
  final String? shortcodeLink;
  final int? projectSequenceNumber;
  final UuidValue? createdBy;
  final DateTime createdAt;
  final UuidValue? updatedBy;
  final DateTime? updatedAt;
  final UuidValue? ownerId;

  Project({
    required this.id,
    required this.projectName,
    this.projectInfo,
    this.shortcodeLink,
    this.projectSequenceNumber,
    this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.ownerId,
  });

  Project copyWith({
    UuidValue? id,
    String? projectName,
    String? projectInfo,
    String? shortcodeLink,
    int? projectSequenceNumber,
    UuidValue? createdBy,
    DateTime? createdAt,
    UuidValue? updatedBy,
    DateTime? updatedAt,
    UuidValue? ownerId,
  }) {
    return Project(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      projectInfo: projectInfo ?? this.projectInfo,
      shortcodeLink: shortcodeLink ?? this.shortcodeLink,
      projectSequenceNumber: projectSequenceNumber ?? this.projectSequenceNumber,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: UuidValue.fromString(json['id']),
      projectName: json['project_name'],
      projectInfo: json['project_info'],
      shortcodeLink: json['shortcode_link'],
      projectSequenceNumber: json['project_sequence_number'],
      createdBy: json['created_by'] != null ? UuidValue.fromString(json['created_by']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedBy: json['updated_by'] != null ? UuidValue.fromString(json['updated_by']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      ownerId: json['owner_id'] != null ? UuidValue.fromString(json['owner_id']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.uuid,
      'project_name': projectName,
      'project_info': projectInfo,
      'shortcode_link': shortcodeLink,
      'project_sequence_number': projectSequenceNumber,
      'created_by': createdBy?.uuid,
      'created_at': createdAt.toIso8601String(),
      'updated_by': updatedBy?.uuid,
      'updated_at': updatedAt?.toIso8601String(),
      'owner_id': ownerId?.uuid,
    };
  }
}
