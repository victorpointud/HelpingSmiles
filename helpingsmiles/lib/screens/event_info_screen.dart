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
                                _buildDetailRow(Icons.people, "Organization", "${eventData!["organizationName"] ?? "Not specified"}"),
                                _buildDetailRow(Icons.people, "Org Type", "${eventData!["organizationType"] ?? "Not specified"}"),
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
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await _registerAsRequest(widget.eventId); // Envía una solicitud
                                    },
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
  
  Future<void> _registerForEvent(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final volunteerDoc = await FirebaseFirestore.instance.collection('volunteers').doc(user.uid).get();

        if (!volunteerDoc.exists) {
          _showErrorDialog("Volunteer profile not found!");
          return;
        }

        final volunteerData = volunteerDoc.data() ?? {};
        await FirebaseFirestore.instance.collection('events').doc(eventId).collection('registrations').doc(user.uid).set({
          'userId': user.uid,
          'name': volunteerData['name'] ?? "Not specified",
          'email': user.email ?? "Not specified",
          'phone': volunteerData['phone'] ?? "Not specified",
          'skills': volunteerData['skills'] ?? [],
          'interests': volunteerData['interests'] ?? [],
          'location': volunteerData['location'] ?? "Not specified",
          'date': volunteerData['date'] ?? "Not specified",
          'timestamp': FieldValue.serverTimestamp(),
        });

        _showSuccessDialog("You have successfully registered for this event.");
      } catch (e) {
        _showErrorDialog("Failed to register for event.");
      }
    }
  }

  Future<void> _registerAsRequest(String eventId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      print("Fetching volunteer data...");
      final volunteerDoc = await FirebaseFirestore.instance.collection('volunteers').doc(user.uid).get();

      if (!volunteerDoc.exists) {
        print("Volunteer profile not found.");
        _showErrorDialog("Volunteer profile not found!");
        return;
      }

      print("Volunteer data found. Checking request...");
      final requestDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('requests')
          .doc(user.uid)
          .get();

      if (requestDoc.exists) {
        print("Request already exists.");
        _showErrorDialog("You have already submitted a request for this event.");
        return;
      }

      print("Creating request...");
      final volunteerData = volunteerDoc.data() ?? {
        'name': "Not specified",
        'phone': "Not specified",
        'skills': [],
        'interests': [],
        'location': "Not specified",
        'date': "Not specified",
      };
      await FirebaseFirestore.instance.collection('events').doc(eventId).collection('requests').doc(user.uid).set({
        'userId': user.uid,
        'name': volunteerData['name'],
        'email': user.email ?? "Not specified",
        'phone': volunteerData['phone'],
        'skills': volunteerData['skills'],
        'interests': volunteerData['interests'],
        'location': volunteerData['location'],
        'date': volunteerData['date'],
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      print("Request submitted successfully.");
      _showSuccessDialog("Your request has been submitted successfully.");
    } catch (e) {
      print("Error submitting request: $e");
      _showErrorDialog("Failed to submit request.");
    }
  }
}

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        content: Text(message, style: const TextStyle(fontSize: 16, color: Colors.black)),
      ),
    );
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
}