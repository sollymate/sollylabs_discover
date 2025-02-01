import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sollylabs_discover/src/core/config/supabase_client.dart';
import 'package:sollylabs_discover/src/features/profile/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  Future<List<UserProfile>> getAllProfiles({required String currentUserId, String? searchQuery, int? limit, int offset = 0}) async {
    var query = supabase.from('profiles').select('id, email, display_id, full_name, avatar_url, updated_at');

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('email.ilike.%$searchQuery%,display_id.ilike.%$searchQuery%,website.ilike.%$searchQuery%'); // ✅ Filter at DB level
    }

    final response = limit != null
        ? await query.range(offset, offset + limit - 1) // ✅ Use correct offset for pagination
        : await query;

    return response.isNotEmpty ? response.map<UserProfile>((data) => UserProfile.fromJson(data)).toList() : [];
  }

  /// ✅ **Upload User Avatar**
  Future<String?> uploadAvatar(String userId, File imageFile) async {
    try {
      final fileExt = path.extension(imageFile.path);
      final fileName = 'avatars/$userId/avatar$fileExt';

      await supabase.storage.from('avatars').upload(fileName, imageFile, fileOptions: const FileOptions(cacheControl: '3600', upsert: true));

      return supabase.storage.from('avatars').getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      rethrow;
    }
  }

  /// ✅ **Delete User Avatar**
  Future<void> deleteAvatar(String userId) async {
    try {
      final pathToDelete = 'avatars/$userId/';
      final files = await supabase.storage.from('avatars').list(path: pathToDelete);
      final filesToDelete = files.map((file) => '$pathToDelete${file.name}').toList();

      if (filesToDelete.isNotEmpty) {
        await supabase.storage.from('avatars').remove(filesToDelete);
      }
    } catch (e) {
      debugPrint('Error deleting avatar: $e');
      rethrow;
    }
  }

  /// ✅ **Get Current User Profile**
  Future<UserProfile?> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();
    return response != null ? UserProfile.fromJson(response) : null;
  }

  /// ✅ **Update Profile**
  Future<void> updateProfile(UserProfile updatedProfile) async {
    try {
      await supabase.from('profiles').update(updatedProfile.toJson()).eq('id', updatedProfile.id.uuid);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  /// ✅ **Check if Display ID is Unique**
  Future<bool> isDisplayIdUnique(String displayId, String currentUserId) async {
    final response = await supabase.from('profiles').select('id').eq('display_id', displayId).neq('id', currentUserId);
    return response.isEmpty;
  }
}
