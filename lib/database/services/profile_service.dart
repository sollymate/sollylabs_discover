import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sollylabs_discover/database/models/profile.dart';
import 'package:sollylabs_discover/global/globals.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
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

  Future<String?> uploadAvatar(String userId, File imageFile) async {
    try {
      final fileExt = path.extension(imageFile.path);
      final fileName = 'avatars/$userId/avatar$fileExt';

      // Upload the file and get the response
      final storageResponse = await globals.supabaseClient.storage
          .from('avatars') // Replace 'avatars' with your bucket name
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get the public URL of the uploaded file
      final String publicUrl = globals.supabaseClient.storage.from('avatars').getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
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

// import 'dart:io';
//
// import 'package:path/path.dart' as path;
// import 'package:sollylabs_discover/database/models/profile.dart';
// import 'package:sollylabs_discover/global/globals.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class ProfileService {
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
//       final List<dynamic> response = await globals.supabaseClient.from('profiles').select('id').eq('email', email).limit(1);
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
//   Future<String?> uploadAvatar(String userId, File imageFile) async {
//     try {
//       final fileExt = path.extension(imageFile.path);
//       final fileName = 'avatars/$userId/avatar$fileExt';
//
//       // Upload the file and get the response
//       final storageResponse = await globals.supabaseClient.storage
//           .from('avatars') // Replace 'avatars' with your bucket name
//           .upload(
//             fileName,
//             imageFile,
//             fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
//           );
//
//       // Get the public URL of the uploaded file
//       final String publicUrl = globals.supabaseClient.storage.from('avatars').getPublicUrl(fileName);
//
//       return publicUrl;
//     } catch (e) {
//       print('Error uploading avatar: $e');
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
//
// // import 'package:sollylabs_discover/database/models/profile.dart';
// // import 'package:sollylabs_discover/global/globals.dart';
// //
// // class ProfileService {
// //   Future<Profile?> getProfile() async {
// //     final user = globals.supabaseClient.auth.currentUser;
// //     if (user == null) {
// //       return null;
// //     }
// //
// //     try {
// //       final response = await globals.supabaseClient.from('profiles').select().eq('id', user.id).maybeSingle();
// //
// //       if (response != null) {
// //         return Profile.fromJson(response);
// //       } else {
// //         return null;
// //       }
// //     } catch (e) {
// //       print('Error fetching user profile: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   Future<void> updateProfile(Profile updatedProfile) async {
// //     try {
// //       final response = await globals.supabaseClient.from('profiles').update(updatedProfile.toJson()).eq('id', updatedProfile.id.uuid).select();
// //
// //       // Check for errors
// //       if (response.isEmpty) {
// //         throw Exception('Failed to update profile: ${response[0]['message']}');
// //       }
// //     } catch (e) {
// //       print('Error updating user profile: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   Future<Profile?> searchUserByEmail(String email) async {
// //     try {
// //       final response = await globals.supabaseClient.from('profiles').select().eq('email', email).maybeSingle();
// //
// //       if (response != null) {
// //         return Profile.fromJson(response);
// //       } else {
// //         return null;
// //       }
// //     } catch (e) {
// //       print('Error searching user by email: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   Future<String> getUserIdFromEmail(String email) async {
// //     try {
// //       final List<dynamic> response = await globals.supabaseClient.from('profiles').select('id').eq('email', email).limit(1);
// //
// //       if (response.isNotEmpty) {
// //         final userId = response[0]['id'];
// //         return userId;
// //       } else {
// //         throw Exception('User not found');
// //       }
// //     } catch (e) {
// //       print('Error fetching user ID: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   Future<Profile?> getUserProfileById(String userId) async {
// //     try {
// //       final response = await globals.supabaseClient.from('profiles').select().eq('id', userId).maybeSingle();
// //
// //       if (response != null) {
// //         return Profile.fromJson(response);
// //       } else {
// //         print('No user found with ID: $userId');
// //         return null;
// //       }
// //     } catch (e) {
// //       print('Error fetching user profile: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   Future<bool> isDisplayIdUnique(String displayId, String currentUserId) async {
// //     try {
// //       final response = await globals.supabaseClient.from('profiles').select('id').eq('display_id', displayId).neq('id', currentUserId); // Exclude current user from the check
// //
// //       // If the response is empty, it means no other user has this display_id
// //       return response.isEmpty;
// //     } catch (e) {
// //       print('Error checking display_id uniqueness: $e');
// //       rethrow;
// //     }
// //   }
// // }
