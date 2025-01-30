class ConnectionProfile {
  final String id;
  final String email;
  final String displayId;
  final String fullName;
  final String website;

  ConnectionProfile({
    required this.id,
    required this.email,
    required this.displayId,
    required this.fullName,
    required this.website,
  });

  factory ConnectionProfile.fromJson(Map<String, dynamic> json) {
    return ConnectionProfile(
      id: json['connection_id'],
      email: json['other_user_email'] ?? 'No Email',
      displayId: json['other_user_display_id'] ?? 'Unknown',
      fullName: json['other_user_full_name'] ?? 'No Name',
      website: json['other_user_website'] ?? 'No Website',
    );
  }
}
