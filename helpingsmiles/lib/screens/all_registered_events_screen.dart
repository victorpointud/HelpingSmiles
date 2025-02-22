import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllRegisteredEventsScreen extends StatefulWidget {
  const AllRegisteredEventsScreen({super.key});

  @override
  _AllRegisteredEventsScreenState createState() => _AllRegisteredEventsScreenState();
}

class _AllRegisteredEventsScreenState extends State<AllRegisteredEventsScreen> {
  List<Map<String, dynamic>> registeredEvents = [];

  @override
  void initState() {
    super.initState();
    _loadRegisteredEvents();
  }

  Future<void> _loadRegisteredEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('registrations')
          .where('userId', isEqualTo: user.uid)
          .get();

      List<Map<String, dynamic>> tempEvents = [];

      for (var doc in querySnapshot.docs) {
        final eventRef = doc.reference.parent.parent;
        if (eventRef != null) {
          final eventDoc = await eventRef.get();
          if (eventDoc.exists) {
            tempEvents.add({
              'id': eventDoc.id,
              'name': eventDoc['name'] ?? "Unknown Event",
              'date': eventDoc['date'] ?? "No date provided",
              'location': eventDoc['location'] ?? "No location provided",
            });
          }
        }
      }

      setState(() {
        registeredEvents = tempEvents;
      });
    } catch (e) {
      print("Error loading registered events: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Registered Events")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: registeredEvents.length,
        itemBuilder: (context, index) {
          final event = registeredEvents[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(event["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${event["date"]} • ${event["location"]}"),
            ),
          );
        },
      ),
    );
  }
}