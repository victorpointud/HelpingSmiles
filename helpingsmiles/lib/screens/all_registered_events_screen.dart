import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registered_event_info_screen.dart'; 

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
      List<Map<String, dynamic>> tempEvents = [];

      final eventsSnapshot = await FirebaseFirestore.instance.collection('events').get();

      for (var eventDoc in eventsSnapshot.docs) {
        final eventId = eventDoc.id;

        final registrationRef = eventDoc.reference.collection('registrations').doc(user.uid);
        final registrationDoc = await registrationRef.get();

        if (registrationDoc.exists) {
          tempEvents.add({
            'id': eventId,
            'name': eventDoc['name'] ?? "Unknown Event",
            'date': eventDoc['date'] ?? "No date provided",
            'location': eventDoc['location'] ?? "No location provided",
          });
        }
      }

      if (!mounted) return;

      setState(() {
        registeredEvents = tempEvents;
      });

    } catch (e) {
      print("Error loading registered events: $e");
    }
  }

  void _navigateToEventInfo(String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisteredEventInfoScreen(eventId: eventId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "My Registered Events",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
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
              child: registeredEvents.isEmpty
                  ? const Center(child: Text("You are not registered in any events.", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: registeredEvents.length,
                      itemBuilder: (context, index) {
                        final event = registeredEvents[index];
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
      onTap: () => _navigateToEventInfo(event["id"]),
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
              Text("${event["date"]} • ${event["location"]}", style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 5),
              const Text("Click to see more info", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}