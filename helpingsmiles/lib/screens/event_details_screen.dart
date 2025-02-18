import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
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

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$title: $value",
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}