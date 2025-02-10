import 'package:flutter/material.dart';
import '../managers/auth_manager.dart';
import 'organization_profile_screen.dart';
import 'login_screen.dart';

class OrganizationHomeScreen extends StatelessWidget {
  const OrganizationHomeScreen({super.key});

  void _logout(BuildContext context) async {
    await AuthManager.logoutUser();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _goToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrganizationProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _goToProfile(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: const Center(
        child: Text("Welcome, Organization!"),
      ),
    );
  }
}
