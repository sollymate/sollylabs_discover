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
  List<Profile> _filteredProfiles = [];
  Set<String> _connectedUsers = {}; // Store connected user IDs
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _profileService = Provider.of<ProfileService>(context, listen: false);
    _connectionService = Provider.of<ConnectionService>(context, listen: false);
    _currentUserId = authService.currentUser!.id;
    _currentUserEmail = authService.currentUser!.email ?? 'No Email';
    _fetchProfiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _limit = 5; // Load 5 profiles per request
  int _offset = 0; // Track the number of loaded profiles
  bool _hasMore = true;

  Future<void> _fetchProfiles({bool isLoadMore = false}) async {
    if (isLoadMore && !_hasMore) return; // Stop if no more profiles

    if (!isLoadMore) _offset = 0; // ✅ Reset offset for new search query

    setState(() => _isLoading = true);
    try {
      final profiles = await _profileService.getAllProfiles(
        searchQuery: _searchController.text, // ✅ Pass search query
        limit: _limit,
        offset: _offset, // ✅ Use correct offset for pagination
      );

      setState(() {
        if (isLoadMore) {
          _profiles.addAll(profiles); // ✅ Append new profiles
        } else {
          _profiles = profiles; // ✅ Initial search result
        }

        _filteredProfiles = _profiles;
        _offset += _limit; // ✅ Move offset forward for next fetch
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

  // Future<void> _fetchProfiles({bool isLoadMore = false}) async {
  //   if (isLoadMore && !_hasMore) return; // Stop if no more profiles
  //
  //   setState(() => _isLoading = true);
  //   try {
  //     final profiles = await _profileService.getAllProfiles(
  //       searchQuery: _searchController.text,
  //       limit: _limit,
  //       offset: _offset, // ✅ Start fetching from the correct position
  //     );
  //
  //     setState(() {
  //       if (isLoadMore) {
  //         _profiles.addAll(profiles); // ✅ Append new profiles
  //       } else {
  //         _profiles = profiles; // ✅ Initial load
  //       }
  //
  //       _filteredProfiles = _profiles; // ✅ Update the displayed list
  //       _offset += _limit; // ✅ Move offset forward for next fetch
  //       _hasMore = profiles.length == _limit; // ✅ Check if more profiles exist
  //     });
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: SelectableText('Error fetching profiles: $e')),
  //       );
  //     }
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  // int _limit = 5; // Number of profiles to load initially
  // bool _hasMore = true; // Flag to check if more profiles exist
  // int _offset = 0; // Tracks how many profiles have been loaded
  //
  // Future<void> _fetchProfiles({bool isLoadMore = false}) async {
  //   if (isLoadMore && !_hasMore) return; // Stop loading if no more profiles
  //
  //   setState(() => _isLoading = true);
  //   try {
  //     final profiles = await _profileService.getAllProfiles(
  //       searchQuery: _searchController.text,
  //       limit: _limit,
  //       offset: _offset, // ✅ Apply correct offset for pagination
  //     );
  //
  //     setState(() {
  //       if (isLoadMore) {
  //         _profiles.addAll(profiles);
  //       } else {
  //         _profiles = profiles;
  //       }
  //
  //       _filteredProfiles = _profiles;
  //       _offset += _limit; // ✅ Increase offset to prevent duplicates
  //       _hasMore = profiles.length == _limit; // ✅ Check if more profiles exist
  //     });
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: SelectableText('Error fetching profiles: $e')),
  //       );
  //     }
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  // Future<void> _fetchProfiles({bool isLoadMore = false}) async {
  //   if (isLoadMore && !_hasMore) return; // Stop loading if no more profiles
  //
  //   setState(() => _isLoading = true);
  //   try {
  //     final profiles = await _profileService.getAllProfiles(
  //       searchQuery: _searchController.text,
  //       limit: _limit, // Pass limit correctly
  //     );
  //
  //     if (isLoadMore) {
  //       _profiles.addAll(profiles);
  //     } else {
  //       _profiles = profiles;
  //     }
  //
  //     _hasMore = profiles.length >= _limit; // If profiles returned < limit, no more to load
  //
  //     setState(() => _filteredProfiles = _profiles);
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: SelectableText('Error fetching profiles: $e')),
  //       );
  //     }
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  // Future<void> _fetchProfiles({bool isLoadMore = false}) async {
  //   if (isLoadMore && !_hasMore) return; // Stop loading if no more profiles
  //
  //   setState(() => _isLoading = true);
  //   try {
  //     final profiles = await _profileService.getAllProfiles(
  //       searchQuery: _searchController.text,
  //       limit: _limit, // Apply limit
  //     );
  //
  //     if (isLoadMore) {
  //       _profiles.addAll(profiles);
  //     } else {
  //       _profiles = profiles;
  //     }
  //
  //     _hasMore = profiles.length >= _limit; // If profiles returned < limit, no more to load
  //
  //     setState(() => _filteredProfiles = _profiles);
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: SelectableText('Error fetching profiles: $e')),
  //       );
  //     }
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  // Future<void> _fetchProfiles() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     final profiles = await _profileService.getAllProfiles(searchQuery: _searchController.text);
  //     final connections = await _connectionService.getConnections(_currentUserId);
  //
  //     setState(() {
  //       _profiles = profiles;
  //       _filteredProfiles = profiles; // No need for local filtering
  //       _connectedUsers = connections.map((c) => c.id).toSet();
  //     });
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: SelectableText('Error fetching profiles: $e')),
  //       );
  //     }
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  // Future<void> _fetchProfiles() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     final profiles = await _profileService.getAllProfiles(searchQuery: _searchController.text);
  //
  //     // final profiles = await _profileService.getAllProfiles();
  //     // final profiles = await _profileService.getAllProfiles();
  //     final connections = await _connectionService.getConnections(_currentUserId);
  //
  //     setState(() {
  //       _profiles = profiles;
  //       _filteredProfiles = profiles; // Initialize filtered list
  //       _connectedUsers = connections.map((c) => c.id).toSet(); // ✅ Use correct ID mapping
  //     });
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: SelectableText('Error fetching profiles: $e')),
  //       );
  //     }
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  void _filterProfiles(String query) {
    if (query.isEmpty) {
      setState(() => _filteredProfiles = _profiles);
      return;
    }

    setState(() {
      _filteredProfiles = _profiles.where((profile) {
        return profile.email?.toLowerCase().contains(query.toLowerCase()) ?? false;
      }).toList();
    });
  }

  Future<void> _sendConnectionRequest(String targetUserId) async {
    try {
      await _connectionService.addConnection(_currentUserId.toString(), targetUserId);

      setState(() {
        _connectedUsers.add(targetUserId); // ✅ Ensure UI reflects new connection
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection Added!')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending request: $e')),
        );
      }
    }
  }

  String _selectedSort = 'email'; // Default sort option

  void _sortProfiles(String sortBy) {
    setState(() {
      _selectedSort = sortBy;
      _filteredProfiles.sort((a, b) {
        switch (sortBy) {
          case 'email':
            return (a.email ?? '').compareTo(b.email ?? '');
          case 'updated_at':
            return (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)); // Descending order
          case 'display_id':
            return (a.displayId ?? '').compareTo(b.displayId ?? '');
          default:
            return 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          DropdownButton<String>(
            value: _selectedSort,
            onChanged: (value) {
              if (value != null) {
                _sortProfiles(value);
              }
            },
            items: const [
              DropdownMenuItem(value: 'email', child: Text('Sort by Email')),
              DropdownMenuItem(value: 'updated_at', child: Text('Sort by Updated At')),
              DropdownMenuItem(value: 'display_id', child: Text('Sort by Display ID')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Show current user's email at the top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue[100],
            child: Text(
              'Your Email: $_currentUserEmail',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search by email',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (query) {
              _fetchProfiles(isLoadMore: false); // ✅ Call fetch method on search input
            },
          ),

          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextField(
          //     controller: _searchController,
          //     decoration: const InputDecoration(
          //       hintText: 'Search by email',
          //       prefixIcon: Icon(Icons.search),
          //       border: OutlineInputBorder(),
          //     ),
          //     onChanged: (query) {
          //       _fetchProfiles(); // 🔹 Fetch profiles directly from Supabase instead of filtering locally
          //     },
          //   ),
          // ),

          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextField(
          //     controller: _searchController,
          //     decoration: const InputDecoration(
          //       hintText: 'Search by email',
          //       prefixIcon: Icon(Icons.search),
          //       border: OutlineInputBorder(),
          //     ),
          //     onChanged: (query) {
          //       // _profileService.getAllProfiles(searchQuery: _searchController.text);
          //       // _filterProfiles(query);
          //       setState(() {}); // Force UI update
          //     },
          //   ),
          // ),
          // if (_searchController.text.isNotEmpty)
          //   Align(
          //     alignment: Alignment.centerRight,
          //     child: Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //       child: TextButton(
          //         onPressed: () {
          //           _searchController.clear();
          //           setState(() => _filteredProfiles = _profiles);
          //         },
          //         child: const Text('Clear Search'),
          //       ),
          //     ),
          //   ),
          if (_searchController.text.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextButton(
                  onPressed: () {
                    _searchController.clear();
                    _fetchProfiles(isLoadMore: false); // ✅ Reset list on clear
                  },
                  child: const Text('Clear Search'),
                ),
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProfiles.isEmpty
                    ? const Center(child: Text('No profiles found.'))
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: _filteredProfiles.length,
                              itemBuilder: (context, index) {
                                final profile = _filteredProfiles[index];

                                if (profile.id.toString() == _currentUserId) return const SizedBox.shrink();

                                final bool isConnected = _connectedUsers.contains(profile.id.toString());

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
                          if (_hasMore) // Show "Load More" button only if more profiles exist
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: ElevatedButton(
                                onPressed: () => _fetchProfiles(isLoadMore: true),
                                child: const Text('Load More'),
                              ),
                            ),

                          // if (_hasMore) // Show "Load More" button only if more profiles exist
                          //   Padding(
                          //     padding: const EdgeInsets.symmetric(vertical: 10),
                          //     child: ElevatedButton(
                          //       onPressed: () {
                          //         setState(() => _limit += 5); // Increase limit by 5
                          //         _fetchProfiles(isLoadMore: true);
                          //       },
                          //       child: const Text('Load More'),
                          //     ),
                          //   ),
                        ],
                      ),
          ),

          // Expanded(
          //   child: _isLoading
          //       ? const Center(child: CircularProgressIndicator())
          //       : _filteredProfiles.isEmpty
          //           ? const Center(child: Text('No profiles found.'))
          //           : ListView.builder(
          //               itemCount: _filteredProfiles.length,
          //               itemBuilder: (context, index) {
          //                 final profile = _filteredProfiles[index];
          //
          //                 if (profile.id.toString() == _currentUserId) return const SizedBox.shrink();
          //
          //                 final bool isConnected = _connectedUsers.contains(profile.id);
          //
          //                 return ListTile(
          //                   leading: profile.avatarUrl != null ? CircleAvatar(backgroundImage: NetworkImage(profile.avatarUrl!)) : const CircleAvatar(child: Icon(Icons.person)),
          //                   title: Text(profile.displayId ?? 'Unknown User'),
          //                   subtitle: Text(profile.email ?? 'No Email'),
          //                   trailing: isConnected
          //                       ? const Text('Connected', style: TextStyle(color: Colors.green))
          //                       : ElevatedButton(
          //                           onPressed: () => _sendConnectionRequest(profile.id.toString()),
          //                           child: const Text('Connect'),
          //                         ),
          //                 );
          //               },
          //             ),
          // ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sollylabs_discover/auth/auth_service.dart';
// import 'package:sollylabs_discover/database/models/profile.dart';
// import 'package:sollylabs_discover/database/services/connection_service.dart';
// import 'package:sollylabs_discover/database/services/profile_service.dart';
//
// class CommunityPage extends StatefulWidget {
//   const CommunityPage({super.key});
//
//   @override
//   State<CommunityPage> createState() => _CommunityPageState();
// }
//
// class _CommunityPageState extends State<CommunityPage> {
//   late ProfileService _profileService;
//   late ConnectionService _connectionService;
//   late String _currentUserId;
//   List<Profile> _profiles = [];
//   List<Profile> _filteredProfiles = [];
//   Set<String> _connectedUsers = {}; // Store connected user IDs
//   bool _isLoading = true;
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _profileService = Provider.of<ProfileService>(context, listen: false);
//     _connectionService = Provider.of<ConnectionService>(context, listen: false);
//     _currentUserId = Provider.of<AuthService>(context, listen: false).currentUser!.id;
//     _fetchProfiles();
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchProfiles() async {
//     setState(() => _isLoading = true);
//     try {
//       final profiles = await _profileService.getAllProfiles();
//       final connections = await _connectionService.getConnections(_currentUserId);
//
//       setState(() {
//         _profiles = profiles;
//         _filteredProfiles = profiles; // Initialize filtered list
//         _connectedUsers = connections.map((c) => c.user1Id.toString() == _currentUserId ? c.user2Id.toString() : c.user1Id.toString()).toSet();
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: SelectableText('Error fetching profiles: $e')),
//         );
//       }
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _filterProfiles(String query) {
//     if (query.isEmpty) {
//       setState(() => _filteredProfiles = _profiles);
//       return;
//     }
//
//     setState(() {
//       _filteredProfiles = _profiles.where((profile) {
//         return profile.email?.toLowerCase().contains(query.toLowerCase()) ?? false;
//       }).toList();
//     });
//   }
//
//   Future<void> _sendConnectionRequest(String targetUserId) async {
//     try {
//       await _connectionService.addConnection(_currentUserId.toString(), targetUserId);
//
//       setState(() {
//         _connectedUsers.add(targetUserId); // ✅ Ensure UI reflects new connection
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Connection Added!')),
//       );
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error sending request: $e')),
//         );
//       }
//     }
//   }
//
//   String _selectedSort = 'email'; // Default sort option
//
//   void _sortProfiles(String sortBy) {
//     setState(() {
//       _selectedSort = sortBy;
//       _filteredProfiles.sort((a, b) {
//         switch (sortBy) {
//           case 'email':
//             return (a.email ?? '').compareTo(b.email ?? '');
//           case 'updated_at':
//             return (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)); // Descending order
//
//           case 'display_id':
//             return (a.displayId ?? '').compareTo(b.displayId ?? '');
//           default:
//             return 0;
//         }
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Community'),
//         actions: [
//           DropdownButton<String>(
//             value: _selectedSort,
//             onChanged: (value) {
//               if (value != null) {
//                 _sortProfiles(value);
//               }
//             },
//             items: const [
//               DropdownMenuItem(value: 'email', child: Text('Sort by Email')),
//               DropdownMenuItem(value: 'updated_at', child: Text('Sort by Updated At')),
//               DropdownMenuItem(value: 'display_id', child: Text('Sort by Display ID')),
//             ],
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: const InputDecoration(
//                 hintText: 'Search by email',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (query) {
//                 _filterProfiles(query);
//                 setState(() {}); // Force UI update
//               },
//             ),
//           ),
//           if (_searchController.text.isNotEmpty)
//             Align(
//               alignment: Alignment.centerRight,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: TextButton(
//                   onPressed: () {
//                     _searchController.clear();
//                     setState(() => _filteredProfiles = _profiles);
//                   },
//                   child: const Text('Clear Search'),
//                 ),
//               ),
//             ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _filteredProfiles.isEmpty
//                     ? const Center(child: Text('No profiles found.'))
//                     : ListView.builder(
//                         itemCount: _filteredProfiles.length,
//                         itemBuilder: (context, index) {
//                           final profile = _filteredProfiles[index];
//
//                           if (profile.id.toString() == _currentUserId) return const SizedBox.shrink();
//
//                           final bool isConnected = _connectedUsers.contains(profile.id.toString());
//
//                           return ListTile(
//                             leading: profile.avatarUrl != null ? CircleAvatar(backgroundImage: NetworkImage(profile.avatarUrl!)) : const CircleAvatar(child: Icon(Icons.person)),
//                             title: Text(profile.displayId ?? 'Unknown User'),
//                             subtitle: Text(profile.email ?? 'No Email'),
//                             trailing: isConnected
//                                 ? const Text('Connected', style: TextStyle(color: Colors.green))
//                                 : ElevatedButton(
//                                     onPressed: () => _sendConnectionRequest(profile.id.toString()),
//                                     child: const Text('Connect'),
//                                   ),
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }
// }
