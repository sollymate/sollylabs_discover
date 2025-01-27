import 'package:sollylabs_discover/database/models/connection.dart';
import 'package:sollylabs_discover/global/globals.dart';
import 'package:uuid/uuid.dart';

class ConnectionService {
  Future<List<Connection>> getConnections(String userId) async {
    final response = await globals.supabaseClient.from('connections').select().or('user1_id.eq.$userId,user2_id.eq.$userId');

    List<Connection> connections = [];
    for (final connection in response) {
      connections.add(Connection.fromJson(connection));
    }
    return connections;
  }

  Future<Connection> createConnection(String user1Id, String user2Id) async {
    final connection = Connection(
      id: UuidValue.fromString(const Uuid().v4()),
      user1Id: UuidValue.fromString(user1Id),
      user2Id: UuidValue.fromString(user2Id),
      createdAt: DateTime.now(),
    );

    final response = await globals.supabaseClient.from('connections').insert(connection.toJson()).select();

    return Connection.fromJson(response[0]);
  }

// Add other methods for managing connections as needed, like deleting or updating connections
}
