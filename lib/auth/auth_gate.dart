import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sollylabs_discover/auth/auth_service.dart';
import 'package:sollylabs_discover/pages/dashboard_page.dart';
import 'package:sollylabs_discover/pages/login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    // Initial check for logged-in user
    if (authService.currentUser != null) {
      _isLoggedIn = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return const LoginPage();
    } else {
      return const DashboardPage();
    }
  }
}

// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sollylabs_discover/auth/auth_service.dart';
// import 'package:sollylabs_discover/pages/account_page.dart';
// import 'package:sollylabs_discover/pages/create_password_page.dart';
// import 'package:sollylabs_discover/pages/login_page.dart';
//
// class AuthGate extends StatefulWidget {
//   const AuthGate({super.key});
//
//   @override
//   State<AuthGate> createState() => _AuthGateState();
// }
//
// class _AuthGateState extends State<AuthGate> {
//   bool _isLoggedIn = false;
//   bool _hasPassword = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkAuthentication();
//   }
//
//   Future<void> _checkAuthentication() async {
//     final authService = Provider.of<AuthService>(context, listen: false);
//
//     // Initial check for logged-in user
//     if (authService.currentUser != null) {
//       _isLoggedIn = true;
//       await _checkIfUserHasPassword(authService);
//     }
//   }
//
//   Future<void> _checkIfUserHasPassword(AuthService authService) async {
//     final hasPassword = await authService.checkIfPasswordIsSet();
//     setState(() {
//       _hasPassword = hasPassword;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_isLoggedIn) {
//       return const LoginPage();
//     } else if (_isLoggedIn && !_hasPassword) {
//       return const CreatePasswordPage();
//     } else {
//       return const AccountPage();
//     }
//   }
// }
//
// // import 'dart:async';
// //
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:sollylabs_discover/auth/auth_service.dart';
// // import 'package:sollylabs_discover/pages/account_page.dart';
// // import 'package:sollylabs_discover/pages/create_password_page.dart';
// // import 'package:sollylabs_discover/pages/login_page.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// //
// // class AuthGate extends StatefulWidget {
// //   const AuthGate({super.key});
// //
// //   @override
// //   State<AuthGate> createState() => _AuthGateState();
// // }
// //
// // class _AuthGateState extends State<AuthGate> {
// //   StreamSubscription<AuthState>? _authSubscription;
// //   bool _isLoggedIn = false;
// //   bool _hasPassword = false;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _checkAuthentication();
// //   }
// //
// //   Future<void> _checkAuthentication() async {
// //     final authService = Provider.of<AuthService>(context, listen: false);
// //
// //     // Initial check for logged-in user
// //     if (authService.currentUser != null) {
// //       _isLoggedIn = true;
// //       await _checkIfUserHasPassword(authService);
// //     }
// //
// //     // Listener for changes in authentication state
// //     _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
// //       final AuthChangeEvent event = data.event;
// //
// //       if (event == AuthChangeEvent.signedOut) {
// //         setState(() {
// //           _isLoggedIn = false;
// //           _hasPassword = false;
// //         });
// //       } else if (event == AuthChangeEvent.signedIn) {
// //         _isLoggedIn = true;
// //         _checkIfUserHasPassword(authService);
// //       }
// //     });
// //   }
// //
// //   Future<void> _checkIfUserHasPassword(AuthService authService) async {
// //     final hasPassword = await authService.checkIfPasswordIsSet();
// //     setState(() {
// //       _hasPassword = hasPassword;
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _authSubscription?.cancel();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     print('\n\n\nLogged In: $_isLoggedIn, Has Password: $_hasPassword\n\n\n');
// //     if (!_isLoggedIn) {
// //       return const LoginPage();
// //     } else if (_isLoggedIn && !_hasPassword) {
// //       return const CreatePasswordPage();
// //     } else {
// //       return const AccountPage();
// //     }
// //   }
// // }
