import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'registered_event_info_screen.dart';

class OrgHistoryScreen extends StatefulWidget {
  const OrgHistoryScreen({super.key});

  @override
  _OrgHistoryScreenState createState() => _OrgHistoryScreenState();
}

class _OrgHistoryScreenState extends State<OrgHistoryScreen> {
  List<Map<String, dynamic>> completedEvents = [];
  int totalVolunteers = 0;
  int totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {

      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('organizationId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'completed')
          .get();

      List<Map<String, dynamic>> tempEvents = [];
      for (var doc in eventsSnapshot.docs) {
        tempEvents.add({
          'id': doc.id,
          'name': doc.data()['name'] ?? "Unnamed Event",
        });
      }

      final volunteersSnapshot = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(user.uid)
          .collection('registrations')
          .get();

      int volunteerCount = volunteersSnapshot.docs.length;

      int calculatedPoints = (tempEvents.length * 2) + volunteerCount;

      setState(() {
        completedEvents = tempEvents;
        totalVolunteers = volunteerCount;
        totalPoints = calculatedPoints;
      });

    } catch (e) {
      debugPrint("Error loading history: $e");
    }
  }

  String _determineLevel() {
    if (totalPoints >= 30) {
      return "💎 Diamond";
    } else if (totalPoints >= 20) {
      return "🥇 Gold";
    } else if (totalPoints >= 10) {
      return "🥈 Silver";
    } else {
      return "🥉 Bronze";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "History",
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildEventsCard("Completed Events", completedEvents, Icons.event, "No completed events yet."),
                  const SizedBox(height: 20),
                  _buildVolCountCard(),
                  const SizedBox(height: 20),
                  _buildLevelCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolCountCard() {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.red, width: 2),
      ),
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.groups, color: Colors.red, size: 25),
              SizedBox(width: 10),
              Text(
                "Total Volunteers Registered",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "$totalVolunteers",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildLevelCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.red, width: 2),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Your Level",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            Text(
              _determineLevel(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 5),
            Text(
              "Total Points: $totalPoints",
              style: const TextStyle(fontSize: 16, color: Colors.black, ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsCard(String title, List<Map<String, dynamic>> items, IconData icon, String emptyMessage) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.red, width: 2),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.red),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 10),
            items.isEmpty
                ? Text(emptyMessage, style: const TextStyle(fontSize: 16, color: Colors.black))
                : Column(
                    children: items.map((item) {
                      return GestureDetector(
                        onTap: () {
                          _navigateToRegisteredEventInfo(item["id"]);
                        },
                        child: Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.event, color: Colors.red),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item["name"],
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  void _navigateToRegisteredEventInfo(String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisteredEventInfoScreen(eventId: eventId),
      ),
    );
  }
}