import 'package:sollylabs_discover/src/core/config/supabase_client.dart';
import 'package:sollylabs_discover/src/features/network/models/network_model.dart';

class NetworkService {
  Future<void> addConnection(String userId, String targetUserId) async {
    final orderedUser1 = userId.compareTo(targetUserId) < 0 ? userId : targetUserId;
    final orderedUser2 = userId.compareTo(targetUserId) < 0 ? targetUserId : userId;

    final response = await supabase.from('connections').insert({
      'user1_id': orderedUser1,
      'user2_id': orderedUser2,
    }).select();

    if (response.isEmpty) {
      throw Exception('Failed to send connection request');
    }
  }

  /// ✅ Fetch active network connections (non-blocked)
  Future<List<NetworkModel>> getNetwork({required String currentUserId}) async {
    try {
      final response = await supabase.from('network').select().eq('user_id', currentUserId); // ✅ Filter by authenticated user

      return response.map<NetworkModel>((data) => NetworkModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Error fetching network connections: $e');
    }
  }

  Future<void> removeUser(String userId, String otherUserId) async {
    try {
      final existingConnection = await supabase.from('connections').select().or('user1_id.eq.$userId,user2_id.eq.$userId').or('user1_id.eq.$otherUserId,user2_id.eq.$otherUserId').maybeSingle();

      if (existingConnection == null) {
        throw Exception('Connection does not exist.');
      }

      final response = await supabase.from('connections').delete().or('user1_id.eq.$userId,user2_id.eq.$userId').or('user1_id.eq.$otherUserId,user2_id.eq.$otherUserId').select();

      if (response.isEmpty) {
        throw Exception('Failed to remove connection');
      }
    } catch (e) {
      throw Exception('Error removing user: $e');
    }
  }

  /// ✅ Block a user
  Future<void> blockUser(String blockerId, String blockedId) async {
    final existingBlock = await supabase.from('blocked_users').select().eq('blocker_id', blockerId).eq('blocked_id', blockedId).maybeSingle();

    if (existingBlock != null) {
      throw Exception('User is already blocked.');
    }

    final response = await supabase.from('blocked_users').insert({
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
    final existingBlock = await supabase.from('blocked_users').select().eq('blocker_id', blockerId).eq('blocked_id', blockedId).maybeSingle();

    if (existingBlock == null) {
      throw Exception('User is not blocked.');
    }

    final response = await supabase.from('blocked_users').delete().eq('blocker_id', blockerId).eq('blocked_id', blockedId).select();

    if (response.isEmpty) {
      throw Exception('Failed to unblock user: $response');
    }
  }
}

// Future<List<CommunityProfile>> getCommunityProfiles({
//   required String currentUserId,
//   String? searchQuery,
//   int? limit,
//   int offset = 0,
// }) async {
//   var query = globals.supabaseClient.from('community').select('user_id, email, display_id, full_name, avatar_url, website, updated_at, is_connected, is_blocked, is_blocked_by').neq('user_id', currentUserId); // Exclude the current user
//
//   // Apply search if provided (Temporary: ilike-based, FTS will be added later)
//   if (searchQuery != null && searchQuery.isNotEmpty) {
//     query = query.or('email.ilike.%$searchQuery%,display_id.ilike.%$searchQuery%,website.ilike.%$searchQuery%');
//   }
//
//   // Apply pagination if a limit is specified
//   final response = limit != null ? await query.range(offset, offset + limit - 1) : await query;
//
//   return response.map<CommunityProfile>((data) => CommunityProfile.fromJson(data)).toList();
// }
