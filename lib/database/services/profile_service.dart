import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sollylabs_discover/database/models/profile.dart';
import 'package:sollylabs_discover/global/globals.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  Future<List<Profile>> getAllProfiles() async {
    final response = await globals.supabaseClient.from('profiles').select();

    PostgrestList testResponse = response;
    for (var i = 0; i < testResponse.length; i++) {
      print('Test Response: ${testResponse[i]}\n\n\n\n');
    }

    if (response.isNotEmpty) {
      return (response as List).map((data) => Profile.fromJson(data)).toList();
    } else {
      return [];
    }
  }

  Future<String?> uploadAvatar(String userId, File imageFile) async {
    try {
      final fileExt = path.extension(imageFile.path);
      final fileName = 'avatars/$userId/avatar$fileExt';

      // Upload the file and get the response
      final storageResponse = await globals.supabaseClient.storage
          .from('avatars') // Replace 'avatars' with your bucket name
          .upload(
            fileName, // No need for duplicate 'avatars' here
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get the public URL of the uploaded file
      final String publicUrl = globals.supabaseClient.storage.from('avatars').getPublicUrl(fileName); // No need for duplicate 'avatars' here

      return publicUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      rethrow;
    }
  }

  Future<void> deleteAvatar(String userId) async {
    try {
      final pathToDelete = 'avatars/$userId/';

      // List all files within the user's avatar directory
      final List<FileObject> files = await globals.supabaseClient.storage.from('avatars').list(path: pathToDelete);

      // Create a list of file paths to delete (full path within the bucket)
      final List<String> filesToDelete = files.map((file) => '$pathToDelete${file.name}').toList();
      print("files: $files");

      print("files to delete: $filesToDelete\n\n\n\n\n");

      // Delete the files from storage
      if (filesToDelete.isNotEmpty) {
        await globals.supabaseClient.storage.from('avatars').remove(filesToDelete);
      }
    } catch (e) {
      print('Error deleting avatar: $e');
      rethrow;
    }
  }

  Future<Profile?> getProfile() async {
    final user = globals.supabaseClient.auth.currentUser;
    if (user == null) {
      return null; // Or handle the case where there is no logged-in user
    }

    try {
      final response = await globals.supabaseClient.from('profiles').select().eq('id', user.id).maybeSingle();

      if (response != null) {
        return Profile.fromJson(response);
      } else {
        return null; // Handle the case where the user's profile does not exist
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(Profile updatedProfile) async {
    try {
      await globals.supabaseClient.from('profiles').update(updatedProfile.toJson()).eq('id', updatedProfile.id.uuid);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<bool> isDisplayIdUnique(String displayId, String currentUserId) async {
    try {
      final response = await globals.supabaseClient.from('profiles').select('id').eq('display_id', displayId).neq('id', currentUserId);

      // If the response is empty, it means no other user has this display_id
      return response.isEmpty;
    } catch (e) {
      print('Error checking display_id uniqueness: $e');
      rethrow;
    }
  }

  Future<Profile?> searchUserByEmail(String email) async {
    try {
      final response = await globals.supabaseClient.from('profiles').select().eq('email', email).maybeSingle();

      if (response != null) {
        return Profile.fromJson(response);
      } else {
        return null;
      }
    } catch (e) {
      print('Error searching user by email: $e');
      rethrow;
    }
  }

  Future<String> getUserIdFromEmail(String email) async {
    try {
      final List<dynamic> response = await globals.supabaseClient
          .from('profiles')
          .select('id')
          .eq('email', email) // Assuming 'email' is a column in your 'profiles' table
          .limit(1); // Limit to one result, assuming emails are unique

      if (response.isNotEmpty) {
        final userId = response[0]['id'];
        return userId;
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error fetching user ID: $e');
      rethrow;
    }
  }

  Future<Profile?> getUserProfileById(String userId) async {
    try {
      final response = await globals.supabaseClient.from('profiles').select().eq('id', userId).maybeSingle(); // Use maybeSingle instead of single

      if (response != null) {
        return Profile.fromJson(response);
      } else {
        print('No user found with ID: $userId');
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow;
    }
  }
}
