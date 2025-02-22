import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sollylabs_discover/src/core/authentication/services/auth_service.dart';

// Type alias for the state
typedef UpdatePasswordAfterResetWidgetState = State<UpdatePasswordAfterResetPage>;

class UpdatePasswordAfterResetPage extends StatefulWidget {
  const UpdatePasswordAfterResetPage({super.key});

  @override
  UpdatePasswordAfterResetWidgetState createState() => _UpdatePasswordAfterResetPageState();
}

class _UpdatePasswordAfterResetPageState extends State<UpdatePasswordAfterResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool _showNewPassword = false;
  bool _showConfirmNewPassword = false;
  bool _isLoading = false; // Loading state

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Password'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter your new password',
                  suffixIcon: IconButton(
                    icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showNewPassword = !_showNewPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmNewPasswordController,
                obscureText: !_showConfirmNewPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  hintText: 'Re-enter your new password',
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmNewPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showConfirmNewPassword = !_showConfirmNewPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);

                          try {
                            // Update password after OTP verification
                            final authService = Provider.of<AuthService>(context, listen: false);
                            final isSuccess = await authService.updateUserPassword(
                              password: _newPasswordController.text,
                            );

                            if (isSuccess) {
                              // Show success message
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Password updated successfully!'),
                                ),
                              );
                              navigator.popUntil((route) => route.isFirst);
                            } else {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update password.'),
                                ),
                              );
                            }
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('An error occurred: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                child: _isLoading ? const CircularProgressIndicator() : const Text('Update Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
