import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vol_info_screen.dart';

class RegisteredVolInfoScreen extends StatefulWidget {
  const RegisteredVolInfoScreen({super.key});

  @override
  _RegisteredVolInfoScreenState createState() => _RegisteredVolInfoScreenState();
}

class _RegisteredVolInfoScreenState extends State<RegisteredVolInfoScreen> {
  List<Map<String, dynamic>> registeredVolunteers = [];
  int totalVolunteers = 0;

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

        totalVolunteers = registeredVolunteers.length;
      });
    } catch (e) {
      print("Error loading volunteers: $e");
    }
  }

  void _navigateToVolunteerDetails(String volunteerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VolInfoScreen(volunteerId: volunteerId),
      ),
    );
  }

  void _confirmDeleteVolunteer(String volunteerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Volunteer", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        content: const Text("Are you sure you want to remove this volunteer from your organization? This action cannot be undone.",
            style: TextStyle(fontSize: 16, color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteVolunteer(volunteerId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVolunteer(String volunteerId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final orgRef = FirebaseFirestore.instance.collection('organizations').doc(user.uid);
      await orgRef.collection('registrations').doc(volunteerId).delete();

      setState(() {
        registeredVolunteers.removeWhere((volunteer) => volunteer['id'] == volunteerId);
        totalVolunteers = registeredVolunteers.length;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Volunteer removed successfully")),
      );
    } catch (e) {
      print("Error deleting volunteer: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting volunteer: $e")),
      );
    }
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
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: Colors.red, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people, color: Colors.red, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            "Total Volunteers: $totalVolunteers",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerCard(Map<String, dynamic> volunteer) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.red, width: 2),
      ),
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: -2,
            left: 320,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _confirmDeleteVolunteer(volunteer["id"]),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _navigateToVolunteerDetails(volunteer["id"]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(volunteer["name"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      Text("${volunteer["email"]} • ${volunteer["phone"]}", style: const TextStyle(color: Colors.black)),
                      const Text("Tap to view details.", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}