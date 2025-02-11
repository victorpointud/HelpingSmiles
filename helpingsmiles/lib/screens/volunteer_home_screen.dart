import 'package:flutter/material.dart';
import '../managers/auth_manager.dart';
import 'volunteer_profile_screen.dart';
import 'login_screen.dart';

class VolunteerHomeScreen extends StatelessWidget {
  const VolunteerHomeScreen({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer Home"),
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: () => _navigate(context, const VolunteerProfileScreen())),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await AuthManager.logoutUser();
            _navigate(context, const LoginScreen());
          }),
        ],
      ),
      body: const Center(child: Text("Welcome, Volunteer!")),
    );
  }
}
