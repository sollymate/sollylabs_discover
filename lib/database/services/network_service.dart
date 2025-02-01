import 'package:sollylabs_discover/database/models/network_model.dart';
import 'package:sollylabs_discover/global/globals.dart';

class NetworkService {
  /// ✅ Fetch active network connections (non-blocked)
  Future<List<NetworkModel>> getNetwork({required String currentUserId}) async {
    try {
      final response = await globals.supabaseClient.from('network').select().eq('user_id', currentUserId); // ✅ Filter by authenticated user

      return response.map<NetworkModel>((data) => NetworkModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Error fetching network connections: $e');
    }
  }

  Future<void> removeUser(String userId, String otherUserId) async {
    try {
      final existingConnection = await globals.supabaseClient.from('connections').select().or('user1_id.eq.$userId,user2_id.eq.$userId').or('user1_id.eq.$otherUserId,user2_id.eq.$otherUserId').maybeSingle();

      if (existingConnection == null) {
        throw Exception('Connection does not exist.');
      }

      final response = await globals.supabaseClient.from('connections').delete().or('user1_id.eq.$userId,user2_id.eq.$userId').or('user1_id.eq.$otherUserId,user2_id.eq.$otherUserId').select();

      if (response.isEmpty) {
        throw Exception('Failed to remove connection');
      }
    } catch (e) {
      throw Exception('Error removing user: $e');
    }
  }

  /// ✅ Block a user
  Future<void> blockUser(String blockerId, String blockedId) async {
    final existingBlock = await globals.supabaseClient.from('blocked_users').select().eq('blocker_id', blockerId).eq('blocked_id', blockedId).maybeSingle();

    if (existingBlock != null) {
      throw Exception('User is already blocked.');
    }

    final response = await globals.supabaseClient.from('blocked_users').insert({
      'blocker_id': blockerId,
      'blocked_id': blockedId,
      'created_at': DateTime.now().toIso8601String(),
    }).select();

    if (response.isEmpty) {
      throw Exception('Failed to block user: $response');
    }
  }

  /// ✅ Unblock a user
  Future<void> unblockUser(String blockerId, String blockedId) async {
    final existingBlock = await globals.supabaseClient.from('blocked_users').select().eq('blocker_id', blockerId).eq('blocked_id', blockedId).maybeSingle();

    if (existingBlock == null) {
      throw Exception('User is not blocked.');
    }

    final response = await globals.supabaseClient.from('blocked_users').delete().eq('blocker_id', blockerId).eq('blocked_id', blockedId).select();

    if (response.isEmpty) {
      throw Exception('Failed to unblock user: $response');
    }
  }
}
