import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sollylabs_discover/src/core/authentication/services/auth_service.dart';
import 'package:sollylabs_discover/src/features/people/models/people_profile.dart';
import 'package:sollylabs_discover/src/features/people/view_models/people_view_model.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  late String _currentUserId;
  late String _currentUserEmail;
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialized = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final peopleViewModel = Provider.of<PeopleViewModel>(context, listen: false);

    if (!_isInitialized) {
      _currentUserId = authService.currentUser!.id;
      _currentUserEmail = authService.currentUser!.email ?? 'No Email';
      peopleViewModel.fetchProfiles(currentUserId: _currentUserId);
      _isInitialized = true;
    }

    return Consumer<PeopleViewModel>(
      builder: (context, peopleViewModel, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Community')),
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
                  onChanged: (query) => peopleViewModel.fetchProfiles(
                    currentUserId: _currentUserId,
                    searchQuery: query,
                  ),
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
                        peopleViewModel.fetchProfiles(currentUserId: _currentUserId);
                      },
                      child: const Text('Clear Search'),
                    ),
                  ),
                ),

              // ✅ Profile List
              Expanded(
                child: peopleViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : peopleViewModel.profiles.isEmpty
                        ? const Center(child: Text('No profiles found.'))
                        : Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount: peopleViewModel.profiles.length,
                                  itemBuilder: (context, index) {
                                    final PeopleProfile profile = peopleViewModel.profiles[index];

                                    if (profile.userId.toString() == _currentUserId) return const SizedBox.shrink();

                                    final bool isConnected = profile.isConnected;
                                    final bool isBlocked = profile.isBlocked;
                                    final bool isBlockedBy = profile.isBlockedBy;

                                    return ListTile(
                                      leading: profile.avatarUrl != null ? CircleAvatar(backgroundImage: NetworkImage(profile.avatarUrl!)) : const CircleAvatar(child: Icon(Icons.person)),
                                      title: Text(profile.displayId ?? 'Unknown User'),
                                      subtitle: Text(profile.email ?? 'No Email'),
                                      trailing: isBlocked
                                          ? const Text('Blocked', style: TextStyle(color: Colors.red))
                                          : isBlockedBy
                                              ? const Text('Blocked By User', style: TextStyle(color: Colors.red))
                                              : isConnected
                                                  ? const Text('Connected', style: TextStyle(color: Colors.green))
                                                  : ElevatedButton(
                                                      onPressed: () {
                                                        peopleViewModel.sendConnectionRequest(
                                                          context: context,
                                                          currentUserId: _currentUserId,
                                                          targetUserId: profile.userId.toString(),
                                                        );
                                                      },
                                                      child: const Text('Connect'),
                                                    ),
                                    );
                                  },
                                ),
                              ),
                              if (peopleViewModel.hasMore) // ✅ Show "Load More" button if more profiles exist
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: ElevatedButton(
                                    onPressed: () => peopleViewModel.fetchProfiles(
                                      currentUserId: _currentUserId,
                                      isLoadMore: true,
                                    ),
                                    child: const Text('Load More'),
                                  ),
                                ),
                            ],
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sollylabs_discover/src/core/authentication/services/auth_service.dart';
// import 'package:sollylabs_discover/src/features/network/services/network_service.dart';
// import 'package:sollylabs_discover/src/features/people/models/people_profile.dart';
// import 'package:sollylabs_discover/src/features/people/services/people_service.dart';
// import 'package:sollylabs_discover/src/features/people/view_models/people_view_model.dart';
//
// class PeoplePage extends StatefulWidget {
//   const PeoplePage({super.key});
//
//   @override
//   State<PeoplePage> createState() => _PeoplePageState();
// }
//
// class _PeoplePageState extends State<PeoplePage> {
//   late PeopleViewModel _peopleViewModel;
//
//   late PeopleService _peopleService;
//   // late NetworkService _networkService;
//   // late ConnectionService _connectionService;
//   late NetworkService _networkService;
//   late String _currentUserId;
//   late String _currentUserEmail;
//   List<PeopleProfile> _profiles = [];
//   Set<String> _connectedUserIds = {};
//   Set<String> _blockedUserIds = {}; // ✅ Store blocked users
//   bool _isLoading = true;
//   final TextEditingController _searchController = TextEditingController();
//
//   final int _limit = 5; // Load 5 profiles per request
//   int _offset = 0;
//   bool _hasMore = true;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     final authService = Provider.of<AuthService>(context, listen: false);
//     _peopleService = Provider.of<PeopleService>(context, listen: false);
//     _networkService = Provider.of<NetworkService>(context, listen: false);
//     _currentUserId = authService.currentUser!.id;
//     _currentUserEmail = authService.currentUser!.email ?? 'No Email';
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final authService = Provider.of<AuthService>(context, listen: false);
//     _peopleService = Provider.of<PeopleService>(context, listen: false);
//     _networkService = Provider.of<NetworkService>(context, listen: false);
//     _currentUserId = authService.currentUser!.id;
//     _currentUserEmail = authService.currentUser!.email ?? 'No Email';
//     // _peopleViewModel.fetchProfiles(currentUserId: _currentUserId);
//
//     // _fetchProfiles();
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   /// ✅ Fetch profiles from `community` view
//   // Future<void> _fetchProfiles({bool isLoadMore = false}) async {
//   //   if (isLoadMore && !_hasMore) return; // Stop if no more profiles
//   //
//   //   if (!isLoadMore) _offset = 0; // ✅ Reset offset for new search
//   //
//   //   setState(() => _isLoading = true);
//   //   try {
//   //     final profiles = await _peopleService.getCommunityProfiles(
//   //       currentUserId: _currentUserId,
//   //       searchQuery: _searchController.text,
//   //       limit: _limit,
//   //       offset: _offset,
//   //     );
//   //
//   //     setState(() {
//   //       if (isLoadMore) {
//   //         _profiles.addAll(profiles);
//   //       } else {
//   //         _profiles = profiles;
//   //       }
//   //
//   //       _offset += _limit;
//   //       _hasMore = profiles.length == _limit;
//   //     });
//   //   } catch (e) {
//   //     if (mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: SelectableText('Error fetching profiles: $e')),
//   //       );
//   //     }
//   //   } finally {
//   //     setState(() => _isLoading = false);
//   //   }
//   // }
//   //
//   // Future<void> _sendConnectionRequest(String targetUserId) async {
//   //   try {
//   //     await _networkService.addConnection(_currentUserId, targetUserId);
//   //
//   //     setState(() {
//   //       _connectedUserIds.add(targetUserId); // ✅ Update UI immediately
//   //     });
//   //
//   //     // ✅ Re-fetch profiles to reflect connection change
//   //     _fetchProfiles(isLoadMore: false);
//   //
//   //     if (mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Connection Added!')),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     if (mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text('Error sending request: $e')),
//   //       );
//   //     }
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<PeopleViewModel>(builder: (context, peopleViewModel, child) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('People')),
//         body: Column(
//           children: [
//             // ✅ Show current user's email at the top
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               color: Colors.blue[100],
//               child: Text(
//                 'Your Email: $_currentUserEmail',
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//
//             // ✅ Search Bar
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: const InputDecoration(
//                   hintText: 'Search by email',
//                   prefixIcon: Icon(Icons.search),
//                   border: OutlineInputBorder(),
//                 ),
//                 // onChanged: (_) => _fetchProfiles(isLoadMore: false),
//                 onChanged: (query) => _peopleViewModel.fetchProfiles(
//                   currentUserId: _currentUserId,
//                   searchQuery: query,
//                 ),
//               ),
//             ),
//
//             if (_searchController.text.isNotEmpty)
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: TextButton(
//                     onPressed: () {
//                       _searchController.clear();
//                       _peopleViewModel.fetchProfiles(currentUserId: _currentUserId);
//
//                       // _fetchProfiles(isLoadMore: false);
//                     },
//                     child: const Text('Clear Search'),
//                   ),
//                 ),
//               ),
//
//             // ✅ Profile List
//             Expanded(
//               child: _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _profiles.isEmpty
//                       ? const Center(child: Text('No profiles found.'))
//                       : Column(
//                           children: [
//                             Expanded(
//                               child: ListView.builder(
//                                 itemCount: _profiles.length,
//                                 itemBuilder: (context, index) {
//                                   final profile = _profiles[index];
//
//                                   if (profile.userId.toString() == _currentUserId) return const SizedBox.shrink();
//
//                                   final bool isConnected = profile.isConnected;
//                                   final bool isBlocked = profile.isBlocked;
//                                   final bool isBlockedBy = profile.isBlockedBy;
//
//                                   return ListTile(
//                                     leading: profile.avatarUrl != null ? CircleAvatar(backgroundImage: NetworkImage(profile.avatarUrl!)) : const CircleAvatar(child: Icon(Icons.person)),
//                                     title: Text(profile.displayId ?? 'Unknown User'),
//                                     subtitle: Text(profile.email ?? 'No Email'),
//                                     trailing: isBlocked
//                                         ? const Text('Blocked', style: TextStyle(color: Colors.red))
//                                         : isBlockedBy
//                                             ? const Text('Blocked By User', style: TextStyle(color: Colors.red))
//                                             : isConnected
//                                                 ? const Text('Connected', style: TextStyle(color: Colors.green))
//                                                 : ElevatedButton(
//                                                     onPressed: () {
//                                                       _peopleViewModel.sendConnectionRequest(
//                                                         context: context,
//                                                         currentUserId: _currentUserId,
//                                                         targetUserId: profile.userId.toString(),
//                                                       );
//                                                     },
//                                                     // onPressed: () => _sendConnectionRequest(profile.userId.toString()),
//                                                     child: const Text('Connect'),
//                                                   ),
//                                   );
//                                 },
//                               ),
//                             ),
//                             if (_hasMore) // ✅ Show "Load More" button if more profiles exist
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(vertical: 10),
//                                 child: ElevatedButton(
//                                   onPressed: () => _peopleViewModel.fetchProfiles(
//                                     currentUserId: _currentUserId,
//                                     isLoadMore: true,
//                                   ),
//                                   // onPressed: () => _fetchProfiles(isLoadMore: true),
//
//                                   child: const Text('Load More'),
//                                 ),
//                               ),
//                           ],
//                         ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }
