import 'package:sollylabs_discover/database/models/connection_profile.dart';
import 'package:sollylabs_discover/global/globals.dart';

class ConnectionService {
  Future<List<ConnectionProfile>> getConnections(String userId, {String? searchQuery}) async {
    var query = globals.supabaseClient.from('connection_profiles').select();

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('user_email.ilike.%$searchQuery%,other_user_email.ilike.%$searchQuery%');
    }

    final response = await query;

    return response.map<ConnectionProfile>((data) => ConnectionProfile.fromJson(data)).toList();
  }

  Future<void> blockConnection(String connectionId) async {
    final response = await globals.supabaseClient
        .from('connections')
        .update({'is_blocked': true}) // ✅ Correct column name
        .eq('id', connectionId)
        .select();

    if (response.isEmpty) {
      throw Exception('Failed to block user');
    }
  }

  Future<void> unblockConnection(String connectionId) async {
    final response = await globals.supabaseClient
        .from('connections')
        .update({'is_blocked': false}) // ✅ Correct column name
        .eq('id', connectionId)
        .select();

    if (response.isEmpty) {
      throw Exception('Failed to unblock user');
    }
  }

  // Future<void> blockConnection(String connectionId) async {
  //   final response = await globals.supabaseClient.from('connections').update({'blocked': true}).eq('id', connectionId).select();
  //
  //   if (response.isEmpty) {
  //     throw Exception('Failed to block user');
  //   }
  // }
  //
  // Future<void> unblockConnection(String connectionId) async {
  //   final response = await globals.supabaseClient.from('connections').update({'blocked': false}).eq('id', connectionId).select();
  //
  //   if (response.isEmpty) {
  //     throw Exception('Failed to unblock user');
  //   }
  // }

  Future<bool> removeConnection(String connectionId) async {
    final response = await globals.supabaseClient.from('connections').delete().eq('id', connectionId).select();

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
