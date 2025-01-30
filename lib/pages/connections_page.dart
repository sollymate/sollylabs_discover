import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sollylabs_discover/auth/auth_service.dart';
import 'package:sollylabs_discover/database/models/connection_profile.dart';
import 'package:sollylabs_discover/database/services/connection_service.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> with SingleTickerProviderStateMixin {
  late ConnectionService _connectionService;
  List<ConnectionProfile> _connections = [];
  List<ConnectionProfile> _blockedConnections = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _connectionService = Provider.of<ConnectionService>(context, listen: false);
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
      final userId = Provider.of<AuthService>(context, listen: false).currentUser!.id;
      final connections = await _connectionService.getConnections(userId);

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

  Future<void> _blockConnection(String connectionId) async {
    try {
      await _connectionService.blockConnection(connectionId);
      setState(() {
        _connections.removeWhere((c) => c.connectionId.toString() == connectionId);
      });
      _fetchConnections();
    } catch (e) {
      _showErrorSnackBar('Error blocking user: $e');
    }
  }

  Future<void> _unblockConnection(String connectionId) async {
    try {
      await _connectionService.unblockConnection(connectionId);
      setState(() {
        _blockedConnections.removeWhere((c) => c.connectionId.toString() == connectionId);
      });
      _fetchConnections();
    } catch (e) {
      _showErrorSnackBar('Error unblocking user: $e');
    }
  }

  Future<void> _confirmRemoveConnection(String connectionId) async {
    try {
      await _connectionService.removeConnection(connectionId);
      setState(() {
        _connections.removeWhere((c) => c.connectionId.toString() == connectionId);
        _blockedConnections.removeWhere((c) => c.connectionId.toString() == connectionId);
      });

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection removed successfully')));
    } catch (e) {
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
          title: Text(connection.otherUserEmail),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (connection.otherUserDisplayId.isNotEmpty == true) Text('Display ID: ${connection.otherUserDisplayId}'),
              if (connection.otherUserFullName.isNotEmpty == true) Text('Full Name: ${connection.otherUserFullName}'),
              if (connection.otherUserWebsite.isNotEmpty == true) Text('Website: ${connection.otherUserWebsite}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isBlockedList)
                IconButton(
                  icon: const Icon(Icons.lock_open, color: Colors.green),
                  onPressed: () => _unblockConnection(connection.connectionId.toString()),
                )
              else ...[
                IconButton(
                  icon: const Icon(Icons.block, color: Colors.red),
                  onPressed: () => _blockConnection(connection.connectionId.toString()),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.grey),
                  onPressed: () => _confirmRemoveConnection(connection.connectionId.toString()),
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
        title: const Text('Connections'),
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
//
// class ConnectionsPage extends StatefulWidget {
//   const ConnectionsPage({super.key});
//
//   @override
//   State<ConnectionsPage> createState() => _ConnectionsPageState();
// }
//
// class _ConnectionsPageState extends State<ConnectionsPage> with SingleTickerProviderStateMixin {
//   late ConnectionService _connectionService;
//   List<ConnectionProfile> _connections = [];
//   List<ConnectionProfile> _blockedConnections = [];
//   bool _isLoading = true;
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _connectionService = Provider.of<ConnectionService>(context, listen: false);
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
//       final userId = Provider.of<AuthService>(context, listen: false).currentUser!.id;
//       final connections = await _connectionService.getConnections(userId);
//
//       setState(() {
//         _connections = connections.where((c) => !c.isBlocked).toList(); // Active connections
//         _blockedConnections = connections.where((c) => c.isBlocked).toList(); // Blocked connections
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching connections: $e')));
//       }
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _blockConnection(String connectionId) async {
//     await _connectionService.blockConnection(connectionId);
//     _fetchConnections();
//   }
//
//   Future<void> _unblockConnection(String connectionId) async {
//     await _connectionService.unblockConnection(connectionId);
//     _fetchConnections();
//   }
//
//   Widget _buildConnectionList(List<ConnectionProfile> connections, bool isBlockedList) {
//     return ListView.builder(
//       itemCount: connections.length,
//       itemBuilder: (context, index) {
//         final connection = connections[index];
//         return ListTile(
//           title: Text(connection.otherUserEmail ?? 'No Email'),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (connection.otherUserDisplayId?.isNotEmpty == true) Text('Display ID: ${connection.otherUserDisplayId}'),
//               if (connection.otherUserFullName?.isNotEmpty == true) Text('Full Name: ${connection.otherUserFullName}'),
//               if (connection.otherUserWebsite?.isNotEmpty == true) Text('Website: ${connection.otherUserWebsite}'),
//               IconButton(
//                 icon: const Icon(Icons.remove_circle, color: Colors.red),
//                 onPressed: () => _confirmRemoveConnection(connection.connectionId.toString()),
//               ),
//             ],
//           ),
//           trailing: isBlockedList
//               ? IconButton(
//                   icon: const Icon(Icons.lock_open, color: Colors.green),
//                   onPressed: () => _unblockConnection(connection.connectionId.toString()),
//                 )
//               : IconButton(
//                   icon: const Icon(Icons.block, color: Colors.red),
//                   onPressed: () => _blockConnection(connection.connectionId.toString()),
//                 ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Connections'),
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
// // class ConnectionsPage extends StatefulWidget {
// //   const ConnectionsPage({super.key});
// //
// //   @override
// //   State<ConnectionsPage> createState() => _ConnectionsPageState();
// // }
// //
// // class _ConnectionsPageState extends State<ConnectionsPage> {
// //   late ConnectionService _connectionService;
// //   List<ConnectionProfile> _connections = [];
// //   bool _isLoading = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _connectionService = Provider.of<ConnectionService>(context, listen: false);
// //     _fetchConnections();
// //   }
// //
// //   Future<void> _fetchConnections() async {
// //     setState(() => _isLoading = true);
// //     try {
// //       final userId = Provider.of<AuthService>(context, listen: false).currentUser!.id;
// //       final connections = await _connectionService.getConnections(userId);
// //       setState(() => _connections = connections);
// //     } catch (e) {
// //       debugPrint('Error fetching connections: $e');
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Error fetching connections: $e')),
// //         );
// //       }
// //     } finally {
// //       if (mounted) setState(() => _isLoading = false);
// //     }
// //   }
// //
// //   void _confirmRemoveConnection(String connectionId) async {
// //     try {
// //       bool isRemoved = await _connectionService.removeConnection(connectionId);
// //
// //       if (isRemoved) {
// //         setState(() {
// //           _connections.removeWhere((connection) => connection.connectionId.toString() == connectionId);
// //         });
// //
// //         if (mounted) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text('Connection removed successfully')),
// //           );
// //         }
// //       } else {
// //         if (mounted) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text('Failed to remove connection. Please try again.')),
// //           );
// //         }
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Error removing connection: $e')),
// //         );
// //       }
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Connections')),
// //       body: _isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : _connections.isEmpty
// //               ? const Center(child: Text('No connections found.'))
// //               : ListView.builder(
// //                   itemCount: _connections.length,
// //                   itemBuilder: (context, index) {
// //                     final connection = _connections[index];
// //                     // return Text('ABC');
// //
// //                     return ListTile(
// //                       title: Text(connection.otherUserEmail.isNotEmpty ? connection.otherUserEmail : 'No Email'),
// //                       subtitle: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           if (connection.otherUserDisplayId.isNotEmpty == true) Text('Display ID: ${connection.otherUserDisplayId}'),
// //                           if (connection.otherUserFullName.isNotEmpty == true) Text('Full Name: ${connection.otherUserFullName}'),
// //                           if (connection.otherUserWebsite.isNotEmpty == true) Text('Website: ${connection.otherUserWebsite}'),
// //                         ],
// //                       ),
// //                       trailing: IconButton(
// //                         icon: const Icon(Icons.remove_circle, color: Colors.red),
// //                         onPressed: () => _confirmRemoveConnection(connection.connectionId.toString()),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //     );
// //   }
// // }
