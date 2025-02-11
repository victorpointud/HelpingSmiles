import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../managers/auth_manager.dart';
import 'organization_profile_screen.dart';
import 'login_screen.dart';
import 'add_activity_screen.dart'; // New screen for adding activities

class OrganizationHomeScreen extends StatefulWidget {
  const OrganizationHomeScreen({super.key});

  @override
  _OrganizationHomeScreenState createState() => _OrganizationHomeScreenState();
}

class _OrganizationHomeScreenState extends State<OrganizationHomeScreen> {
  String? organizationName;

  @override
  void initState() {
    super.initState();
    _loadOrganizationData();
  }

  Future<void> _loadOrganizationData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? orgName = await AuthManager.getOrganizationName(user.uid);
      setState(() {
        organizationName = orgName ?? "Unknown Organization";
      });
    }
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(organizationName ?? "Loading..."),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white), 
            onPressed: () => _navigate(context, const OrganizationProfileScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), 
            onPressed: () async {
              await AuthManager.logoutUser();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, $organizationName!", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildSectionTitle("Upcoming Events"),
            _buildEventCard("Charity Fundraiser", "Feb 18, 3 PM"),
            _buildEventCard("Health Camp", "Feb 22, 9 AM"),
            const SizedBox(height: 20),
            _buildSectionTitle("Pending Volunteer Requests"),
            _buildVolunteerRequest("John Doe", "Community Cleanup"),
            _buildVolunteerRequest("Alice Smith", "Food Drive"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => _navigate(context, const AddActivityScreen()),
        child: const Icon(Icons.add, color: Colors.white),
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
}
