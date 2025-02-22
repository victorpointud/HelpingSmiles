import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllEventsScreen extends StatefulWidget {
  const AllEventsScreen({
    super.key}
    );

  @override
  _AllEventsScreenState createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('events').get();
    setState(() {
      events = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? "Unnamed Event",
          'date': data['date'] ?? "No date provided",
          'location': data['location'] ?? "No location provided",
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Events")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
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