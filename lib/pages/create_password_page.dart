import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sollylabs_discover/auth/auth_service.dart';

// Define the type alias
typedef CreatePasswordWidgetState = State<CreatePasswordPage>;

class CreatePasswordPage extends StatefulWidget {
  const CreatePasswordPage({super.key});

  @override
  CreatePasswordWidgetState createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Password'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm your password',
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
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

                          final authService = Provider.of<AuthService>(context, listen: false);
                          final messenger = ScaffoldMessenger.of(context);

                          try {
                            final isSuccess = await authService.updateUserPassword(
                              password: _passwordController.text,
                            );

                            if (isSuccess) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Password created successfully!'),
                                ),
                              );
                              if (context.mounted) {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              }
                            } else {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to create password.'),
                                  backgroundColor: Colors.red,
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
                child: _isLoading ? const CircularProgressIndicator() : const Text('Create Password'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Navigate to AccountPage directly
                  Navigator.of(context).pushReplacementNamed('/account');
                },
                child: const Text('Skip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sollylabs_discover/auth/auth_service.dart';
//
// class CreatePasswordPage extends StatefulWidget {
//   const CreatePasswordPage({super.key});
//
//   @override
//   CreatePasswordPageState createState() => CreatePasswordPageState();
// }
//
// class CreatePasswordPageState extends State<CreatePasswordPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _showPassword = false;
//   bool _showConfirmPassword = false;
//   bool _isLoading = false;
//
//   @override
//   void dispose() {
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Password'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               TextFormField(
//                 controller: _passwordController,
//                 obscureText: !_showPassword,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   hintText: 'Enter your password',
//                   suffixIcon: IconButton(
//                     icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
//                     onPressed: () {
//                       setState(() {
//                         _showPassword = !_showPassword;
//                       });
//                     },
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a password';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _confirmPasswordController,
//                 obscureText: !_showConfirmPassword,
//                 decoration: InputDecoration(
//                   labelText: 'Confirm Password',
//                   hintText: 'Confirm your password',
//                   suffixIcon: IconButton(
//                     icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
//                     onPressed: () {
//                       setState(() {
//                         _showConfirmPassword = !_showConfirmPassword;
//                       });
//                     },
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please confirm your password';
//                   }
//                   if (value != _passwordController.text) {
//                     return 'Passwords do not match';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _isLoading
//                     ? null
//                     : () async {
//                         if (_formKey.currentState!.validate()) {
//                           setState(() {
//                             _isLoading = true;
//                           });
//
//                           final authService = Provider.of<AuthService>(context, listen: false);
//                           final messenger = ScaffoldMessenger.of(context);
//
//                           try {
//                             // Assuming you have a method in AuthService to update user's password
//                             final isSuccess = await authService.updateUserPasswordAfterOtp(
//                               password: _passwordController.text,
//                             );
//
//                             if (isSuccess) {
//                               messenger.showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Password created successfully!'),
//                                 ),
//                               );
//                               // Navigate to the AccountPage or other appropriate page
//                               if (context.mounted) {
//                                 Navigator.of(context).popUntil((route) => route.isFirst);
//                               }
//                             } else {
//                               messenger.showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Failed to create password.'),
//                                   backgroundColor: Colors.red,
//                                 ),
//                               );
//                             }
//                           } catch (e) {
//                             messenger.showSnackBar(
//                               SnackBar(
//                                 content: Text('An error occurred: $e'),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                           } finally {
//                             setState(() {
//                               _isLoading = false;
//                             });
//                           }
//                         }
//                       },
//                 child: _isLoading ? const CircularProgressIndicator() : const Text('Create Password'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
