import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sollylabs_discover/src/core/navigation/route_names.dart';

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
                context.push(RouteNames.userPage);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.group),
              label: const Text('People'),
              onPressed: () {
                context.push(RouteNames.peoplePage);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.link), // ✅ New icon for NetworkPage
              label: const Text('Network'), // ✅ Button for NetworkPage
              onPressed: () {
                context.push(RouteNames.networkPage);
              },
            ),
          ],
        ),
      ),
    );
  }
}
