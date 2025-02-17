import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../managers/edit_org_profile_manager.dart';
import '../../../managers/auth_manager.dart';

class OrganizationProfileScreen extends StatefulWidget {
  const OrganizationProfileScreen({super.key});

  @override
  _OrganizationProfileScreenState createState() => _OrganizationProfileScreenState();
}

class _OrganizationProfileScreenState extends State<OrganizationProfileScreen> {
  String? name;
  String? email;
  String? phone;
  String? date;
  String? password;
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
          name = doc['name'] ?? "Not specified";
          phone = doc['phone'] ?? "Not specified";
          date = doc['date'] ?? "Not specified";
          password = doc['password']?? "Not specified"; 
          missions = _convertToList(doc['missions']);
          objectives = _convertToList(doc['objectives']);
          volunteerTypes = _convertToList(doc['volunteerTypes']);
          locations = _convertToList(doc['locations']);
        });
      }

      // 🚀 Cargar el email por separado
      String? userEmail = await AuthManager.getUserEmail(user.uid);
      setState(() {
        email = userEmail ?? "Not specified";
      });
    }
  }



  List<String> _convertToList(dynamic data) {
    if (data is List) {
      return data.whereType<String>().toList();
    } else if (data is String) {
      return [data];
    } else {
      return [];
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditOrgProfileManager()),
    ).then((result) {
      if (result == true) _loadOrganizationData(); // Refresh data after editing
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
            _buildProfileSection(Icons.business, "Name", name),
            _buildProfileSection(Icons.email, "Email", email),
            _buildProfileSection(Icons.phone, "Phone Number", phone),
            _buildProfileSection(Icons.calendar_today, "Date of Creation", date),
            _buildProfileList(Icons.lock, "Password", [password ?? "Not specified"]),
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

  Widget _buildProfileSection(IconData icon, String title, String? content) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "$title:\n${content ?? 'Not specified'}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
            ...items.map((item) => Text("• $item", style: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}
