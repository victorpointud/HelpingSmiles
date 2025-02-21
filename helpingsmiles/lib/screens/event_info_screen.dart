import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventInfoScreen extends StatefulWidget {
  final String eventId;

  const EventInfoScreen({super.key, required this.eventId});

  @override
  _EventInfoScreenState createState() => _EventInfoScreenState();
}

class _EventInfoScreenState extends State<EventInfoScreen> {
  Map<String, dynamic>? eventData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('events').doc(widget.eventId).get();
      if (doc.exists) {
        setState(() {
          eventData = doc.data();
          isLoading = false;
        });
      } else {
        setState(() {
          eventData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading event data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Event Details",
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.red))
                : eventData == null
                    ? const Center(child: Text("Event not found.", style: TextStyle(color: Colors.white)))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Card(
                          color: Colors.white,
                          elevation: 10,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  eventData!["name"] ?? "Unnamed Event",
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                                ),
                                const SizedBox(height: 15),
                                _buildDetailRow(Icons.calendar_today, "Date", eventData!["date"] ?? "No date provided"),
                                _buildDetailRow(Icons.location_on, "Location", eventData!["location"] ?? "No location provided"),
                                _buildDetailRow(Icons.timelapse, "Duration", "${eventData!["duration"] ?? "N/A"} hours"),
                                _buildDetailRow(Icons.people, "Volunteer Type", eventData!["volunteerType"] ?? "Not specified"),
                                const SizedBox(height: 20),
                                const Text(
                                  "Description:",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  eventData!["description"] ?? "No description available",
                                  style: const TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () => _registerForEvent('id'),
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
                        ),
                      ),
          ),
        ],
      ),
    );
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


  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: value,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}