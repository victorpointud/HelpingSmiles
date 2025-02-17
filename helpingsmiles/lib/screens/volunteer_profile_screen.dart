import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../managers/edit_vol_profile_manager.dart';

class VolunteerProfileScreen extends StatefulWidget {
  const VolunteerProfileScreen({super.key});

  @override
  _VolunteerProfileScreenState createState() => _VolunteerProfileScreenState();
}

class _VolunteerProfileScreenState extends State<VolunteerProfileScreen> {
  String? name;
  String? email;
  String? phone;
  String? date;
  String? password;
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
        if (mounted) {
          setState(() {
            name = doc.data()?['name'] ?? "Not specified";
            email = doc.data()?['email'] ?? "Not specified";
            phone = doc.data()?['phone'] ?? "Not specified";
            date = doc.data()?['date'] ?? "Not specified";
            location = doc.data()?['location'] ?? "Not specified";
            password = doc.data()?['password'] ?? "Not specified";
            final dynamic interestsData = doc.data()?['interests'];
            interests = (interestsData is List) ? interestsData.cast<String>() : [];
            final dynamic skillsData = doc.data()?['skills'];
            skills = (skillsData is List) ? skillsData.cast<String>() : [];
          });
        }
      }
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditVolProfileManager()),
    ).then((result) {
      if (result == true) _loadVolunteerData();
    });
  }


  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black)),
        content: const Text("Are you sure you want to delete your account? This action cannot be undone.",  style: TextStyle(fontSize: 15, color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 9, 34, 225))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text("Delete", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 2, 2))),
          ),
        ],
      ),
    );
  }

   Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Primero eliminamos la organización de Firestore
        await FirebaseFirestore.instance.collection('organizations').doc(user.uid).delete();

        // Luego eliminamos al usuario de Firebase Auth
        await user.delete();

        // Regresar al login después de borrar la cuenta
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting account: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          name ?? "Volunteer Profile",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
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
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildProfileSection(Icons.person, "Name", name ?? "Not specified"),
                _buildProfileSection(Icons.email, "Email", email ?? "Not specified"),
                _buildProfileSection(Icons.phone, "Phone Number", phone ?? "Not specified"),
                _buildProfileSection(Icons.calendar_today, "Date of Birth", date ?? "Not specified"),
                _buildProfileSection(Icons.lock, "Password", password ?? "Not specified"),
                _buildProfileSection(Icons.location_on, "Location", location ?? "Not specified"),
                _buildProfileList(Icons.favorite, "Interests", interests),
                _buildProfileList(Icons.star, "Skills", skills),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _navigateToEditProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _confirmDeleteAccount,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("Delete Account", style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(IconData icon, String title, String content) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "$title: ",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    TextSpan(
                      text: content,
                      style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
                    ),
                  ],
                ),
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
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: Colors.red),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black))
            ]),
            ...items.map((item) => Text("• $item", style: const TextStyle(fontSize: 16, color: Colors.black))),
          ],
        ),
      ),
    );
  }
}