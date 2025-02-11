import 'package:flutter/material.dart';
import '../managers/auth_manager.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final String title;
  const HomeScreen({super.key, required this.title});

  Future<void> _logout(BuildContext context) async {
    await AuthManager.logoutUser();
    _navigateToLogin(context);
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context)),
        ],
      ),
      body: const Center(child: Text("You're logged in!")),
    );
  }
}
