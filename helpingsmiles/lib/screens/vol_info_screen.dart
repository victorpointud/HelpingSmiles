import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VolInfoScreen extends StatefulWidget {
  final String volunteerId; 

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
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Card(
                  color: Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileSection(Icons.person, "Name", name ?? "Not specified"),
                        _buildProfileSection(Icons.email, "Email", email ?? "Not specified"),
                        _buildProfileSection(Icons.phone, "Phone", phone ?? "Not specified"),
                        _buildProfileSection(Icons.calendar_today, "Date of Birth", date ?? "Not specified"),
                        _buildProfileSection(Icons.location_on, "Location", location ?? "Not specified"),
                        _buildProfileList(Icons.favorite, "Interests", interests),
                        _buildProfileList(Icons.star, "Skills", skills),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                  TextSpan(
                    text: content,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList(IconData icon, String title, List<String> items) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 32, top: 5),
              child: Text("Not specified", style: TextStyle(fontSize: 16, color: Colors.black)),
            )
          else
            Column(
              children: items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 32, top: 5),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color.fromARGB(255, 0, 0, 0), size: 16),
                    const SizedBox(width: 5),
                    Expanded(child: Text(item, style: const TextStyle(fontSize: 16, color: Colors.black))),
                  ],
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

}