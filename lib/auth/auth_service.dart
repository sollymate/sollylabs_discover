import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService with ChangeNotifier {
  final SupabaseClient _supabaseClient;
  final Logger _log = Logger('AuthService');

  StreamSubscription? _authSubscription;

  AuthService(this._supabaseClient) {
    _initializeAuthListener();
    _configureLogging();
  }

  void _configureLogging() {
    Logger.root.level = Level.ALL; // You can adjust the level
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  void _initializeAuthListener() {
    _authSubscription = _supabaseClient.auth.onAuthStateChange.listen((AuthState data) {
      _handleAuthStateChange(data);
    });
  }

  void _handleAuthStateChange(AuthState data) {
    final AuthChangeEvent event = data.event;
    final Session? session = data.session;

    _log.info('Auth Change Event: $event');
    if (session != null) {
      _log.info('Session: ${session.toJson()}');
    }
    notifyListeners();
  }

  User? get currentUser => _supabaseClient.auth.currentUser;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      notifyListeners();
    } catch (e) {
      _log.severe('Error during sign in with email and password: $e');
      rethrow;
    }
  }

  Future<void> signInWithOtp(String email) async {
    try {
      await _supabaseClient.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.supabase.flutter://login-callback/',
      );
      notifyListeners();
    } catch (e) {
      _log.severe('Error during sign in with OTP: $e');
      rethrow;
    }
  }

  Future<void> verifyOtp(String email, String token) async {
    try {
      await _supabaseClient.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
      notifyListeners();
    } catch (e) {
      _log.severe('Error during OTP verification: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      notifyListeners();
    } catch (e) {
      _log.severe('Error during sign out: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb
            ? 'http://localhost:3000/#/update-password' // Web URL
            : 'io.supabase.flutter://login-callback/', // Mobile deep link URL
      );
      notifyListeners();
    } catch (e) {
      _log.severe('Error sending password reset email: $e');
      rethrow;
    }
  }

  Future<bool> updateUserPassword({required String password}) async {
    try {
      final updates = UserAttributes(password: password);
      final response = await _supabaseClient.auth.updateUser(updates);
      if (response.user != null) {
        // Update the 'has_set_password' field in the 'profiles' table to true
        final user = _supabaseClient.auth.currentUser;
        if (user != null) {
          final profileUpdateResponse = await _supabaseClient.from('profiles').update({'has_set_password': true}).eq('id', user.id).select();

          if (profileUpdateResponse.isNotEmpty) {
            _log.info('Updated user profile successfully');
          } else {
            _log.warning('Failed to update user profile');
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      _log.severe('Error updating user password after OTP: $e');
      return false;
    }
  }

  Future<void> requestPasswordResetOtp(String email) async {
    try {
      await _supabaseClient.auth.signInWithOtp(
        email: email,
        emailRedirectTo: kIsWeb ? 'http://localhost:3000/#/update-password' : 'io.supabase.flutter://login-callback/',
      );
      notifyListeners();
    } catch (e) {
      _log.severe('Error requesting password reset OTP: $e');
      rethrow;
    }
  }

  Future<bool> checkIfPasswordIsSet() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return false;

    try {
      final response = await _supabaseClient.from('profiles').select('has_set_password').eq('id', user.id).maybeSingle();

      if (response != null && response.containsKey('has_set_password')) {
        return response['has_set_password'] as bool;
      }
    } catch (e) {
      _log.severe('Error checking if password is set: $e');
    }

    return false;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // Method to verify the current password
  Future<bool> verifyCurrentPassword({required String password}) async {
    try {
      final currentUserEmail = _supabaseClient.auth.currentUser?.email;
      if (currentUserEmail == null) {
        _log.warning('Current user email is null');
        return false;
      }

      // Attempt to sign in with the current user's email and provided password
      final signInResponse = await _supabaseClient.auth.signInWithPassword(
        email: currentUserEmail,
        password: password,
      );

      // Check if sign-in was successful
      if (signInResponse.session != null) {
        _log.info('Current password verification successful');
        return true;
      } else {
        _log.warning('Current password verification failed');
        return false;
      }
    } catch (e) {
      _log.severe('Error during current password verification: $e');
      return false;
    }
  }
}

// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
// import 'package:logging/logging.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class AuthService with ChangeNotifier {
//   final SupabaseClient _supabaseClient;
//   final Logger _log = Logger('AuthService');
//
//   StreamSubscription? _authSubscription;
//
//   AuthService(this._supabaseClient) {
//     _initializeAuthListener();
//     // Configure logging
//     Logger.root.level = Level.ALL; // You can adjust the level
//     Logger.root.onRecord.listen((record) {
//       debugPrint('${record.level.name}: ${record.time}: ${record.message}');
//     });
//   }
//
//   void _initializeAuthListener() {
//     _authSubscription = _supabaseClient.auth.onAuthStateChange.listen((AuthState data) {
//       _handleAuthStateChange(data);
//     });
//   }
//
//   void _handleAuthStateChange(AuthState data) {
//     final AuthChangeEvent event = data.event;
//     final Session? session = data.session;
//
//     _log.info('Auth Change Event: $event');
//     if (session != null) {
//       _log.info('Session: ${session.toJson()}');
//     }
//     notifyListeners();
//   }
//
//   User? get currentUser => _supabaseClient.auth.currentUser;
//
//   Future<void> signInWithEmailAndPassword(String email, String password) async {
//     try {
//       await _supabaseClient.auth.signInWithPassword(
//         email: email,
//         password: password,
//       );
//       notifyListeners();
//     } catch (e) {
//       _log.severe('Error during sign in with email and password: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> signInWithOtp(String email) async {
//     try {
//       await _supabaseClient.auth.signInWithOtp(
//         email: email,
//         emailRedirectTo: 'io.supabase.flutter://login-callback/',
//       );
//       notifyListeners();
//     } catch (e) {
//       _log.severe('Error during sign in with OTP: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> verifyOtp(String email, String token) async {
//     try {
//       await _supabaseClient.auth.verifyOTP(
//         email: email,
//         token: token,
//         type: OtpType.recovery,
//       );
//       notifyListeners();
//     } catch (e) {
//       _log.severe('Error during OTP verification: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> signOut() async {
//     try {
//       await _supabaseClient.auth.signOut();
//       notifyListeners();
//     } catch (e) {
//       _log.severe('Error during sign out: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> sendPasswordResetEmail(String email) async {
//     try {
//       await _supabaseClient.auth.resetPasswordForEmail(
//         email,
//         redirectTo: kIsWeb
//             ? 'http://localhost:3000/#/update-password' // Web URL
//             : 'io.supabase.flutter://login-callback/', // Mobile deep link URL
//       );
//       notifyListeners();
//     } catch (e) {
//       _log.severe('Error sending password reset email: $e');
//       rethrow;
//     }
//   }
//
//   Future<bool> updateUserPassword({required String password}) async {
//     try {
//       final updates = UserAttributes(password: password);
//       final response = await _supabaseClient.auth.updateUser(updates);
//       if (response.user != null) {
//         // Update the 'has_set_password' field in the 'profiles' table to true
//         final user = _supabaseClient.auth.currentUser;
//         if (user != null) {
//           final profileUpdateResponse = await _supabaseClient.from('profiles').update({'has_set_password': true}).eq('id', user.id).select();
//
//           if (profileUpdateResponse.isNotEmpty) {
//             _log.info('Updated user profile successfully');
//           } else {
//             _log.warning('Failed to update user profile');
//           }
//         }
//         return true;
//       }
//       return false;
//     } catch (e) {
//       _log.severe('Error updating user password after OTP: $e');
//       return false;
//     }
//   }
//
//   Future<void> requestPasswordResetOtp(String email) async {
//     try {
//       await _supabaseClient.auth.signInWithOtp(
//         email: email,
//         emailRedirectTo: kIsWeb ? 'http://localhost:3000/#/update-password' : 'io.supabase.flutter://login-callback/',
//       );
//       notifyListeners();
//     } catch (e) {
//       _log.severe('Error requesting password reset OTP: $e');
//       rethrow;
//     }
//   }
//
//   Future<bool> checkIfPasswordIsSet() async {
//     final user = _supabaseClient.auth.currentUser;
//     if (user == null) return false;
//
//     try {
//       final response = await _supabaseClient.from('profiles').select('has_set_password').eq('id', user.id).maybeSingle();
//
//       if (response != null && response.containsKey('has_set_password')) {
//         return response['has_set_password'] as bool;
//       }
//     } catch (e) {
//       _log.severe('Error checking if password is set: $e');
//     }
//
//     return false;
//   }
//
//   @override
//   void dispose() {
//     _authSubscription?.cancel();
//     super.dispose();
//   }
// }
//
// // import 'dart:async';
// //
// // import 'package:flutter/foundation.dart';
// // import 'package:logging/logging.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// //
// // class AuthService with ChangeNotifier {
// //   final SupabaseClient _supabaseClient;
// //   final Logger _log = Logger('AuthService');
// //
// //   StreamSubscription? _authSubscription;
// //
// //   AuthService(this._supabaseClient) {
// //     _initializeAuthListener();
// //     _configureLogging();
// //   }
// //
// //   void _configureLogging() {
// //     Logger.root.level = Level.ALL;
// //     Logger.root.onRecord.listen((record) {
// //       debugPrint('${record.level.name}: ${record.time}: ${record.message}');
// //     });
// //   }
// //
// //   void _initializeAuthListener() {
// //     _authSubscription = _supabaseClient.auth.onAuthStateChange.listen((AuthState data) {
// //       _handleAuthStateChange(data);
// //     });
// //   }
// //
// //   void _handleAuthStateChange(AuthState data) {
// //     final AuthChangeEvent event = data.event;
// //     final Session? session = data.session;
// //
// //     _log.info('Auth Change Event: $event');
// //     if (session != null) {
// //       _log.info('Session: ${session.toJson()}');
// //     }
// //     notifyListeners();
// //   }
// //
// //   User? get currentUser => _supabaseClient.auth.currentUser;
// //
// //   Future<void> signInWithEmailAndPassword(String email, String password) async {
// //     try {
// //       await _supabaseClient.auth.signInWithPassword(
// //         email: email,
// //         password: password,
// //       );
// //       notifyListeners();
// //     } catch (e) {
// //       _log.severe('Error during sign in with email and password: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   Future<void> signInWithOtp(String email) async {
// //     try {
// //       await _supabaseClient.auth.signInWithOtp(
// //         email: email,
// //         emailRedirectTo: 'io.supabase.flutter://login-callback/',
// //       );
// //       notifyListeners();
// //     } catch (e) {
// //       _log.severe('Error during sign in with OTP: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   Future<void> verifyOtp(String email, String token) async {
// //     try {
// //       await _supabaseClient.auth.verifyOTP(
// //         email: email,
// //         token: token,
// //         type: OtpType.email,
// //       );
// //       notifyListeners();
// //     } catch (e) {
// //       _log.severe('Error during OTP verification: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   Future<void> signOut() async {
// //     try {
// //       await _supabaseClient.auth.signOut();
// //       notifyListeners();
// //     } catch (e) {
// //       _log.severe('Error during sign out: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   Future<void> sendPasswordResetEmail(String email) async {
// //     try {
// //       await _supabaseClient.auth.resetPasswordForEmail(
// //         email,
// //         redirectTo: kIsWeb
// //             ? 'http://localhost:3000/#/update-password' // Web URL
// //             : 'io.supabase.flutter://login-callback/', // Mobile deep link URL
// //       );
// //       notifyListeners();
// //     } catch (e) {
// //       _log.severe('Error sending password reset email: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   // Future<void> sendPasswordResetEmail(String email) async {
// //   //   try {
// //   //     await _supabaseClient.auth.resetPasswordForEmail(
// //   //       email,
// //   //       redirectTo: kIsWeb
// //   //           ? 'http://localhost:3000/#/update-password' // Web URL
// //   //           : 'io.supabase.flutter://login-callback/', // Mobile deep link URL
// //   //     );
// //   //     notifyListeners();
// //   //   } catch (e) {
// //   //     _log.severe('Error sending password reset email: $e');
// //   //     rethrow;
// //   //   }
// //   // }
// //
// //   // Future<bool> updateUserPasswordAfterOtp({required String password}) async {
// //   //   try {
// //   //     final updates = UserAttributes(password: password);
// //   //     final response = await _supabaseClient.auth.updateUser(updates);
// //   //     if (response.user != null) {
// //   //       // Update the 'has_set_password' field in the 'profiles' table to true
// //   //       final user = _supabaseClient.auth.currentUser;
// //   //       if (user != null) {
// //   //         final profileUpdateResponse = await _supabaseClient.from('profiles').update({'has_set_password': true}).eq('id', user.id).select();
// //   //
// //   //         if (profileUpdateResponse.isNotEmpty) {
// //   //           _log.info('Updated user profile successfully');
// //   //         } else {
// //   //           _log.warning('Failed to update user profile');
// //   //         }
// //   //       }
// //   //       return true;
// //   //     }
// //   //     return false;
// //   //   } catch (e) {
// //   //     _log.severe('Error updating user password after OTP: $e');
// //   //     return false;
// //   //   }
// //   // }
// //
// //   Future<bool> updateUserPassword({required String password}) async {
// //     try {
// //       final updates = UserAttributes(password: password);
// //       final response = await _supabaseClient.auth.updateUser(updates);
// //       if (response.user != null) {
// //         return true;
// //       }
// //       return false;
// //     } catch (e) {
// //       _log.severe('Error updating user password after OTP: $e');
// //       return false;
// //     }
// //   }
// //
// //   Future<void> requestPasswordResetOtp(String email) async {
// //     try {
// //       await _supabaseClient.auth.signInWithOtp(
// //         email: email,
// //         emailRedirectTo: kIsWeb ? 'http://localhost:3000/#/update-password' : 'io.supabase.flutter://login-callback/',
// //       );
// //       notifyListeners();
// //     } catch (e) {
// //       _log.severe('Error requesting password reset OTP: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   Future<bool> checkIfPasswordIsSet() async {
// //     final user = _supabaseClient.auth.currentUser;
// //     if (user == null) return false;
// //
// //     try {
// //       final response = await _supabaseClient.from('profiles').select('has_set_password').eq('id', user.id).maybeSingle();
// //
// //       if (response != null && response.containsKey('has_set_password')) {
// //         return response['has_set_password'] as bool;
// //       }
// //     } catch (e) {
// //       _log.severe('Error checking if password is set: $e');
// //     }
// //
// //     return false;
// //   }
// //
// //   @override
// //   void dispose() {
// //     _authSubscription?.cancel();
// //     super.dispose();
// //   }
// // }
