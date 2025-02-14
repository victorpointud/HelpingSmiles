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
  String? volunteerName;
  List<Map<String, dynamic>> organizations = [];

  @override
  void initState() {
    super.initState();
    _loadVolunteerData();
    _loadOrganizations();
    _loadUserData();
  }

  /// Cargar el nombre del voluntario autenticado
  Future<void> _loadVolunteerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? name = await AuthManager.getUserName(user.uid);
      setState(() {
        volunteerName = name ?? "Volunteer";
      });
    }
  }

Future<void> _loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String? userName = await AuthManager.getUserName(user.uid);
    setState(() {
      volunteerName = userName ?? "Volunteer";
    });
  }
}
  /// Cargar todas las organizaciones registradas en Firebase
  Future<void> _loadOrganizations() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('organizations').get();
      setState(() {
        organizations = querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print("Error loading organizations: $e");
    }
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $volunteerName!", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () => _navigate(context, const VolunteerProfileScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
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
      return const Center(child: Text("No organizations available."));
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
      child: ListTile(
        title: Text(org["name"] ?? "Unknown Organization", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(org["mission"] ?? "No mission available"),
        trailing: const Icon(Icons.business, color: Colors.red),
      ),
    );
  }
}
