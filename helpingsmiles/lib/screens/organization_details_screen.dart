import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationDetailsScreen extends StatefulWidget {
  final String organizationId;

  const OrganizationDetailsScreen({super.key, required this.organizationId});

  @override
  _OrganizationDetailsScreenState createState() => _OrganizationDetailsScreenState();
}

class _OrganizationDetailsScreenState extends State<OrganizationDetailsScreen> {
  String? name;
  String? mission;
  List<String> volunteerTypes = [];
  List<String> locations = [];
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
        name = doc.data()?['name'] ?? "Not specified";
        mission = (doc.data()?['missions'] is List && (doc.data()?['missions'] as List).isNotEmpty) ? (doc.data()?['missions'] as List).first : "Not specified";
        volunteerTypes = _convertToList(doc.data()?['volunteerTypes']);
        locations = _convertToList(doc.data()?['locations']);
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
          .map((doc) => doc.data().containsKey('title') ? doc['title'] as String : "Unnamed Event")
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
      appBar: AppBar(title: const Text("Organization Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileSection(Icons.business, "Organization", name ?? "Not specified"),
            _buildProfileSection(Icons.flag, "Mission", mission ?? "Not specified"),
            _buildProfileList(Icons.people, "Volunteer Types", volunteerTypes),
            _buildProfileList(Icons.location_on, "Locations", locations),
            _buildProfileList(Icons.event, "Upcoming Events", upcomingEvents),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                    ),
                    TextSpan(
                      text: content,
                      style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.black),
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
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            ]),
            ...items.map((item) => Text("• $item", style: const TextStyle(fontSize: 16, color: Colors.black))),
          ],
        ),
      ),
    );
  }
}
