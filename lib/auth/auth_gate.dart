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
