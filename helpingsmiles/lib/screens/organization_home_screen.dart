import 'package:flutter/material.dart';
import '../managers/auth_manager.dart';
import 'organization_profile_screen.dart';
import 'login_screen.dart';

class OrganizationHomeScreen extends StatelessWidget {
  const OrganizationHomeScreen({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Organization Dashboard"),
        actions: [
          IconButton(icon: const Icon(Icons.business), onPressed: () => _navigate(context, const OrganizationProfileScreen())),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await AuthManager.logoutUser();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrgProfileCard(),
            const SizedBox(height: 20),
            _buildSectionTitle("Upcoming Events"),
            _buildEventCard("Charity Fundraiser", "Feb 18, 3 PM"),
            _buildEventCard("Health Camp", "Feb 22, 9 AM"),
            const SizedBox(height: 20),
            _buildSectionTitle("Pending Volunteer Requests"),
            _buildVolunteerRequest("John Doe", "Community Cleanup"),
            _buildVolunteerRequest("Alice Smith", "Food Drive"),
            const SizedBox(height: 10),
            _buildNavigationButton(context, "Manage Profile", Icons.settings, const OrganizationProfileScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgProfileCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        
        title: const Text("Helping Hands Org", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Managing volunteer opportunities."),
        trailing: const Icon(Icons.volunteer_activism, color: Colors.red),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildEventCard(String event, String date) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(event, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: const Icon(Icons.event),
      ),
    );
  }

  Widget _buildVolunteerRequest(String name, String task) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Applied for: $task"),
        trailing: const Icon(Icons.check_circle_outline),
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
