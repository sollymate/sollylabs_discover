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

class _ConnectionsPageState extends State<ConnectionsPage> {
  late ConnectionService _connectionService;
  List<ConnectionProfile> _connections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _connectionService = Provider.of<ConnectionService>(context, listen: false);
    _fetchConnections();
  }

  Future<void> _fetchConnections() async {
    setState(() => _isLoading = true);
    try {
      final userId = Provider.of<AuthService>(context, listen: false).currentUser!.id;
      final connections = await _connectionService.getConnections(userId);
      setState(() => _connections = connections);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching connections: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connections')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _connections.isEmpty
              ? const Center(child: Text('No connections found.'))
              : ListView.builder(
                  itemCount: _connections.length,
                  itemBuilder: (context, index) {
                    final connection = _connections[index];
                    return ListTile(
                      title: Text(connection.email), // ✅ Use `email` from `ConnectionProfile`
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Display ID: ${connection.displayId}'),
                          Text('Full Name: ${connection.fullName}'),
                          Text('Website: ${connection.website}'),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sollylabs_discover/auth/auth_service.dart';
// import 'package:sollylabs_discover/database/models/connection.dart';
// import 'package:sollylabs_discover/database/services/connection_service.dart';
//
// class ConnectionsPage extends StatefulWidget {
//   const ConnectionsPage({super.key});
//
//   @override
//   State<ConnectionsPage> createState() => _ConnectionsPageState();
// }
//
// class _ConnectionsPageState extends State<ConnectionsPage> {
//   late ConnectionService _connectionService;
//   List<Connection> _connections = [];
//   bool _isLoading = true;
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _connectionService = Provider.of<ConnectionService>(context, listen: false);
//     _fetchConnections();
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchConnections({String? searchQuery}) async {
//     setState(() => _isLoading = true);
//     try {
//       final userId = Provider.of<AuthService>(context, listen: false).currentUser!.id;
//       final connections = await _connectionService.getConnections(userId, searchQuery: searchQuery);
//       setState(() => _connections = connections);
//     } catch (e) {
//       String abc = e.toString();
//       print('Error fetching connections: $abc');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching connections: $e')),
//         );
//       }
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Connections')),
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
//               onChanged: (query) => _fetchConnections(searchQuery: query),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _connections.isEmpty
//                     ? const Center(child: Text('No connections found.'))
//                     : ListView.builder(
//                         itemCount: _connections.length,
//                         itemBuilder: (context, index) {
//                           final connection = _connections[index];
//                           return ListTile(
//                             title: Text(connection.userEmail),
//                             // Add more UI elements to display connection details
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:sollylabs_discover/auth/auth_service.dart';
// // import 'package:sollylabs_discover/database/models/connection.dart';
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
// //   List<Connection> _connections = [];
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
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Error fetching connections: $e')),
// //         );
// //       }
// //     } finally {
// //       setState(() => _isLoading = false);
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
// //                     return ListTile(
// //                       title: Text(connection.userEmail),
// //                     );
// //                   },
// //                 ),
// //     );
// //   }
// // }
