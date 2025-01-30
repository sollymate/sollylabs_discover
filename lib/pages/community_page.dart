import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sollylabs_discover/auth/auth_service.dart';
import 'package:sollylabs_discover/database/models/profile.dart';
import 'package:sollylabs_discover/database/services/connection_service.dart';
import 'package:sollylabs_discover/database/services/profile_service.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late ProfileService _profileService;
  late ConnectionService _connectionService;
  late String _currentUserId;
  late String _currentUserEmail;
  List<Profile> _profiles = [];
  // Set<String> _connectedUserEmails = {}; // Store emails of connected users
  Set<String> _connectedUserId = {}; // Store emails of connected users
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  final int _limit = 5; // Load 5 profiles per request
  int _offset = 0; // Track loaded profiles count
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _profileService = Provider.of<ProfileService>(context, listen: false);
    _connectionService = Provider.of<ConnectionService>(context, listen: false);
    _currentUserId = authService.currentUser!.id;
    _currentUserEmail = authService.currentUser!.email ?? 'No Email';

    _fetchConnections(); // ✅ Load connected users first
    _fetchProfiles(); // ✅ Load community profiles
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchConnections() async {
    try {
      final connectionsProfile = await _connectionService.getConnections(_currentUserId);
      setState(() {
        _connectedUserId = connectionsProfile
            .map((c) => c.otherUserId.toString()) // Ensure non-null
            .toSet();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: SelectableText('Error fetching connections: $e')),
        );
      }
    }
  }

  /// ✅ Fetch profiles with pagination
  Future<void> _fetchProfiles({bool isLoadMore = false}) async {
    if (isLoadMore && !_hasMore) return; // Stop if no more profiles

    if (!isLoadMore) _offset = 0; // ✅ Reset offset for new search

    setState(() => _isLoading = true);
    try {
      final profiles = await _profileService.getAllProfiles(searchQuery: _searchController.text, limit: _limit, offset: _offset);

      setState(() {
        if (isLoadMore) {
          _profiles.addAll(profiles); // ✅ Append new profiles
        } else {
          _profiles = profiles; // ✅ Initial search result
        }

        _offset += _limit; // ✅ Move offset forward
        _hasMore = profiles.length == _limit; // ✅ Check if more profiles exist
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: SelectableText('Error fetching profiles: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// ✅ Send connection request
  Future<void> _sendConnectionRequest(String targetUserId) async {
    try {
      await _connectionService.addConnection(_currentUserId, targetUserId);

      setState(() {
        // _connectedUserEmails.add(targetUserId); // ✅ Update UI
        _connectedUserId.add(targetUserId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection Added!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: Column(
        children: [
          // ✅ Show current user's email at the top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue[100],
            child: Text('Your Email: $_currentUserEmail', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),

          // ✅ Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(hintText: 'Search by email', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
              onChanged: (_) => _fetchProfiles(isLoadMore: false),
            ),
          ),

          if (_searchController.text.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextButton(
                  onPressed: () {
                    _searchController.clear();
                    _fetchProfiles(isLoadMore: false);
                  },
                  child: const Text('Clear Search'),
                ),
              ),
            ),

          // ✅ Profile List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _profiles.isEmpty
                    ? const Center(child: Text('No profiles found.'))
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: _profiles.length,
                              itemBuilder: (context, index) {
                                final profile = _profiles[index];

                                if (profile.id.toString() == _currentUserId) return const SizedBox.shrink(); // ✅ Hide current user
                                // if (profile.email == _currentUserEmail) return const SizedBox.shrink(); // ✅ Hide current user

                                // final bool isConnected = _connectedUserEmails.contains(profile.email);
                                final bool isConnected = _connectedUserId.contains(profile.id.toString());

                                return ListTile(
                                  leading: profile.avatarUrl != null ? CircleAvatar(backgroundImage: NetworkImage(profile.avatarUrl!)) : const CircleAvatar(child: Icon(Icons.person)),
                                  title: Text(profile.displayId ?? 'Unknown User'),
                                  subtitle: Text(profile.email ?? 'No Email'),
                                  trailing: isConnected
                                      ? const Text('Connected', style: TextStyle(color: Colors.green))
                                      : ElevatedButton(
                                          onPressed: () => _sendConnectionRequest(profile.id.toString()),
                                          child: const Text('Connect'),
                                        ),
                                );
                              },
                            ),
                          ),
                          if (_hasMore) // ✅ Show "Load More" button if more profiles exist
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: ElevatedButton(
                                onPressed: () => _fetchProfiles(isLoadMore: true),
                                child: const Text('Load More'),
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
