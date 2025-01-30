import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sollylabs_discover/database/models/profile.dart';
import 'package:sollylabs_discover/global/globals.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  Future<List<Profile>> getAllProfiles({String? searchQuery, int? limit, int offset = 0}) async {
    var query = globals.supabaseClient.from('profiles').select('id, email, display_id, full_name, avatar_url, updated_at');

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('email.ilike.%$searchQuery%,display_id.ilike.%$searchQuery%,website.ilike.%$searchQuery%'); // ✅ Filter at DB level
    }

    final response = limit != null
        ? await query.range(offset, offset + limit - 1) // ✅ Use correct offset for pagination
        : await query;

    return response.isNotEmpty ? response.map<Profile>((data) => Profile.fromJson(data)).toList() : [];
  }

  /// ✅ **Upload User Avatar**
  Future<String?> uploadAvatar(String userId, File imageFile) async {
    try {
      final fileExt = path.extension(imageFile.path);
      final fileName = 'avatars/$userId/avatar$fileExt';

      await globals.supabaseClient.storage.from('avatars').upload(fileName, imageFile, fileOptions: const FileOptions(cacheControl: '3600', upsert: true));

      return globals.supabaseClient.storage.from('avatars').getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      rethrow;
    }
  }

  /// ✅ **Delete User Avatar**
  Future<void> deleteAvatar(String userId) async {
    try {
      final pathToDelete = 'avatars/$userId/';
      final files = await globals.supabaseClient.storage.from('avatars').list(path: pathToDelete);
      final filesToDelete = files.map((file) => '$pathToDelete${file.name}').toList();

      if (filesToDelete.isNotEmpty) {
        await globals.supabaseClient.storage.from('avatars').remove(filesToDelete);
      }
    } catch (e) {
      debugPrint('Error deleting avatar: $e');
      rethrow;
    }
  }

  /// ✅ **Get Current User Profile**
  Future<Profile?> getProfile() async {
    final user = globals.supabaseClient.auth.currentUser;
    if (user == null) return null;

    final response = await globals.supabaseClient.from('profiles').select().eq('id', user.id).maybeSingle();
    return response != null ? Profile.fromJson(response) : null;
  }

  /// ✅ **Update Profile**
  Future<void> updateProfile(Profile updatedProfile) async {
    try {
      await globals.supabaseClient.from('profiles').update(updatedProfile.toJson()).eq('id', updatedProfile.id.uuid);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  /// ✅ **Check if Display ID is Unique**
  Future<bool> isDisplayIdUnique(String displayId, String currentUserId) async {
    final response = await globals.supabaseClient.from('profiles').select('id').eq('display_id', displayId).neq('id', currentUserId);
    return response.isEmpty;
  }
}

/// ✅ **Get Profile by Email**
// Future<Profile?> searchUserByEmail(String email) async {
//   final response = await globals.supabaseClient.from('profiles').select().eq('email', email).maybeSingle();
//   return response != null ? Profile.fromJson(response) : null;
// }

/// ✅ **Get User ID from Email**
// Future<String> getUserIdFromEmail(String email) async {
//   final response = await globals.supabaseClient.from('profiles').select('id').eq('email', email).limit(1);
//
//   if (response.isNotEmpty) {
//     return response[0]['id'];
//   } else {
//     throw Exception('User not found');
//   }
// }
/// ✅ **Get User Profile by ID**
// Future<Profile?> getUserProfileById(String userId) async {
//   final response = await globals.supabaseClient.from('profiles').select().eq('id', userId).maybeSingle();
//   return response != null ? Profile.fromJson(response) : null;
// }
