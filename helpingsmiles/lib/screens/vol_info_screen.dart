import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VolInfoScreen extends StatefulWidget {
  final String volunteerId; // Se recibe el ID del voluntario

  const VolInfoScreen({super.key, required this.volunteerId});

  @override
  _VolInfoScreenState createState() => _VolInfoScreenState();
}

class _VolInfoScreenState extends State<VolInfoScreen> {
  String? name;
  String? email;
  String? phone;
  String? date;
  String? location;
  List<String> interests = [];
  List<String> skills = [];

  @override
  void initState() {
    super.initState();
    _loadVolunteerData();
  }

  Future<void> _loadVolunteerData() async {
    final doc = await FirebaseFirestore.instance.collection('volunteers').doc(widget.volunteerId).get();
    if (doc.exists) {
      if (mounted) {
        setState(() {
          name = doc.data()?['name'] ?? "Not specified";
          email = doc.data()?['email'] ?? "Not specified";
          phone = doc.data()?['phone'] ?? "Not specified";
          date = doc.data()?['date'] ?? "Not specified";
          location = doc.data()?['location'] ?? "Not specified";
          final dynamic interestsData = doc.data()?['interests'];
          interests = (interestsData is List) ? interestsData.cast<String>() : [];
          final dynamic skillsData = doc.data()?['skills'];
          skills = (skillsData is List) ? skillsData.cast<String>() : [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          name ?? "Volunteer Details",
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
          Container(color: Colors.black.withOpacity(0.3)),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileSection(Icons.person, "Name", name ?? "Not specified"),
                _buildProfileSection(Icons.email, "Email", email ?? "Not specified"),
                _buildProfileSection(Icons.phone, "Phone Number", phone ?? "Not specified"),
                _buildProfileSection(Icons.calendar_today, "Date of Birth", date ?? "Not specified"),
                _buildProfileSection(Icons.location_on, "Location", location ?? "Not specified"),
                _buildProfileList(Icons.favorite, "Interests", interests),
                _buildProfileList(Icons.star, "Skills", skills),
                const SizedBox(height: 20),
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