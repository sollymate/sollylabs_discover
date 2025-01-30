import 'dart:io';

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

  // Future<List<Profile>> getAllProfiles({String? searchQuery, int? limit, int offset = 0}) async {
  //   var query = globals.supabaseClient.from('profiles').select('id, email, display_id, full_name, avatar_url, updated_at');
  //
  //   if (searchQuery != null && searchQuery.isNotEmpty) {
  //     query = query.or('email.ilike.%$searchQuery%,display_id.ilike.%$searchQuery%,website.ilike.%$searchQuery%');
  //   }
  //
  //   final response = limit != null
  //       ? await query.range(offset, offset + limit - 1) // ✅ Ensure correct pagination
  //       : await query;
  //
  //   return response.isNotEmpty ? response.map<Profile>((data) => Profile.fromJson(data)).toList() : [];
  // }

  // Future<List<Profile>> getAllProfiles({String? searchQuery, int? limit, int offset = 0}) async {
  //   var query = globals.supabaseClient.from('profiles').select('id, email, display_id, full_name, avatar_url, updated_at');
  //
  //   if (searchQuery != null && searchQuery.isNotEmpty) {
  //     query = query.or('email.ilike.%$searchQuery%,display_id.ilike.%$searchQuery%,website.ilike.%$searchQuery%');
  //   }
  //
  //   final response = limit != null
  //       ? await query.range(offset, offset + limit - 1) // ✅ Use correct offset
  //       : await query;
  //
  //   return response.isNotEmpty ? response.map<Profile>((data) => Profile.fromJson(data)).toList() : [];
  // }

  // Future<List<Profile>> getAllProfiles({String? searchQuery, int? limit}) async {
  //   var query = globals.supabaseClient.from('profiles').select('id, email, display_id, full_name, avatar_url, updated_at');
  //
  //   if (searchQuery != null && searchQuery.isNotEmpty) {
  //     query = query.or('email.ilike.%$searchQuery%,display_id.ilike.%$searchQuery%,website.ilike.%$searchQuery%');
  //   }
  //
  //   // Apply limit during query execution instead of reassigning
  //   final response = limit != null
  //       ? await query.range(0, limit - 1) // ✅ Apply `.range()` only at execution
  //       : await query; // ✅ If no limit, execute normally
  //
  //   if (response.isNotEmpty) {
  //     return response.map<Profile>((data) => Profile.fromJson(data)).toList();
  //   } else {
  //     return [];
  //   }
  // }

  // Future<List<Profile>> getAllProfiles({String? searchQuery, int? limit}) async {
  //   var query = globals.supabaseClient.from('profiles').select('id, email, display_id, full_name, avatar_url, updated_at');
  //
  //   if (searchQuery != null && searchQuery.isNotEmpty) {
  //     query = query.or('email.ilike.%$searchQuery%,display_id.ilike.%$searchQuery%,website.ilike.%$searchQuery%');
  //   }
  //
  //   if (limit != null) {
  //     query = query.range(0, limit - 1); // Apply limit if provided
  //   }
  //
  //   final response = await query;
  //
  //   if (response.isNotEmpty) {
  //     return response.map<Profile>((data) => Profile.fromJson(data)).toList();
  //   } else {
  //     return [];
  //   }
  // }

  /// ✅ **Get all profiles (With optional search)**
  // Future<List<Profile>> getAllProfiles({String? searchQuery}) async {
  //   var query = globals.supabaseClient.from('profiles').select('id, email, display_id, full_name, avatar_url, updated_at');
  //
  //   if (searchQuery != null && searchQuery.isNotEmpty) {
  //     query = query.or('email.ilike.%$searchQuery%,display_id.ilike.%$searchQuery%,website.ilike.%$searchQuery%');
  //   }
  //
  //   final response = await query;
  //
  //   if (response.isNotEmpty) {
  //     return response.map<Profile>((data) => Profile.fromJson(data)).toList();
  //   } else {
  //     return [];
  //   }
  // }

  /// ✅ **Upload User Avatar**
  Future<String?> uploadAvatar(String userId, File imageFile) async {
    try {
      final fileExt = path.extension(imageFile.path);
      final fileName = 'avatars/$userId/avatar$fileExt';

      await globals.supabaseClient.storage.from('avatars').upload(fileName, imageFile, fileOptions: const FileOptions(cacheControl: '3600', upsert: true));

      return globals.supabaseClient.storage.from('avatars').getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading avatar: $e');
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
      print('Error deleting avatar: $e');
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
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  /// ✅ **Check if Display ID is Unique**
  Future<bool> isDisplayIdUnique(String displayId, String currentUserId) async {
    final response = await globals.supabaseClient.from('profiles').select('id').eq('display_id', displayId).neq('id', currentUserId);
    return response.isEmpty;
  }

  /// ✅ **Get Profile by Email**
  Future<Profile?> searchUserByEmail(String email) async {
    final response = await globals.supabaseClient.from('profiles').select().eq('email', email).maybeSingle();
    return response != null ? Profile.fromJson(response) : null;
  }

  /// ✅ **Get User ID from Email**
  Future<String> getUserIdFromEmail(String email) async {
    final response = await globals.supabaseClient.from('profiles').select('id').eq('email', email).limit(1);

    if (response.isNotEmpty) {
      return response[0]['id'];
    } else {
      throw Exception('User not found');
    }
  }

  /// ✅ **Get User Profile by ID**
  Future<Profile?> getUserProfileById(String userId) async {
    final response = await globals.supabaseClient.from('profiles').select().eq('id', userId).maybeSingle();
    return response != null ? Profile.fromJson(response) : null;
  }
}

// import 'dart:io';
//
// import 'package:path/path.dart' as path;
// import 'package:sollylabs_discover/database/models/profile.dart';
// import 'package:sollylabs_discover/global/globals.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class ProfileService {
//   Future<List<Profile>> getAllProfiles() async {
//     final response = await globals.supabaseClient.from('profiles').select();
//
//     PostgrestList testResponse = response;
//     for (var i = 0; i < testResponse.length; i++) {
//       print('Test Response: ${testResponse[i]}\n\n\n\n');
//     }
//
//     if (response.isNotEmpty) {
//       return (response as List).map((data) => Profile.fromJson(data)).toList();
//     } else {
//       return [];
//     }
//   }
//
//   Future<String?> uploadAvatar(String userId, File imageFile) async {
//     try {
//       final fileExt = path.extension(imageFile.path);
//       final fileName = 'avatars/$userId/avatar$fileExt';
//
//       // Upload the file and get the response
//       final storageResponse = await globals.supabaseClient.storage
//           .from('avatars') // Replace 'avatars' with your bucket name
//           .upload(
//             fileName, // No need for duplicate 'avatars' here
//             imageFile,
//             fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
//           );
//
//       // Get the public URL of the uploaded file
//       final String publicUrl = globals.supabaseClient.storage.from('avatars').getPublicUrl(fileName); // No need for duplicate 'avatars' here
//
//       return publicUrl;
//     } catch (e) {
//       print('Error uploading avatar: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> deleteAvatar(String userId) async {
//     try {
//       final pathToDelete = 'avatars/$userId/';
//
//       // List all files within the user's avatar directory
//       final List<FileObject> files = await globals.supabaseClient.storage.from('avatars').list(path: pathToDelete);
//
//       // Create a list of file paths to delete (full path within the bucket)
//       final List<String> filesToDelete = files.map((file) => '$pathToDelete${file.name}').toList();
//       print("files: $files");
//
//       print("files to delete: $filesToDelete\n\n\n\n\n");
//
//       // Delete the files from storage
//       if (filesToDelete.isNotEmpty) {
//         await globals.supabaseClient.storage.from('avatars').remove(filesToDelete);
//       }
//     } catch (e) {
//       print('Error deleting avatar: $e');
//       rethrow;
//     }
//   }
//
//   Future<Profile?> getProfile() async {
//     final user = globals.supabaseClient.auth.currentUser;
//     if (user == null) {
//       return null; // Or handle the case where there is no logged-in user
//     }
//
//     try {
//       final response = await globals.supabaseClient.from('profiles').select().eq('id', user.id).maybeSingle();
//
//       if (response != null) {
//         return Profile.fromJson(response);
//       } else {
//         return null; // Handle the case where the user's profile does not exist
//       }
//     } catch (e) {
//       print('Error fetching user profile: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> updateProfile(Profile updatedProfile) async {
//     try {
//       await globals.supabaseClient.from('profiles').update(updatedProfile.toJson()).eq('id', updatedProfile.id.uuid);
//     } catch (e) {
//       print('Error updating user profile: $e');
//       rethrow;
//     }
//   }
//
//   Future<bool> isDisplayIdUnique(String displayId, String currentUserId) async {
//     try {
//       final response = await globals.supabaseClient.from('profiles').select('id').eq('display_id', displayId).neq('id', currentUserId);
//
//       // If the response is empty, it means no other user has this display_id
//       return response.isEmpty;
//     } catch (e) {
//       print('Error checking display_id uniqueness: $e');
//       rethrow;
//     }
//   }
//
//   Future<Profile?> searchUserByEmail(String email) async {
//     try {
//       final response = await globals.supabaseClient.from('profiles').select().eq('email', email).maybeSingle();
//
//       if (response != null) {
//         return Profile.fromJson(response);
//       } else {
//         return null;
//       }
//     } catch (e) {
//       print('Error searching user by email: $e');
//       rethrow;
//     }
//   }
//
//   Future<String> getUserIdFromEmail(String email) async {
//     try {
//       final List<dynamic> response = await globals.supabaseClient
//           .from('profiles')
//           .select('id')
//           .eq('email', email) // Assuming 'email' is a column in your 'profiles' table
//           .limit(1); // Limit to one result, assuming emails are unique
//
//       if (response.isNotEmpty) {
//         final userId = response[0]['id'];
//         return userId;
//       } else {
//         throw Exception('User not found');
//       }
//     } catch (e) {
//       print('Error fetching user ID: $e');
//       rethrow;
//     }
//   }
//
//   Future<Profile?> getUserProfileById(String userId) async {
//     try {
//       final response = await globals.supabaseClient.from('profiles').select().eq('id', userId).maybeSingle(); // Use maybeSingle instead of single
//
//       if (response != null) {
//         return Profile.fromJson(response);
//       } else {
//         print('No user found with ID: $userId');
//         return null;
//       }
//     } catch (e) {
//       print('Error fetching user profile: $e');
//       rethrow;
//     }
//   }
// }
