import 'package:flutter/material.dart';
import 'package:sollylabs_discover/src/core/authentication/widgets/sign_in_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: const Center(
        child: SignInForm(),
      ),
    );
  }
}
