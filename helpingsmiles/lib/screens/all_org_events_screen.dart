import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../managers/edit_org_event_manager.dart';

class AllOrgEventsScreen extends StatefulWidget {
  final String organizationId;

  const AllOrgEventsScreen({super.key, required this.organizationId});

  @override
  _AllOrgEventsScreenState createState() => _AllOrgEventsScreenState();
}

class _AllOrgEventsScreenState extends State<AllOrgEventsScreen> {
  List<Map<String, dynamic>> orgEvents = [];
  String organizationName = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadOrganizationName();
    _loadOrgEvents();
  }

  Future<void> _loadOrganizationName() async {
    try {
      final orgDoc = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(widget.organizationId)
          .get();

      if (orgDoc.exists) {
        setState(() {
          organizationName = orgDoc.data()?['name'] ?? "Unnamed Organization";
        });
      } else {
        setState(() {
          organizationName = "Organization Not Found";
        });
      }
    } catch (e) {
      print("Error loading organization name: $e");
      setState(() {
        organizationName = "Error Loading Name";
      });
    }
  }

  Future<void> _loadOrgEvents() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('organizationId', isEqualTo: widget.organizationId)
          .get();

      setState(() {
        orgEvents = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? "Unnamed Event",
            'date': data['date'] ?? "No date provided",
            'location': data['location'] ?? "No location provided",
            'description': data['description'] ?? "No description available",
            'duration': data['duration'] ?? "N/A",
            'volunteerType': data['volunteerType'] ?? "Not specified",
          };
        }).toList();
      });
    } catch (e) {
      print("Error loading organization events: $e");
    }
  }

  void _navigateToEditEvent(String eventId, Map<String, dynamic> eventData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditOrgEventManager(eventId: eventId, eventData: eventData),
      ),
    ).then((updated) {
      if (updated == true) {
        _loadOrgEvents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          organizationName,
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: orgEvents.isEmpty
                  ? const Center(
                      child: Text(
                        "No events found for this organization.",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: orgEvents.length,
                      itemBuilder: (context, index) {
                        final event = orgEvents[index];
                        return _buildEventCard(event);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return GestureDetector(
      onTap: () => _navigateToEditEvent(event["id"], event),
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
              Text(event["name"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 5),
              _buildDetailRow(Icons.calendar_today, "Date", event["date"]),
              _buildDetailRow(Icons.location_on, "Location", event["location"]),
              _buildDetailRow(Icons.timelapse, "Duration", "${event["duration"]} hours"),
              _buildDetailRow(Icons.people, "Volunteer Type", event["volunteerType"]),
              const SizedBox(height: 10),
              const Text(
                "Description:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text(event["description"], style: const TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _navigateToEditEvent(event["id"], event),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Edit Event", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}