import 'package:sollylabs_discover/database/models/connection_profile.dart';
import 'package:sollylabs_discover/global/globals.dart';

class ConnectionService {
  Future<List<ConnectionProfile>> getConnections(String userId, {String? searchQuery}) async {
    var query = globals.supabaseClient.from('connection_profiles').select('connection_id, other_user_email, other_user_display_id, other_user_full_name, other_user_website').or('user1_id.eq.$userId,user2_id.eq.$userId');

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('other_user_email.ilike.%$searchQuery%, other_user_display_id.ilike.%$searchQuery%, other_user_full_name.ilike.%$searchQuery%, other_user_website.ilike.%$searchQuery%');
    }

    final response = await query;

    return response.map<ConnectionProfile>((data) => ConnectionProfile.fromJson(data)).toList();
  }

  Future<void> addConnection(String userId, String targetUserId) async {
    final orderedUser1 = userId.compareTo(targetUserId) < 0 ? userId : targetUserId;
    final orderedUser2 = userId.compareTo(targetUserId) < 0 ? targetUserId : userId;

    final response = await globals.supabaseClient.from('connections').insert({
      'user1_id': orderedUser1,
      'user2_id': orderedUser2,
    }).select();

    if (response.isEmpty) {
      throw Exception('Failed to send connection request');
    }
  }
}

// import 'package:sollylabs_discover/database/models/connection.dart';
// import 'package:sollylabs_discover/global/globals.dart';
//
// class ConnectionService {
//   Future<List<Connection>> getConnections(String userId, {String? searchQuery}) async {
//     var query = globals.supabaseClient.from('connections').select('id, user1_id, user2_id, user1:profiles!connections_user1_id_fkey(email), user2:profiles!connections_user2_id_fkey(email)').or('user1_id.eq.$userId,user2_id.eq.$userId');
//
//     if (searchQuery != null && searchQuery.isNotEmpty) {
//       // Add an 'or' condition to filter by email in either user1 or user2
//       query = query.or('user1.email.ilike.%$searchQuery%,user2.email.ilike.%$searchQuery%');
//     }
//
//     final response = await query;
//
//     return response
//         .map<Connection>((data) => Connection(
//               id: data['id'],
//               user1Id: data['user1_id'],
//               user2Id: data['user2_id'],
//               userEmail: data['user1_id'] == userId ? data['user2']['email'] : data['user1']['email'],
//             ))
//         .toList();
//   }
//
//   Future<void> addConnection(String userId, String targetUserId) async {
//     final orderedUser1 = userId.compareTo(targetUserId) < 0 ? userId : targetUserId;
//     final orderedUser2 = userId.compareTo(targetUserId) < 0 ? targetUserId : userId;
//
//     final response = await globals.supabaseClient.from('connections').insert({
//       'user1_id': orderedUser1,
//       'user2_id': orderedUser2,
//     }).select();
//
//     if (response.isEmpty) {
//       throw Exception('Failed to send connection request');
//     }
//   }
// }
