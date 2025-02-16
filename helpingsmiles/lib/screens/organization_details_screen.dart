import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/event_list_screen.dart';

class OrganizationDetailsScreen extends StatefulWidget {
  final String organizationId;
  final String organizationName;

  const OrganizationDetailsScreen({
    super.key,
    required this.organizationId,
    required this.organizationName,
  });

  @override
  _OrganizationDetailsScreenState createState() => _OrganizationDetailsScreenState();
}

class _OrganizationDetailsScreenState extends State<OrganizationDetailsScreen> {
  String? phone;
  String? date;
  List<String> missions = [];
  List<String> objectives = [];
  List<String> upcomingEvents = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizationData();
    _loadUpcomingEvents();
  }

  Future<void> _loadOrganizationData() async {
    final doc = await FirebaseFirestore.instance.collection('organizations').doc(widget.organizationId).get();
    if (doc.exists) {
      setState(() {
        phone = doc.data()?['phone'] ?? "Not specified";
        date = doc.data()?['date'] ?? "Not specified";
        missions = (doc.data()?['missions'] as List<dynamic>?)?.cast<String>() ?? [];
        objectives = (doc.data()?['objectives'] as List<dynamic>?)?.cast<String>() ?? [];
      });
    }
  }

  Future<void> _loadUpcomingEvents() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('organizationId', isEqualTo: widget.organizationId)
        .get();

    setState(() {
      upcomingEvents = querySnapshot.docs
          .map((doc) => doc['name'] ?? "Unnamed Event")
          .whereType<String>()
          .toList();
    });
  }

  void _navigateToEventList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventListScreen(organizationId: widget.organizationId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.organizationName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(Icons.phone, "Phone", phone ?? "Not specified"),
            _buildProfileSection(Icons.calendar_today, "Date Created", date ?? "Not specified"),
            _buildProfileList(Icons.flag, "Mission", missions),
            _buildProfileList(Icons.list, "Objectives", objectives),

            // 📌 Botón para ver los eventos
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _navigateToEventList,
              icon: const Icon(Icons.event),
              label: const Text("View Upcoming Events"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 221, 38, 38), foregroundColor: Colors.white),
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
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content),
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