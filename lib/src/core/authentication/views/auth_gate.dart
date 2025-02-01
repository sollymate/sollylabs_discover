import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sollylabs_discover/src/core/authentication/services/auth_service.dart';
import 'package:sollylabs_discover/src/core/authentication/views/login_page.dart';
import 'package:sollylabs_discover/src/core/views/dashboard_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final isAuthenticated = authService.currentUser != null;

    return isAuthenticated ? const DashboardPage() : const LoginPage();
  }
}

// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sollylabs_discover/src/core/authentication/services/auth_service.dart';
// import 'package:sollylabs_discover/src/core/authentication/views/login_page.dart';
// import 'package:sollylabs_discover/src/core/views/dashboard_page.dart';
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
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_isLoggedIn) {
//       return const LoginPage();
//     } else {
//       return const DashboardPage();
//     }
//   }
// }
