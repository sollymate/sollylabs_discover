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
      debugPrint('Error fetching connections: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching connections: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeConnection(String connectionId) async {
    try {
      await _connectionService.removeConnection(connectionId);

      setState(() {
        _connections.removeWhere((c) => c.connectionId == connectionId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection removed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing connection: $e')),
        );
      }
    }
  }

  void _confirmRemoveConnection(String connectionId) async {
    try {
      bool isRemoved = await _connectionService.removeConnection(connectionId);

      if (isRemoved) {
        setState(() {
          _connections.removeWhere((connection) => connection.connectionId.toString() == connectionId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connection removed successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to remove connection. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing connection: $e')),
        );
      }
    }
  }

  // void _confirmRemoveConnection(String connectionId) async {
  //   try {
  //     await _connectionService.removeConnection(connectionId);
  //
  //     setState(() {
  //       _connections.removeWhere((connection) => connection.connectionId.toString() == connectionId);
  //     });
  //
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Connection removed successfully')),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error removing connection: $e')),
  //       );
  //     }
  //   }
  // }

  // void _confirmRemoveConnection(String connectionId) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Remove Connection'),
  //       content: const Text('Are you sure you want to remove this connection?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _removeConnection(connectionId);
  //           },
  //           child: const Text('Remove', style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
                    // return Text('ABC');

                    return ListTile(
                      title: Text(connection.otherUserEmail.isNotEmpty ? connection.otherUserEmail : 'No Email'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (connection.otherUserDisplayId.isNotEmpty == true) Text('Display ID: ${connection.otherUserDisplayId}'),
                          if (connection.otherUserFullName.isNotEmpty == true) Text('Full Name: ${connection.otherUserFullName}'),
                          if (connection.otherUserWebsite.isNotEmpty == true) Text('Website: ${connection.otherUserWebsite}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _confirmRemoveConnection(connection.connectionId.toString()),
                      ),
                    );
                  },
                ),
    );
  }
}
