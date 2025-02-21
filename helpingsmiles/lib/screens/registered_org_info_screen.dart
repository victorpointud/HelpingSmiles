import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RegisteredOrgInfoScreen extends StatefulWidget {
  final String organizationId;
  final String organizationName;

  const RegisteredOrgInfoScreen({
    super.key,
    required this.organizationId,
    required this.organizationName,
  });

  @override
  _RegisteredOrgInfoScreenState createState() => _RegisteredOrgInfoScreenState();
}

class _RegisteredOrgInfoScreenState extends State<RegisteredOrgInfoScreen> {
  String? phone;
  String? date;
  String? mission;
  List<String> objectives = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizationData();
  }

  Future<void> _loadOrganizationData() async {
    final doc = await FirebaseFirestore.instance.collection('organizations').doc(widget.organizationId).get();
    if (doc.exists) {
      setState(() {
        phone = doc.data()?['phone'] ?? "Not specified";
        date = doc.data()?['date'] ?? "Not specified";
        mission = doc.data()?['mission'] ?? "Not specified";
        objectives = (doc.data()?['objectives'] as List<dynamic>?)?.cast<String>() ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.organizationName,
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(Icons.phone, "Phone", phone ?? "Not specified"),
                  _buildProfileSection(Icons.calendar_today, "Date Created", date ?? "Not specified"),
                  _buildProfileSection(Icons.flag, "Mission", mission ?? "Not specified"),
                  _buildProfileList(Icons.list, "Objectives", objectives),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(IconData icon, String title, String content) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: Text(content, style: const TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _buildProfileList(IconData icon, String title, List<String> items) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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