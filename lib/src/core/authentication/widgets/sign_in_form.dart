import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sollylabs_discover/src/core/authentication/services/auth_service.dart';
import 'package:sollylabs_discover/src/core/navigation/route_names.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  SignInFormState createState() => SignInFormState();
}

class SignInFormState extends State<SignInForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late TabController _tabController;
  bool _showPassword = false;
  bool _isLoading = false; // Add a loading state variable

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  key: const Key('emailField'),
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                if (_tabController.index == 1) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextFormField(
                      key: const Key('passwordField'),
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (_tabController.index == 1) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        context.push(RouteNames.resetPasswordPage);

                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
                        // );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Sign in with OTP'),
              Tab(text: 'Sign in with Password'),
            ],
          ),
          const SizedBox(height: 20),
          _isLoading // Show progress indicator if loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  key: const Key('signInButton'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true; // Start loading
                      });

                      final authService = Provider.of<AuthService>(context, listen: false);
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);

                      try {
                        if (_tabController.index == 1) {
                          // Handle password sign-in
                          await authService.signInWithEmailAndPassword(
                            _emailController.text,
                            _passwordController.text,
                          );
                        } else {
                          // Handle existing OTP sign-in
                          await authService.signInWithOtp(
                            _emailController.text,
                          );
                          if (context.mounted) {
                            context.push(RouteNames.otpPage, extra: {
                              'email': _emailController.text,
                            });

                            // navigator.push(
                            //   MaterialPageRoute(
                            //     builder: (context) => OtpPage(email: _emailController.text),
                            //   ),
                            // );
                          }
                        }
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                        setState(() {
                          _isLoading = false; // Stop loading
                        });
                      } finally {
                        setState(() {
                          _isLoading = false; // Stop loading
                        });
                      }
                    }
                  },
                  child: const Text('Sign In'),
                ),
        ],
      ),
    );
  }
}
