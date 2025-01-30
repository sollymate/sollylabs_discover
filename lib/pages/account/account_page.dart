import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sollylabs_discover/auth/auth_service.dart';
import 'package:sollylabs_discover/database/database.dart';
import 'package:sollylabs_discover/database/models/profile.dart';
import 'package:sollylabs_discover/pages/login_page.dart';
import 'package:sollylabs_discover/pages/otp_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isSigningOut = false;
  Profile? _userProfile;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _displayIdController = TextEditingController();
  File? _avatarImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _websiteController.dispose();
    _displayIdController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final database = Provider.of<Database>(context, listen: false);
    try {
      final profile = await database.profileService.getProfile();
      if (profile != null && mounted) {
        setState(() {
          _userProfile = profile;
          _fullNameController.text = _userProfile!.fullName ?? '';
          _usernameController.text = _userProfile!.username ?? '';
          _websiteController.text = _userProfile!.website ?? '';
          _displayIdController.text = _userProfile!.displayId ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading profile: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final database = Provider.of<Database>(context, listen: false);

      // Validate uniqueness of displayId if it's not null
      if (_displayIdController.text.isNotEmpty) {
        final isUnique = await database.profileService.isDisplayIdUnique(_displayIdController.text, _userProfile!.id.uuid);
        if (!isUnique && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Display ID is already taken'), backgroundColor: Colors.red));
          return;
        }
      }

      String? avatarUrl;
      if (_avatarImage != null) {
        avatarUrl = await database.profileService.uploadAvatar(_userProfile!.id.uuid, _avatarImage!);
      }

      final updatedProfile = Profile(
        id: _userProfile!.id,
        fullName: _fullNameController.text,
        username: _usernameController.text,
        website: _websiteController.text,
        displayId: _displayIdController.text.isEmpty ? null : _displayIdController.text,
        updatedAt: DateTime.now(),
        email: _userProfile!.email,
        avatarUrl: avatarUrl ?? _userProfile!.avatarUrl,
      );

      try {
        await database.profileService.updateProfile(updatedProfile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _avatarImage = null; // Clear the selected image after updating
            _userProfile = updatedProfile; // Update the local profile
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _avatarImage = File(image.path);
      });
    }
  }

  Future<void> _removeAvatar() async {
    final database = Provider.of<Database>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Delete the avatar from storage
      await database.profileService.deleteAvatar(_userProfile!.id.uuid);

      // Update the user's profile to set the avatarUrl to null
      final updatedProfile = _userProfile!.copyWith(avatarUrl: null);
      await database.profileService.updateProfile(updatedProfile);

      if (mounted) {
        setState(() {
          _userProfile = updatedProfile;
          _avatarImage = null; // Clear the local image
        });

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Avatar removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error removing avatar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_userProfile != null) ...[
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _avatarImage != null ? FileImage(_avatarImage!) : (_userProfile!.avatarUrl != null ? NetworkImage(_userProfile!.avatarUrl!) : null) as ImageProvider<Object>?,
                            child: _avatarImage == null && _userProfile!.avatarUrl == null ? const Icon(Icons.camera_alt, size: 50) : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_userProfile!.avatarUrl != null || _avatarImage != null)
                          ElevatedButton(
                            onPressed: _removeAvatar,
                            child: const Text('Remove Avatar'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        if (value.length < 3) {
                          return 'Username must be at least 3 characters long';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(labelText: 'Website'),
                    ),
                    TextFormField(
                      controller: _displayIdController,
                      decoration: const InputDecoration(labelText: 'Display ID'),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _updateProfile,
                            child: const Text('Update Profile'),
                          ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSigningOut
                        ? null
                        : () async {
                            setState(() {
                              _isSigningOut = true;
                            });

                            final messenger = ScaffoldMessenger.of(context);
                            final authService = Provider.of<AuthService>(context, listen: false);
                            final navigator = Navigator.of(context);
                            try {
                              await authService.signOut();

                              // Explicitly navigate to LoginPage after successful sign out
                              if (context.mounted) {
                                navigator.pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const LoginPage()),
                                  (Route<dynamic> route) => false, // Remove all previous routes
                                );
                              }
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Error during sign out: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              setState(() {
                                _isSigningOut = false;
                              });
                            }
                          },
                    child: _isSigningOut
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Sign Out'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            final authService = Provider.of<AuthService>(context, listen: false);
                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);
                            try {
                              await authService.requestPasswordResetOtp(
                                authService.currentUser!.email!,
                              );
                              if (mounted) {
                                navigator.push(
                                  MaterialPageRoute(
                                    builder: (context) => OtpPage(
                                      email: authService.currentUser!.email!,
                                      isResetPassword: true,
                                    ),
                                  ),
                                );
                              }
                            } catch (error) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${error.toString()}'),
                                ),
                              );
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                    child: _isLoading ? const CircularProgressIndicator() : const Text('Update Password'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
