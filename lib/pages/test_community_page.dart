import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sollylabs_discover/auth/auth_service.dart';
import 'package:sollylabs_discover/database/models/community_profile.dart';
import 'package:sollylabs_discover/database/services/community_service.dart';

class TestCommunityPage extends StatefulWidget {
  const TestCommunityPage({super.key});

  @override
  State<TestCommunityPage> createState() => _TestCommunityPageState();
}

class _TestCommunityPageState extends State<TestCommunityPage> {
  late CommunityService _communityService;
  late String _currentUserId;
  List<CommunityProfile> _profiles = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  final int _limit = 5; // Load 5 profiles per request
  int _offset = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _communityService = Provider.of<CommunityService>(context, listen: false);
    _currentUserId = authService.currentUser!.id;

    _fetchProfiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// ✅ Fetch profiles from `community` view
  Future<void> _fetchProfiles({bool isLoadMore = false}) async {
    if (isLoadMore && !_hasMore) return; // Stop if no more profiles

    if (!isLoadMore) _offset = 0; // Reset offset for new search

    setState(() => _isLoading = true);
    try {
      final profiles = await _communityService.getCommunityProfiles(
        currentUserId: _currentUserId,
        searchQuery: _searchController.text,
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        if (isLoadMore) {
          _profiles.addAll(profiles);
        } else {
          _profiles = profiles;
        }

        _offset += _limit;
        _hasMore = profiles.length == _limit;
      });

      // ✅ Debugging Output
      for (var profile in profiles) {
        debugPrint('User: ${profile.displayId} | Connected: ${profile.isConnected} | Blocked: ${profile.isBlocked} | Blocked By: ${profile.isBlockedBy}');
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Community Page')),
      body: Column(
        children: [
          // ✅ Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _fetchProfiles(isLoadMore: false),
            ),
          ),

          // ✅ Profile List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _profiles.isEmpty
                    ? const Center(child: Text('No profiles found.'))
                    : ListView.builder(
                        itemCount: _profiles.length,
                        itemBuilder: (context, index) {
                          final profile = _profiles[index];

                          return ListTile(
                            leading: profile.avatarUrl != null ? CircleAvatar(backgroundImage: NetworkImage(profile.avatarUrl!)) : const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(profile.displayId ?? 'Unknown User'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(profile.email ?? 'No Email'),
                                Text(
                                  profile.isBlocked
                                      ? 'Blocked ❌'
                                      : profile.isBlockedBy
                                          ? 'Blocked By User ❌'
                                          : profile.isConnected
                                              ? 'Connected ✅'
                                              : 'Not Connected',
                                  style: TextStyle(
                                    color: profile.isBlocked || profile.isBlockedBy
                                        ? Colors.red
                                        : profile.isConnected
                                            ? Colors.green
                                            : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
