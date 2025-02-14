import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../managers/edit_org_profile_manager.dart';

class OrganizationProfileScreen extends StatefulWidget {
  const OrganizationProfileScreen({super.key});

  @override
  _OrganizationProfileScreenState createState() => _OrganizationProfileScreenState();
}

class _OrganizationProfileScreenState extends State<OrganizationProfileScreen> {
  List<String> objectives = [];
  List<String> volunteerTypes = [];
  List<String> locations = [];
  List<String> missions = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizationData();
  }

  Future<void> _loadOrganizationData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection('organizations').doc(user.uid).get();
    if (doc.exists) {
      setState(() {
        missions = _convertToList(doc.data()?['missions']);
        objectives = _convertToList(doc.data()?['objectives']);
        volunteerTypes = _convertToList(doc.data()?['volunteerTypes']);
        locations = _convertToList(doc.data()?['locations']);
      });
    }
  }
}

// Método corregido para evitar errores
List<String> _convertToList(dynamic data) {
  if (data is List) {
    return data.whereType<String>().toList(); // Convierte solo elementos tipo String
  } else if (data is String) {
    return [data]; // Convierte un solo String en una lista con un solo elemento
  } else {
    return []; // Retorna lista vacía si es nulo u otro tipo
  }
}


  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditOrgProfileManager()),
    ).then((result) {
      if (result == true) _loadOrganizationData(); // Refresh data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Organization Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color.fromARGB(255, 224, 63, 63),
              child: Icon(Icons.business, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildProfileList(Icons.flag, "Mission", missions),
            _buildProfileList(Icons.list, "Objectives", objectives),
            _buildProfileList(Icons.people, "Volunteer Types", volunteerTypes),
            _buildProfileList(Icons.location_on, "Locations", locations),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToEditProfile,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileList(IconData icon, String title, List<String> items) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: Colors.red), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
            ...items.map((item) => Text("• $item")),
          ],
        ),
      ),
    );
  }
}
