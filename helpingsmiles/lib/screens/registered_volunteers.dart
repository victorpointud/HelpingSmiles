import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'volunteer_details_screen.dart';

class RegisteredVolunteersScreen extends StatefulWidget {
  const RegisteredVolunteersScreen({super.key});

  @override
  _RegisteredVolunteersScreenState createState() => _RegisteredVolunteersScreenState();
}

class _RegisteredVolunteersScreenState extends State<RegisteredVolunteersScreen> {
  List<Map<String, dynamic>> registeredVolunteers = [];

  @override
  void initState() {
    super.initState();
    _loadRegisteredVolunteers();
  }

  Future<void> _loadRegisteredVolunteers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final orgRef = FirebaseFirestore.instance.collection('organizations').doc(user.uid);
      final querySnapshot = await orgRef.collection('registrations').get();

      if (!mounted) return;
      setState(() {
        registeredVolunteers = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id, 
            'name': data['name'] ?? "Unknown Volunteer",
            'email': data['email'] ?? "No email provided",
            'phone': data['phone'] ?? "No phone provided",
          };
        }).toList();
      });
    } catch (e) {
      print("Error loading volunteers: $e");
    }
  }

  void _navigateToVolunteerDetails(String volunteerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VolunteersDetailsScreen(volunteerId: volunteerId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Registered Volunteers",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
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
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: registeredVolunteers.isEmpty
                  ? const Center(child: Text("No registered volunteers.", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: registeredVolunteers.length,
                      itemBuilder: (context, index) {
                        final volunteer = registeredVolunteers[index];
                        return _buildVolunteerCard(volunteer);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerCard(Map<String, dynamic> volunteer) {
    return GestureDetector(
      onTap: () => _navigateToVolunteerDetails(volunteer["id"]), 
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
              Text(volunteer["name"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              Text("${volunteer["email"]} • ${volunteer["phone"]}", style: const TextStyle(color: Colors.black)),
              const Text("Click to see more info", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color:Colors.black)), 
            ],
          ),
        ),
      ),
    );
  }
}