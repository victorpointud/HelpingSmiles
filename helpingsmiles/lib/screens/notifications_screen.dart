import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_info_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> upcomingEvents = [];

  @override
  void initState() {
    super.initState();
    _loadUpcomingEvents();
  }

  Future<void> _loadUpcomingEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance.collection('events').get();
      List<Map<String, dynamic>> tempEvents = [];

      DateTime now = DateTime.now();

      for (var doc in eventsSnapshot.docs) {
        final eventData = doc.data() as Map<String, dynamic>;
        DateTime? eventDate = DateTime.tryParse(eventData['date'] ?? '');

        if (eventDate != null && eventDate.isAfter(now)) {
          final registrationRef = doc.reference.collection('registrations').doc(user.uid);
          final registrationDoc = await registrationRef.get();

          if (registrationDoc.exists) {
            tempEvents.add({
              'id': doc.id,
              'name': eventData['name'] ?? "Unnamed Event",
              'date': eventData['date'] ?? "No date provided",
              'location': eventData['location'] ?? "No location provided",
            });
          }
        }
      }

      setState(() {
        upcomingEvents = tempEvents;
      });
    } catch (e) {
      print("Error loading notifications: $e");
    }
  }

  Future<void> _clearAllNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      for (var event in upcomingEvents) {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(event['id'])
            .collection('registrations')
            .doc(user.uid)
            .delete();
      }

      setState(() {
        upcomingEvents.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All notifications cleared.")),
      );
    } catch (e) {
      print("Error clearing notifications: $e");
    }
  }

  Future<void> _deleteNotification(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('registrations')
          .doc(user.uid)
          .delete();

      setState(() {
        upcomingEvents.removeWhere((event) => event['id'] == eventId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification removed.")),
      );
    } catch (e) {
      print("Error deleting notification: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Notifications",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (upcomingEvents.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: _clearAllNotifications,
            ),
        ],
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
            child: upcomingEvents.isEmpty
                ? const Center(
                    child: Text(
                      "No upcoming notifications.",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView.builder(
                      itemCount: upcomingEvents.length,
                      itemBuilder: (context, index) {
                        final event = upcomingEvents[index];
                        return _buildNotificationCard(event);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> event) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.red, width: 2),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _navigateToEventInfo(event["id"]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reminder: ${event["name"]}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text("Date: ${event["date"]}", style: const TextStyle(fontSize: 16, color: Colors.black)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text("Location: ${event["location"]}", style: const TextStyle(fontSize: 16, color: Colors.black)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("Tap to view details.", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => _deleteNotification(event["id"]),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEventInfo(String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventInfoScreen(eventId: eventId),
      ),
    );
  }
}