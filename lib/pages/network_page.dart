import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sollylabs_discover/auth/auth_service.dart';
import 'package:sollylabs_discover/database/models/network_model.dart';
import 'package:sollylabs_discover/database/services/network_service.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  late NetworkService _networkService;
  late String _currentUserId;
  List<NetworkModel> _networkConnections = [];
  List<NetworkModel> _blockedConnections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _networkService = Provider.of<NetworkService>(context, listen: false);
    _currentUserId = authService.currentUser!.id;
    _fetchNetwork();
  }

  Future<void> _fetchNetwork() async {
    setState(() => _isLoading = true);
    try {
      final connections = await _networkService.getNetwork(currentUserId: _currentUserId);
      setState(() {
        _networkConnections = connections.where((c) => !c.isBlocked).toList();
        _blockedConnections = connections.where((c) => c.isBlocked).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching network: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _blockUser(String otherUserId) async {
    try {
      await _networkService.blockUser(_currentUserId, otherUserId);
      _fetchNetwork(); // ✅ Refresh UI after blocking
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User blocked successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error blocking user: $e')),
      );
    }
  }

  Future<void> _unblockUser(String otherUserId) async {
    try {
      await _networkService.unblockUser(_currentUserId, otherUserId);
      _fetchNetwork(); // ✅ Refresh UI after unblocking
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User unblocked successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error unblocking user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _networkConnections.length,
                    itemBuilder: (context, index) {
                      final connection = _networkConnections[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(connection.otherUserDisplayId),
                        subtitle: Text(connection.otherUserEmail),
                        trailing: IconButton(
                          icon: const Icon(Icons.block, color: Colors.red),
                          onPressed: () => _blockUser(connection.otherUserId.toString()),
                        ),
                      );
                    },
                  ),
                ),
                if (_blockedConnections.isNotEmpty) const Divider(thickness: 1),
                if (_blockedConnections.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Blocked Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                if (_blockedConnections.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _blockedConnections.length,
                      itemBuilder: (context, index) {
                        final blockedUser = _blockedConnections[index];
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person_off)),
                          title: Text(blockedUser.otherUserDisplayId),
                          subtitle: Text(blockedUser.otherUserEmail),
                          trailing: IconButton(
                            icon: const Icon(Icons.lock_open, color: Colors.green),
                            onPressed: () => _unblockUser(blockedUser.otherUserId.toString()),
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

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sollylabs_discover/auth/auth_service.dart';
// import 'package:sollylabs_discover/database/models/network_model.dart';
// import 'package:sollylabs_discover/database/services/network_service.dart';
//
// class NetworkPage extends StatefulWidget {
//   const NetworkPage({super.key});
//
//   @override
//   State<NetworkPage> createState() => _NetworkPageState();
// }
//
// class _NetworkPageState extends State<NetworkPage> {
//   late NetworkService _networkService;
//   late String _currentUserId;
//   List<NetworkModel> _networkConnections = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     final authService = Provider.of<AuthService>(context, listen: false);
//     _networkService = Provider.of<NetworkService>(context, listen: false);
//     _currentUserId = authService.currentUser!.id;
//     _fetchNetwork();
//   }
//
//   Future<void> _fetchNetwork() async {
//     setState(() => _isLoading = true);
//     try {
//       final connections = await _networkService.getNetwork(currentUserId: _currentUserId);
//       setState(() => _networkConnections = connections);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching network: $e')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Network')),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _networkConnections.isEmpty
//               ? const Center(child: Text('No connections found.'))
//               : ListView.builder(
//                   itemCount: _networkConnections.length,
//                   itemBuilder: (context, index) {
//                     final connection = _networkConnections[index];
//                     return ListTile(
//                       leading: const CircleAvatar(child: Icon(Icons.person)),
//                       title: Text(connection.otherUserDisplayId),
//                       subtitle: Text(connection.otherUserEmail),
//                     );
//                   },
//                 ),
//     );
//   }
// }
