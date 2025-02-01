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
