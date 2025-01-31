import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sollylabs_discover/auth/auth_service.dart';
import 'package:sollylabs_discover/database/models/connection_profile.dart';
import 'package:sollylabs_discover/database/services/connection_service.dart';

class TestConnectionsPage extends StatefulWidget {
  const TestConnectionsPage({super.key});

  @override
  State<TestConnectionsPage> createState() => _TestConnectionsPageState();
}

class _TestConnectionsPageState extends State<TestConnectionsPage> with SingleTickerProviderStateMixin {
  late ConnectionService _connectionService;
  List<ConnectionProfile> _connections = [];
  List<ConnectionProfile> _blockedConnections = [];
  bool _isLoading = true;
  late TabController _tabController;
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _connectionService = Provider.of<ConnectionService>(context, listen: false);
    _currentUserId = authService.currentUser!.id;
    _tabController = TabController(length: 2, vsync: this);
    _fetchConnections();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchConnections() async {
    setState(() => _isLoading = true);
    try {
      final connections = await _connectionService.getConnections(_currentUserId);

      setState(() {
        _connections = connections.where((c) => !c.isBlocked).toList();
        _blockedConnections = connections.where((c) => c.isBlocked).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching connections: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _blockConnection(String otherUserId) async {
    debugPrint('🔹 Attempting to block user: $otherUserId');

    try {
      await _connectionService.blockUser(_currentUserId, otherUserId);
      debugPrint('✅ Successfully blocked user: $otherUserId');
      _fetchConnections();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User blocked successfully!')),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR blocking user: $e');
      debugPrint('📜 Stack Trace: $stackTrace');
      _showErrorSnackBar('Error blocking user: $e');
    }
  }

  Future<void> _unblockConnection(String otherUserId) async {
    debugPrint('🔹 Attempting to unblock user: $otherUserId');

    try {
      await _connectionService.unblockUser(_currentUserId, otherUserId);
      debugPrint('✅ Successfully unblocked user: $otherUserId');
      _fetchConnections();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User unblocked successfully!')),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR unblocking user: $e');
      debugPrint('📜 Stack Trace: $stackTrace');
      _showErrorSnackBar('Error unblocking user: $e');
    }
  }

  Future<void> _removeConnection(String otherUserId) async {
    debugPrint('🔹 Attempting to remove connection with: $otherUserId');

    try {
      await _connectionService.removeConnection(_currentUserId, otherUserId);
      debugPrint('✅ Successfully removed connection: $otherUserId');
      _fetchConnections();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection removed successfully!')),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR removing connection: $e');
      debugPrint('📜 Stack Trace: $stackTrace');
      _showErrorSnackBar('Error removing connection: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildConnectionList(List<ConnectionProfile> connections, bool isBlockedList) {
    if (connections.isEmpty) {
      return const Center(child: Text('No connections found.'));
    }

    return ListView.builder(
      itemCount: connections.length,
      itemBuilder: (context, index) {
        final connection = connections[index];

        return ListTile(
          leading: connection.otherUserWebsite != null && connection.otherUserWebsite!.startsWith('http') ? CircleAvatar(backgroundImage: NetworkImage(connection.otherUserWebsite!)) : const CircleAvatar(child: Icon(Icons.person)), // ✅ Default icon if avatar is missing
          title: Text(connection.otherUserEmail),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (connection.otherUserDisplayId.isNotEmpty) Text('Display ID: ${connection.otherUserDisplayId}'),
              if (connection.otherUserFullName.isNotEmpty) Text('Full Name: ${connection.otherUserFullName}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isBlockedList)
                IconButton(
                  icon: const Icon(Icons.lock_open, color: Colors.green),
                  onPressed: () => _unblockConnection(connection.otherUserId.toString()),
                )
              else ...[
                IconButton(
                  icon: const Icon(Icons.block, color: Colors.red),
                  onPressed: () => _blockConnection(connection.otherUserId.toString()),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.grey),
                  onPressed: () => _removeConnection(connection.otherUserId.toString()),
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Connections'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Connections'),
            Tab(text: 'Blocked Users'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildConnectionList(_connections, false), // Active connections
                _buildConnectionList(_blockedConnections, true), // Blocked connections
              ],
            ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sollylabs_discover/auth/auth_service.dart';
// import 'package:sollylabs_discover/database/models/connection_profile.dart';
// import 'package:sollylabs_discover/database/services/connection_service.dart';
// import 'package:sollylabs_discover/global/globals.dart';
//
// class TestConnectionsPage extends StatefulWidget {
//   const TestConnectionsPage({super.key});
//
//   @override
//   State<TestConnectionsPage> createState() => _TestConnectionsPageState();
// }
//
// class _TestConnectionsPageState extends State<TestConnectionsPage> with SingleTickerProviderStateMixin {
//   late ConnectionService _connectionService;
//   List<ConnectionProfile> _connections = [];
//   List<ConnectionProfile> _blockedConnections = [];
//   bool _isLoading = true;
//   late TabController _tabController;
//   late String _currentUserId;
//
//   @override
//   void initState() {
//     super.initState();
//     final authService = Provider.of<AuthService>(context, listen: false);
//     _connectionService = Provider.of<ConnectionService>(context, listen: false);
//     _currentUserId = authService.currentUser!.id;
//     _tabController = TabController(length: 2, vsync: this);
//     _fetchConnections();
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchConnections() async {
//     setState(() => _isLoading = true);
//     try {
//       final connections = await _connectionService.getConnections(_currentUserId);
//
//       setState(() {
//         _connections = connections.where((c) => !c.isBlocked).toList();
//         _blockedConnections = connections.where((c) => c.isBlocked).toList();
//       });
//     } catch (e, stackTrace) {
//       print('Error fetching connections: $e\n$stackTrace');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching connections: $e')));
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   // Future<void> _blockConnection(String connectionId) async {
//   //   try {
//   //     await _connectionService.blockConnection(connectionId);
//   //     _fetchConnections();
//   //   } catch (e) {
//   //     _showErrorSnackBar('Error blocking user: $e');
//   //   }
//   // }
//
//   Future<void> _blockConnection(String otherUserId) async {
//     try {
//       await _connectionService.blockUser(_currentUserId, otherUserId);
//
//       setState(() {
//         _connections.removeWhere((c) => c.otherUserId.toString() == otherUserId);
//       });
//
//       // ✅ Refresh connections to update UI
//       _fetchConnections();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User blocked successfully!')),
//       );
//     } catch (e) {
//       _showErrorSnackBar('Error blocking user: $e');
//     }
//   }
//
//   Future<void> _unblockConnection(String connectionId) async {
//     try {
//       await _connectionService.unblockConnection(connectionId);
//       _fetchConnections();
//     } catch (e) {
//       _showErrorSnackBar('Error unblocking user: $e');
//     }
//   }
//
//   // Future<void> _removeConnection(String connectionId) async {
//   //   try {
//   //     await _connectionService.removeConnection(connectionId);
//   //     _fetchConnections();
//   //   } catch (e) {
//   //     _showErrorSnackBar('Error removing connection: $e');
//   //   }
//   // }
//   Future<void> removeConnection(String userId, String otherUserId) async {
//     debugPrint('🔹 Checking if connection exists between $userId and $otherUserId');
//
//     final existingConnection = await globals.supabaseClient.from('connections').select().or('user1_id.eq.$userId,user2_id.eq.$userId').or('user1_id.eq.$otherUserId,user2_id.eq.$otherUserId').maybeSingle();
//
//     if (existingConnection == null) {
//       debugPrint('⚠️ No connection exists between $userId and $otherUserId.');
//       throw Exception('Connection does not exist.');
//     }
//
//     final response = await globals.supabaseClient.from('connections').delete().or('user1_id.eq.$userId,user2_id.eq.$userId').or('user1_id.eq.$otherUserId,user2_id.eq.$otherUserId');
//
//     if (response.error != null) {
//       debugPrint('❌ Error removing connection: ${response.error!.message}');
//       throw Exception('Failed to remove connection: ${response.error!.message}');
//     }
//
//     debugPrint('✅ Connection successfully removed between $userId and $otherUserId');
//   }
//
//   void _showErrorSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }
//
//   Widget _buildConnectionList(List<ConnectionProfile> connections, bool isBlockedList) {
//     if (connections.isEmpty) {
//       return const Center(child: Text('No connections found.'));
//     }
//
//     return ListView.builder(
//       itemCount: connections.length,
//       itemBuilder: (context, index) {
//         final connection = connections[index];
//         return ListTile(
//           leading: connection.otherUserWebsite != null && connection.otherUserWebsite!.startsWith('http') ? CircleAvatar(backgroundImage: NetworkImage(connection.otherUserWebsite!)) : const CircleAvatar(child: Icon(Icons.person)), // ✅ Use default icon if URL is invalid
//           title: Text(connection.otherUserEmail),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (connection.otherUserDisplayId != null && connection.otherUserDisplayId!.isNotEmpty) Text('Display ID: ${connection.otherUserDisplayId}'),
//               if (connection.otherUserFullName != null && connection.otherUserFullName!.isNotEmpty) Text('Full Name: ${connection.otherUserFullName}'),
//             ],
//           ),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (isBlockedList)
//                 IconButton(
//                   icon: const Icon(Icons.lock_open, color: Colors.green),
//                   onPressed: () => _unblockConnection(connection.otherUserId.toString()),
//                 )
//               else ...[
//                 IconButton(
//                   icon: const Icon(Icons.block, color: Colors.red),
//                   onPressed: () => _blockConnection(connection.otherUserId.toString()),
//                 ),
//                 // IconButton(
//                 //   icon: const Icon(Icons.remove_circle, color: Colors.grey),
//                 //   onPressed: () => _removeConnection(connection.otherUserId.toString()),
//                 // ),
//                 IconButton(
//                   icon: const Icon(Icons.remove_circle, color: Colors.grey),
//                   onPressed: () => removeConnection(_currentUserId, connection.otherUserId.toString()), // ✅ Pass both user IDs
//                 ),
//               ]
//             ],
//           ),
//         );
//
//         // return ListTile(
//         //   leading: connection.otherUserWebsite != null ? CircleAvatar(backgroundImage: NetworkImage(connection.otherUserWebsite!)) : const CircleAvatar(child: Icon(Icons.person)),
//         //   title: Text(connection.otherUserEmail),
//         //   subtitle: Column(
//         //     crossAxisAlignment: CrossAxisAlignment.start,
//         //     children: [
//         //       if (connection.otherUserDisplayId != null) Text('Display ID: ${connection.otherUserDisplayId}'),
//         //       if (connection.otherUserFullName != null) Text('Full Name: ${connection.otherUserFullName}'),
//         //     ],
//         //   ),
//         //   trailing: Row(
//         //     mainAxisSize: MainAxisSize.min,
//         //     children: [
//         //       if (isBlockedList)
//         //         IconButton(
//         //           icon: const Icon(Icons.lock_open, color: Colors.green),
//         //           onPressed: () => _unblockConnection(connection.connectionId.toString()),
//         //         )
//         //       else ...[
//         //         IconButton(
//         //           icon: const Icon(Icons.block, color: Colors.red),
//         //           onPressed: () => _blockConnection(connection.connectionId.toString()),
//         //         ),
//         //         IconButton(
//         //           icon: const Icon(Icons.remove_circle, color: Colors.grey),
//         //           onPressed: () => _removeConnection(connection.connectionId.toString()),
//         //         ),
//         //       ]
//         //     ],
//         //   ),
//         // );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Test Connections'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'Active Connections'),
//             Tab(text: 'Blocked Users'),
//           ],
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildConnectionList(_connections, false), // Active connections
//                 _buildConnectionList(_blockedConnections, true), // Blocked connections
//               ],
//             ),
//     );
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:sollylabs_discover/auth/auth_service.dart';
// // import 'package:sollylabs_discover/database/models/connection_profile.dart';
// // import 'package:sollylabs_discover/database/services/connection_service.dart';
// //
// // class TestConnectionsPage extends StatefulWidget {
// //   const TestConnectionsPage({super.key});
// //
// //   @override
// //   State<TestConnectionsPage> createState() => _TestConnectionsPageState();
// // }
// //
// // class _TestConnectionsPageState extends State<TestConnectionsPage> with SingleTickerProviderStateMixin {
// //   late ConnectionService _connectionService;
// //   List<ConnectionProfile> _connections = [];
// //   List<ConnectionProfile> _blockedConnections = [];
// //   bool _isLoading = true;
// //   late TabController _tabController;
// //   late String _currentUserId;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     final authService = Provider.of<AuthService>(context, listen: false);
// //     _connectionService = Provider.of<ConnectionService>(context, listen: false);
// //     _currentUserId = authService.currentUser!.id;
// //     _tabController = TabController(length: 2, vsync: this);
// //     _fetchConnections();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _fetchConnections() async {
// //     setState(() => _isLoading = true);
// //     try {
// //       final connections = await _connectionService.getConnections(_currentUserId);
// //
// //       setState(() {
// //         _connections = connections.where((c) => !c.isBlocked).toList();
// //         _blockedConnections = connections.where((c) => c.isBlocked).toList();
// //       });
// //     } catch (e) {
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching connections: $e')));
// //       }
// //     } finally {
// //       if (mounted) setState(() => _isLoading = false);
// //     }
// //   }
// //
// //   Future<void> _blockConnection(String connectionId) async {
// //     try {
// //       await _connectionService.blockConnection(connectionId);
// //       _fetchConnections();
// //     } catch (e) {
// //       _showErrorSnackBar('Error blocking user: $e');
// //     }
// //   }
// //
// //   Future<void> _unblockConnection(String connectionId) async {
// //     try {
// //       await _connectionService.unblockConnection(connectionId);
// //       _fetchConnections();
// //     } catch (e) {
// //       _showErrorSnackBar('Error unblocking user: $e');
// //     }
// //   }
// //
// //   Future<void> _removeConnection(String connectionId) async {
// //     try {
// //       await _connectionService.removeConnection(connectionId);
// //       _fetchConnections();
// //     } catch (e) {
// //       _showErrorSnackBar('Error removing connection: $e');
// //     }
// //   }
// //
// //   void _showErrorSnackBar(String message) {
// //     if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
// //     }
// //   }
// //
// //   Widget _buildConnectionList(List<ConnectionProfile> connections, bool isBlockedList) {
// //     if (connections.isEmpty) {
// //       return const Center(child: Text('No connections found.'));
// //     }
// //
// //     return ListView.builder(
// //       itemCount: connections.length,
// //       itemBuilder: (context, index) {
// //         final connection = connections[index];
// //         return ListTile(
// //           leading: connection.otherUserAvatarUrl != null ? CircleAvatar(backgroundImage: NetworkImage(connection.otherUserAvatarUrl!)) : const CircleAvatar(child: Icon(Icons.person)),
// //           title: Text(connection.otherUserEmail),
// //           subtitle: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               if (connection.otherUserDisplayId.isNotEmpty) Text('Display ID: ${connection.otherUserDisplayId}'),
// //               if (connection.otherUserFullName.isNotEmpty) Text('Full Name: ${connection.otherUserFullName}'),
// //               if (connection.otherUserWebsite.isNotEmpty) Text('Website: ${connection.otherUserWebsite}'),
// //             ],
// //           ),
// //           trailing: Row(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               if (isBlockedList)
// //                 IconButton(
// //                   icon: const Icon(Icons.lock_open, color: Colors.green),
// //                   onPressed: () => _unblockConnection(connection.connectionId.toString()),
// //                 )
// //               else ...[
// //                 IconButton(
// //                   icon: const Icon(Icons.block, color: Colors.red),
// //                   onPressed: () => _blockConnection(connection.connectionId.toString()),
// //                 ),
// //                 IconButton(
// //                   icon: const Icon(Icons.remove_circle, color: Colors.grey),
// //                   onPressed: () => _removeConnection(connection.connectionId.toString()),
// //                 ),
// //               ]
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Test Connections'),
// //         bottom: TabBar(
// //           controller: _tabController,
// //           tabs: const [
// //             Tab(text: 'Active Connections'),
// //             Tab(text: 'Blocked Users'),
// //           ],
// //         ),
// //       ),
// //       body: _isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : TabBarView(
// //               controller: _tabController,
// //               children: [
// //                 _buildConnectionList(_connections, false), // Active connections
// //                 _buildConnectionList(_blockedConnections, true), // Blocked connections
// //               ],
// //             ),
// //     );
// //   }
// // }
