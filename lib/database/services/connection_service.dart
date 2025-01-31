import 'package:flutter/material.dart';
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

  // Future<void> blockUser(String blockerId, String blockedId) async {
  //   final existingBlock = await globals.supabaseClient.from('blocked_users').select().eq('blocker_id', blockerId).eq('blocked_id', blockedId).maybeSingle();
  //
  //   if (existingBlock != null) {
  //     throw Exception('User is already blocked.');
  //   }
  //
  //   final response = await globals.supabaseClient.from('blocked_users').insert({
  //     'blocker_id': blockerId,
  //     'blocked_id': blockedId,
  //     'created_at': DateTime.now().toIso8601String(),
  //   });
  //
  //   if (response.error != null) {
  //     throw Exception('Failed to block user: ${response.error!.message}');
  //   }
  // }

  Future<void> blockUser(String blockerId, String blockedId) async {
    debugPrint('🔹 Checking if user $blockedId is already blocked by $blockerId');

    final existingBlock = await globals.supabaseClient.from('blocked_users').select().eq('blocker_id', blockerId).eq('blocked_id', blockedId).maybeSingle();

    if (existingBlock != null) {
      debugPrint('⚠️ User $blockedId is already blocked by $blockerId.');
      throw Exception('User is already blocked.');
    }

    final response = await globals.supabaseClient.from('blocked_users').insert({
      'blocker_id': blockerId,
      'blocked_id': blockedId,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (response.error != null) {
      debugPrint('❌ Error blocking user: ${response.error!.message}');
      throw Exception('Failed to block user: ${response.error!.message}');
    }

    debugPrint('✅ User $blockedId successfully blocked by $blockerId');
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

  // Future<bool> removeConnection(String connectionId) async {
  //   final response = await globals.supabaseClient.from('connections').delete().eq('id', connectionId).select();
  //
  //   return response.isNotEmpty; // Returns `true` if deletion was successful
  // }
  Future<void> removeConnection(String userId, String otherUserId) async {
    debugPrint('🔹 Checking if connection exists between $userId and $otherUserId');

    final existingConnection = await globals.supabaseClient.from('connections').select().or('user1_id.eq.$userId,user2_id.eq.$userId').or('user1_id.eq.$otherUserId,user2_id.eq.$otherUserId').maybeSingle();

    if (existingConnection == null) {
      debugPrint('⚠️ No connection exists between $userId and $otherUserId.');
      throw Exception('Connection does not exist.');
    }

    final response = await globals.supabaseClient.from('connections').delete().or('user1_id.eq.$userId,user2_id.eq.$userId').or('user1_id.eq.$otherUserId,user2_id.eq.$otherUserId');

    if (response.error != null) {
      debugPrint('❌ Error removing connection: ${response.error!.message}');
      throw Exception('Failed to remove connection: ${response.error!.message}');
    }

    debugPrint('✅ Connection successfully removed between $userId and $otherUserId');
  }

  Future<void> unblockUser(String blockerId, String blockedId) async {
    debugPrint('🔹 Attempting to unblock user: $blockedId');

    final existingBlock = await globals.supabaseClient.from('blocked_users').select().eq('blocker_id', blockerId).eq('blocked_id', blockedId).maybeSingle();

    if (existingBlock == null) {
      debugPrint('⚠️ User $blockedId is not blocked by $blockerId.');
      throw Exception('User is not blocked.');
    }

    final response = await globals.supabaseClient.from('blocked_users').delete().eq('blocker_id', blockerId).eq('blocked_id', blockedId);

    if (response.error != null) {
      debugPrint('❌ Error unblocking user: ${response.error!.message}');
      throw Exception('Failed to unblock user: ${response.error!.message}');
    }

    debugPrint('✅ Successfully unblocked user: $blockedId');
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
