import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisteredEventInfoScreen extends StatefulWidget {
  final String eventId;

  const RegisteredEventInfoScreen({super.key, required this.eventId});

  @override
  _RegisteredEventInfoScreenState createState() => _RegisteredEventInfoScreenState();
}

class _RegisteredEventInfoScreenState extends State<RegisteredEventInfoScreen> {
  Map<String, dynamic>? eventData;
  Map<String, dynamic>? representativeData;
  bool isLoading = true;
  bool isRepLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventData();
    _loadRepresentativeData();
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

  Future<void> _loadRepresentativeData() async {
    try {
      final repDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('representatives')
          .doc('info')
          .get();

      if (repDoc.exists && repDoc.data() != null) {
        setState(() {
          representativeData = repDoc.data();
        });
      } else {
        print("No representative data found.");
      }
    } catch (e) {
      print("Error loading representative data: $e");
    } finally {
      setState(() => isRepLoading = false);
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
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                _buildRepresentativeSection(), 
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

  Widget _buildRepresentativeSection() {
    if (isRepLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (representativeData == null) {
      return const Center(
        child: Text(
          "No representative assigned for this event.",
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54),
        ),
      );
    }
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Representative",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.person, "Name", "${representativeData!['repName']} ${representativeData!['repLastName']}"),
            _buildDetailRow(Icons.email, "Email", representativeData!['repEmail']),
            _buildDetailRow(Icons.phone, "Phone", representativeData!['repPhone']),
          ],
        ),
      ),
    );
  }

}