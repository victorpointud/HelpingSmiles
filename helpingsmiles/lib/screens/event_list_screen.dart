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
          _showErrorDialog("Volunteer profile not found!");
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

        _showSuccessDialog(); 

      } catch (e) {
        print("Error registering for event: $e");
        _showErrorDialog("Failed to register for event.");
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registration Successful!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        content: const Text("You have successfully registered for this event.", style: TextStyle(fontSize: 16, color: Colors.black)),
        actions: [
          Center(child: CircularProgressIndicator(color: Colors.red)), 
        ],
      ),
    );

    
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); 
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text(message, style: const TextStyle(fontSize: 16, color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Upcoming Events",
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: events.isEmpty
                    ? [
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 50),
                            child: Text(
                              "No upcoming events. Stay tuned!",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ]
                    : events.map((event) => _buildEventCard(event)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['name'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.red),
                const SizedBox(width: 10),
                const Text("Date: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                Expanded(child: Text(event['date'], style: const TextStyle(fontSize: 16, color: Colors.black))),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 10),
                const Text("Location: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                Expanded(child: Text(event['location'], style: const TextStyle(fontSize: 16, color: Colors.black))),
              ],
            ),
            const SizedBox(height: 10),
            const Text("Description:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            Text(event['description'], style: const TextStyle(fontSize: 14, color: Colors.black)),
            const SizedBox(height: 15),
            Center(
              child: ElevatedButton(
                onPressed: () => _registerForEvent(event['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Register", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}