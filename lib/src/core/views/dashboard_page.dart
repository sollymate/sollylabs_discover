import 'package:flutter/material.dart';
import 'package:sollylabs_discover/src/features/profile/views/user_page.dart';

import '../../features/network/views/network_page.dart';
import '../../features/people/views/people_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.account_circle),
              label: const Text('Account'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserPage()));
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.group),
              label: const Text('People'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PeoplePage()),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.link), // ✅ New icon for NetworkPage
              label: const Text('Network'), // ✅ Button for NetworkPage
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NetworkPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
