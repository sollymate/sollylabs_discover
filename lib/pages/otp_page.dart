import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sollylabs_discover/auth/auth_service.dart';
import 'package:sollylabs_discover/pages/update_password_after_reset_page.dart';

class OtpPage extends StatefulWidget {
  final String email;
  final bool isResetPassword;

  const OtpPage({
    required this.email,
    this.isResetPassword = false,
    super.key,
  });

  @override
  OtpPageState createState() => OtpPageState();
}

class OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false; // Add loading state

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OTP Verification"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Enter OTP sent to: ${widget.email}"),
              const SizedBox(height: 20),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Enter OTP',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading
                    ? null // Disable button while loading
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true; // Start loading
                          });

                          final authService = Provider.of<AuthService>(context, listen: false);
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);

                          try {
                            if (widget.isResetPassword) {
                              await authService.verifyOtp(
                                widget.email,
                                _otpController.text,
                              );
                              if (mounted) {
                                navigator.push(
                                  MaterialPageRoute(
                                    builder: (context) => const UpdatePasswordAfterResetPage(),
                                  ),
                                );
                              }
                            } else {
                              await authService.verifyOtp(
                                widget.email,
                                _otpController.text,
                              );
                              if (mounted) {
                                navigator.pop();
                              }
                            }
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Error verifying OTP: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            setState(() {
                              _isLoading = false; // Stop loading
                            });
                          }
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator() // Show indicator
                    : const Text("Verify OTP"),
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
// import 'package:sollylabs_discover/pages/update_password_after_reset_page.dart';
//
// class OtpPage extends StatefulWidget {
//   final String email;
//   final bool isResetPassword;
//
//   const OtpPage({
//     required this.email,
//     this.isResetPassword = false,
//     super.key,
//   });
//
//   @override
//   OtpPageState createState() => OtpPageState();
// }
//
// class OtpPageState extends State<OtpPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _otpController = TextEditingController();
//   bool _isLoading = false; // Add loading state
//
//   @override
//   void dispose() {
//     _otpController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("OTP Verification"),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text("Enter OTP sent to: ${widget.email}"),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _otpController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'OTP',
//                   hintText: 'Enter OTP',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the OTP';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _isLoading
//                     ? null // Disable button while loading
//                     : () async {
//                         if (_formKey.currentState!.validate()) {
//                           setState(() {
//                             _isLoading = true; // Start loading
//                           });
//
//                           final authService = Provider.of<AuthService>(context, listen: false);
//                           final messenger = ScaffoldMessenger.of(context);
//                           final navigator = Navigator.of(context);
//
//                           try {
//                             if (widget.isResetPassword) {
//                               // Verify OTP for password reset
//                               final isVerified = await authService.verifyPasswordResetOtp(
//                                 email: widget.email,
//                                 otp: _otpController.text,
//                               );
//                               if (isVerified) {
//                                 // Navigate to UpdatePasswordAfterResetPage
//                                 if (mounted) {
//                                   navigator.push(
//                                     MaterialPageRoute(
//                                       builder: (context) => const UpdatePasswordAfterResetPage(),
//                                     ),
//                                   );
//                                 }
//                               } else {
//                                 messenger.showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Incorrect OTP'),
//                                   ),
//                                 );
//                               }
//                             } else {
//                               await authService.verifyOtp(
//                                 widget.email,
//                                 _otpController.text,
//                               );
//                               if (mounted) {
//                                 navigator.pop();
//                               }
//                             }
//                           } catch (e) {
//                             messenger.showSnackBar(
//                               SnackBar(
//                                 content: Text('Error verifying OTP: $e'),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                           } finally {
//                             setState(() {
//                               _isLoading = false; // Stop loading
//                             });
//                           }
//                         }
//                       },
//                 child: _isLoading
//                     ? const CircularProgressIndicator() // Show indicator
//                     : const Text("Verify OTP"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:sollylabs_discover/auth/auth_service.dart';
// //
// // class OtpPage extends StatefulWidget {
// //   final String email;
// //   final bool isResetPassword; // Add this parameter
// //
// //   const OtpPage({
// //     required this.email,
// //     this.isResetPassword = false, // Default value is false
// //     super.key,
// //   });
// //
// //   @override
// //   OtpPageState createState() => OtpPageState();
// // }
// //
// // class OtpPageState extends State<OtpPage> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _otpController = TextEditingController();
// //   bool _isLoading = false; // Add loading state
// //
// //   @override
// //   void dispose() {
// //     _otpController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("OTP Verification"),
// //       ),
// //       body: Form(
// //         key: _formKey,
// //         child: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Text("Enter OTP sent to: ${widget.email}"),
// //               const SizedBox(height: 20),
// //               TextFormField(
// //                 controller: _otpController,
// //                 keyboardType: TextInputType.number,
// //                 decoration: const InputDecoration(
// //                   labelText: 'OTP',
// //                   hintText: 'Enter OTP',
// //                 ),
// //                 validator: (value) {
// //                   if (value == null || value.isEmpty) {
// //                     return 'Please enter the OTP';
// //                   }
// //                   return null;
// //                 },
// //               ),
// //               const SizedBox(height: 20),
// //               ElevatedButton(
// //                 onPressed: _isLoading
// //                     ? null // Disable button while loading
// //                     : () async {
// //                         if (_formKey.currentState!.validate()) {
// //                           setState(() {
// //                             _isLoading = true; // Start loading
// //                           });
// //
// //                           final authService = Provider.of<AuthService>(context, listen: false);
// //                           final messenger = ScaffoldMessenger.of(context);
// //                           final navigator = Navigator.of(context);
// //
// //                           try {
// //                             await authService.verifyOtp(
// //                               widget.email,
// //                               _otpController.text,
// //                             );
// //                             if (mounted) {
// //                               navigator.pop();
// //                             }
// //                           } catch (e) {
// //                             messenger.showSnackBar(
// //                               SnackBar(
// //                                 content: Text('Error verifying OTP: $e'),
// //                                 backgroundColor: Colors.red,
// //                               ),
// //                             );
// //                           } finally {
// //                             setState(() {
// //                               _isLoading = false; // Stop loading
// //                             });
// //                           }
// //                         }
// //                       },
// //                 child: _isLoading
// //                     ? const CircularProgressIndicator() // Show indicator
// //                     : const Text("Verify OTP"),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';
// // // import 'package:sollylabs_discover/auth/auth_service.dart';
// // //
// // // class OtpPage extends StatefulWidget {
// // //   final String email;
// // //
// // //   const OtpPage({required this.email, super.key});
// // //
// // //   @override
// // //   OtpPageState createState() => OtpPageState();
// // // }
// // //
// // // class OtpPageState extends State<OtpPage> {
// // //   final _formKey = GlobalKey<FormState>();
// // //   final _otpController = TextEditingController();
// // //   bool _isLoading = false; // Add loading state
// // //
// // //   @override
// // //   void dispose() {
// // //     _otpController.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text("OTP Verification"),
// // //       ),
// // //       body: Form(
// // //         key: _formKey,
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(16.0),
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               Text("Enter OTP sent to: ${widget.email}"),
// // //               const SizedBox(height: 20),
// // //               TextFormField(
// // //                 controller: _otpController,
// // //                 keyboardType: TextInputType.number,
// // //                 decoration: const InputDecoration(
// // //                   labelText: 'OTP',
// // //                   hintText: 'Enter OTP',
// // //                 ),
// // //                 validator: (value) {
// // //                   if (value == null || value.isEmpty) {
// // //                     return 'Please enter the OTP';
// // //                   }
// // //                   return null;
// // //                 },
// // //               ),
// // //               const SizedBox(height: 20),
// // //               ElevatedButton(
// // //                 onPressed: _isLoading
// // //                     ? null // Disable button while loading
// // //                     : () async {
// // //                         if (_formKey.currentState!.validate()) {
// // //                           setState(() {
// // //                             _isLoading = true; // Start loading
// // //                           });
// // //
// // //                           final authService = Provider.of<AuthService>(context, listen: false);
// // //                           final messenger = ScaffoldMessenger.of(context);
// // //                           final navigator = Navigator.of(context);
// // //
// // //                           try {
// // //                             await authService.verifyOtp(
// // //                               widget.email,
// // //                               _otpController.text,
// // //                             );
// // //                             if (mounted) {
// // //                               navigator.pop();
// // //                             }
// // //                           } catch (e) {
// // //                             messenger.showSnackBar(
// // //                               SnackBar(
// // //                                 content: Text('Error verifying OTP: $e'),
// // //                                 backgroundColor: Colors.red,
// // //                               ),
// // //                             );
// // //                           } finally {
// // //                             setState(() {
// // //                               _isLoading = false; // Stop loading
// // //                             });
// // //                           }
// // //                         }
// // //                       },
// // //                 child: _isLoading
// // //                     ? const CircularProgressIndicator() // Show indicator
// // //                     : const Text("Verify OTP"),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // // import 'package:flutter/material.dart';
// // // // import 'package:provider/provider.dart';
// // // // import 'package:sollylabs_discover/auth/auth_service.dart';
// // // //
// // // // class OtpPage extends StatefulWidget {
// // // //   final String email;
// // // //
// // // //   const OtpPage({required this.email, super.key});
// // // //
// // // //   @override
// // // //   OtpPageState createState() => OtpPageState();
// // // // }
// // // //
// // // // class OtpPageState extends State<OtpPage> {
// // // //   final _formKey = GlobalKey<FormState>();
// // // //   final _otpController = TextEditingController();
// // // //
// // // //   @override
// // // //   void dispose() {
// // // //     _otpController.dispose();
// // // //     super.dispose();
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: const Text("OTP Verification"),
// // // //       ),
// // // //       body: Form(
// // // //         key: _formKey,
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(16.0),
// // // //           child: Column(
// // // //             mainAxisAlignment: MainAxisAlignment.center,
// // // //             children: [
// // // //               Text("Enter OTP sent to: ${widget.email}"),
// // // //               const SizedBox(height: 20),
// // // //               TextFormField(
// // // //                 controller: _otpController,
// // // //                 keyboardType: TextInputType.number,
// // // //                 decoration: const InputDecoration(
// // // //                   labelText: 'OTP',
// // // //                   hintText: 'Enter OTP',
// // // //                 ),
// // // //                 validator: (value) {
// // // //                   if (value == null || value.isEmpty) {
// // // //                     return 'Please enter the OTP';
// // // //                   }
// // // //                   return null;
// // // //                 },
// // // //               ),
// // // //               const SizedBox(height: 20),
// // // //               ElevatedButton(
// // // //                 onPressed: () async {
// // // //                   if (_formKey.currentState!.validate()) {
// // // //                     final authService = Provider.of<AuthService>(context, listen: false);
// // // //                     final messenger = ScaffoldMessenger.of(context);
// // // //                     final navigator = Navigator.of(context);
// // // //
// // // //                     try {
// // // //                       await authService.verifyOtp(
// // // //                         widget.email,
// // // //                         _otpController.text,
// // // //                       );
// // // //
// // // //                       navigator.pop();
// // // //                     } catch (e) {
// // // //                       messenger.showSnackBar(
// // // //                         SnackBar(
// // // //                           content: Text('Error verifying OTP: $e'),
// // // //                           backgroundColor: Colors.red,
// // // //                         ),
// // // //                       );
// // // //                     }
// // // //                   }
// // // //                 },
// // // //                 child: const Text("Verify OTP"),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
