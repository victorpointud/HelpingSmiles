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
      try {
        final volunteerDoc = await FirebaseFirestore.instance
            .collection('volunteers')
            .doc(user.uid)
            .get();

        if (!volunteerDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Volunteer profile not found!")),
          );
          return;
        }

        final volunteerData = volunteerDoc.data() ?? {};
        final name = volunteerData['name'] ?? "Not specified";
        final email = user.email ?? "Not specified";
        final phone = volunteerData['phone'] ?? "Not specified";
        final skills = (volunteerData['skills'] as List<dynamic>?)?.cast<String>() ?? [];
        final interests = (volunteerData['interests'] as List<dynamic>?)?.cast<String>() ?? [];
        final location = volunteerData['location'] ?? "Not specified";
        final date = volunteerData['date'] ?? "Not specified";

        await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .collection('registrations')
            .doc(user.uid)
            .set({
          'userId': user.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'skills': skills,
          'interests': interests,
          'location': location,
          'date': date,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully registered for event!")),
        );
      } catch (e) {
        print("Error registering for event: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to register for event.")),
        );
      }
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
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _registerForEvent(event['id']),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 0, 0, 0), foregroundColor: Colors.white),
                      child: const Text("Register"),
                    ),
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