import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventListScreen extends StatefulWidget {
  final String organizationId;

  const EventListScreen({super.key, required this.organizationId});

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('organizationId', isEqualTo: widget.organizationId)
        .get();

    setState(() {
      events = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? "Unnamed Event",
          'description': data['description'] ?? "No description available",
          'date': data['date'] ?? "No date specified",
          'location': data['location'] ?? "No location specified",
        };
      }).toList();
    });
  }

  Future<void> _registerForEvent(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('registrations')
          .doc(user.uid)
          .set({'userId': user.uid, 'timestamp': FieldValue.serverTimestamp()});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully registered for event!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upcoming Events")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 5),
                  Text("📅 Date: ${event['date']}"),
                  Text("📍 Location: ${event['location']}"),
                  const SizedBox(height: 5),
                  Text(event['description']),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _registerForEvent(event['id']),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 221, 42, 42), foregroundColor: Colors.white),
                    child: const Text("Register"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}