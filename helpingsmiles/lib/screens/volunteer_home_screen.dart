import 'package:flutter/material.dart';
import '../managers/auth_manager.dart';
import 'volunteer_profile_screen.dart';
import 'login_screen.dart';

class VolunteerHomeScreen extends StatelessWidget {
  const VolunteerHomeScreen({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer Dashboard"),
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: () => _navigate(context, const VolunteerProfileScreen())),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await AuthManager.logoutUser();
            _navigate(context, const LoginScreen());
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            _buildProfileCard(),

            const SizedBox(height: 20),

            // Upcoming Tasks
            _buildSectionTitle("Upcoming Activities"),
            _buildTaskCard("Community Cleanup", "Feb 12, 10 AM"),
            _buildTaskCard("Food Drive", "Feb 15, 2 PM"),

            const SizedBox(height: 20),

            // Progress Tracker
            _buildSectionTitle("Your Impact"),
            _buildProgressTracker(),

            const SizedBox(height: 10),

            // Buttons
            _buildNavigationButton(context, "View Profile", Icons.account_circle, const VolunteerProfileScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        
        title: const Text("Welcome, Volunteer!", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Your next task is coming up soon."),
        trailing: const Icon(Icons.volunteer_activism, color: Colors.red),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildTaskCard(String task, String date) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(task, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Widget _buildProgressTracker() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const Text("Activities Completed", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("5", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context, String text, IconData icon, Widget screen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _navigate(context, screen),
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
