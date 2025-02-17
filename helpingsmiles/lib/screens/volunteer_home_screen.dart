import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../managers/auth_manager.dart';
import 'volunteer_profile_screen.dart';
import 'login_screen.dart';
import 'organization_details_screen.dart';

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
      if (mounted) {
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
            'id': doc.id,
            'name': data['name'] ?? "Unknown Organization",
            'mission': data['mission'] ?? "Unknown Mission",
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

  void _navigateToOrganizationDetails(String orgId, String orgName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrganizationDetailsScreen(
          organizationId: orgId,
          organizationName: orgName,
        ),
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false, // ✅ Elimina el botón de regreso
      title: Text(
        "Welcome, ${userName ?? 'Loading...'}!",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.person, color: Colors.black), onPressed: _navigateToProfile),
        IconButton(icon: const Icon(Icons.logout, color: Colors.red), onPressed: _logout),
      ],
      toolbarHeight: kToolbarHeight, // ✅ Ajusta la altura sin espacios extras
    ),
    body: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(color: Colors.black.withOpacity(0.3)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Registered Organizations"),
                  _buildOrganizationList(),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildOrganizationList() {
    if (organizations.isEmpty) {
      return const Center(child: Text("No registered organizations.", style: TextStyle(color: Colors.white)));
    }
    return Column(
      children: organizations.map((org) => _buildOrganizationCard(org)).toList(),
    );
  }

  Widget _buildOrganizationCard(Map<String, dynamic> org) {
    return GestureDetector(
      onTap: () => _navigateToOrganizationDetails(org["id"], org["name"]),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(org["name"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 5),
              Text(org["mission"], style: const TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 5),
              const Text("Click to see more info", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0))),
            ],
          ),
        ),
      ),
    );
  }
}