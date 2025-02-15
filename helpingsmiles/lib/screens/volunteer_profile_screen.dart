import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../managers/edit_vol_profile_manager.dart';

class VolunteerProfileScreen extends StatefulWidget {
  const VolunteerProfileScreen({super.key});

  @override
  _VolunteerProfileScreenState createState() => _VolunteerProfileScreenState();
}

class _VolunteerProfileScreenState extends State<VolunteerProfileScreen> {
  String? name;
  String? location;
  List<String> interests = [];
  List<String> skills = [];

  @override
  void initState() {
    super.initState();
    _loadVolunteerData();
  }

 Future<void> _loadVolunteerData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection('volunteers').doc(user.uid).get();
    if (doc.exists) {
      setState(() {
        name = doc['name'] ?? "Unknown";
        location = doc['location'] ?? "Not specified";

        // Ensure 'interests' is always a list
        final dynamic interestsData = doc['interests'];
        if (interestsData is List) {
          interests = interestsData.cast<String>();
        } else if (interestsData is String) {
          interests = [interestsData]; // Convert single string to list
        } else {
          interests = [];
        }

        // Ensure 'skills' is always a list
        final dynamic skillsData = doc['skills'];
        if (skillsData is List) {
          skills = skillsData.cast<String>();
        } else if (skillsData is String) {
          skills = [skillsData]; // Convert single string to list
        } else {
          skills = [];
        }
      });
    }
  }
}


  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditVolProfileManager()),
    ).then((result) {
      if (result == true) _loadVolunteerData(); // Refresh data after editing
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Volunteer Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildProfileList(Icons.favorite, "Interests", interests),
            _buildProfileList(Icons.star, "Skills", skills),
            _buildProfileSection(Icons.location_on, "Location", location ?? "Not specified"),
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

  Widget _buildProfileSection(IconData icon, String title, String content) {
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
                "$title:\n$content",
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
