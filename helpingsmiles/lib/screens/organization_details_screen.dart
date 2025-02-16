import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationDetailsScreen extends StatefulWidget {
  final String organizationId;
  final String organizationName;

  const OrganizationDetailsScreen({super.key, required this.organizationId, required this.organizationName});

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
        missions = _convertToList(doc.data()?['missions']);
        objectives = _convertToList(doc.data()?['objectives']);
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
          .map((doc) => doc.data().containsKey('name') ? doc['name'] as String : "Unnamed Event")
          .toList();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.organizationName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileSection(Icons.phone, "Phone", phone ?? "Not specified"),
            _buildProfileSection(Icons.date_range, "Date Created", date ?? "Not specified"),
            _buildProfileList(Icons.flag, "Mission", missions),
            _buildProfileList(Icons.list, "Objectives", objectives),
            _buildProfileList(Icons.calendar_today, "Upcoming Events", upcomingEvents),
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
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "$title: ",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    TextSpan(
                      text: content,
                      style: const TextStyle(fontSize: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: Colors.red),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
            ]),
            ...items.map((item) => Text("• $item", style: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}
