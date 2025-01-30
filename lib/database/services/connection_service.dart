import 'package:sollylabs_discover/database/models/connection_profile.dart';
import 'package:sollylabs_discover/global/globals.dart';

class ConnectionService {
  Future<List<ConnectionProfile>> getConnections(String userId, {String? searchQuery}) async {
    var query = globals.supabaseClient.from('connection_profiles').select();

    print('Query Connections is: $query\n\n\n');

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('user_email.ilike.%$searchQuery%,other_user_email.ilike.%$searchQuery%,'
          'user_display_id.ilike.%$searchQuery%,other_user_display_id.ilike.%$searchQuery%,'
          'user_full_name.ilike.%$searchQuery%,other_user_full_name.ilike.%$searchQuery%,'
          'user_website.ilike.%$searchQuery%,other_user_website.ilike.%$searchQuery%');
    }

    final response = await query;

    final connectionProfiles = response.map<ConnectionProfile>((data) {
      return ConnectionProfile.fromJson(data);
    }).toList();

    return connectionProfiles;
  }

  Future<bool> removeConnection(String connectionId) async {
    final response = await globals.supabaseClient.from('connections').delete().eq('id', connectionId).select();

    // if (response.isEmpty) {
    //   throw Exception('Failed to remove connection');
    // }

    return response.isNotEmpty; // Returns `true` if deletion was successful
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
