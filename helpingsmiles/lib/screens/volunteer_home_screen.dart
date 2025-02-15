import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../managers/auth_manager.dart';
import 'volunteer_profile_screen.dart';
import 'login_screen.dart';

class VolunteerHomeScreen extends StatefulWidget {
  const VolunteerHomeScreen({super.key});

  @override
  _VolunteerHomeScreenState createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
  String? userName;
  List<Map<String, dynamic>> organizations = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadOrganizations();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? fullName = await AuthManager.getUserName(user.uid);
      if (mounted) { // ✅ Verifica si el widget aún está en pantalla
        setState(() {
          userName = fullName ?? "Unknown Volunteer";
        });
      }
    }
  }

  Future<void> _loadOrganizations() async {
  try {
    final querySnapshot = await FirebaseFirestore.instance.collection('organizations').get();

    setState(() {
      organizations = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] ?? "Unknown Organization",
          'mission': (data['missions'] as List<dynamic>?)?.join(", ") ?? "No mission available",
          'volunteerTypes': (data['volunteerTypes'] as List<dynamic>?)?.join(", ") ?? "No volunteer types specified",
          'locations': (data['locations'] != null && data['locations'] is List<dynamic>) 
              ? (data['locations'] as List<dynamic>).join(", ") 
              : "No location specified",
        };
      }).toList();
    });
  } catch (e) {
    print("Error loading organizations: $e");
  }
}

  void _logout() async {
    await AuthManager.logoutUser();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _navigateToProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const VolunteerProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${userName ?? 'Loading...'}!", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: _navigateToProfile),
          IconButton(icon: const Icon(Icons.logout, color: Colors.red), onPressed: _logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Registered Organizations"),
            _buildOrganizationList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildOrganizationList() {
    if (organizations.isEmpty) {
      return const Center(child: Text("No registered organizations."));
    }
    return Column(
      children: organizations.map((org) => _buildOrganizationCard(org)).toList(),
    );
  }

  Widget _buildOrganizationCard(Map<String, dynamic> org) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(org["name"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 5),
            Text("Mission: ${org["mission"]}", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 5),
            Text("Volunteer Types: ${org["volunteerTypes"]}", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 5),
            Text("Locations: ${org["locations"]}", style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
