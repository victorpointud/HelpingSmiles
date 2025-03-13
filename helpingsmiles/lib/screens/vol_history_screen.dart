import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'registered_event_info_screen.dart';
import 'registered_org_info_screen.dart';

class VolHistoryScreen extends StatefulWidget {
  const VolHistoryScreen({super.key});

  @override
  _VolHistoryScreenState createState() => _VolHistoryScreenState();
}

class _VolHistoryScreenState extends State<VolHistoryScreen> {
  List<Map<String, dynamic>> registeredOrganizations = [];
  List<Map<String, dynamic>> completedEvents = [];
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
      final orgsSnapshot = await FirebaseFirestore.instance
          .collection('organizations')
          .get();

      List<Map<String, dynamic>> tempOrgs = [];
      for (var doc in orgsSnapshot.docs) {
        final registrationRef = doc.reference.collection('registrations').doc(user.uid);
        final registrationDoc = await registrationRef.get();

        if (registrationDoc.exists) {
          tempOrgs.add({
            'id': doc.id,
            'name': doc.data()['name'] ?? "Unnamed Organization",
          });
        }
      }

      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .get();

      List<Map<String, dynamic>> tempEvents = [];
      for (var doc in eventsSnapshot.docs) {
        final registrationRef = doc.reference.collection('registrations').doc(user.uid);
        final registrationDoc = await registrationRef.get();

        if (registrationDoc.exists && registrationDoc.data()?['status'] == 'completed') {
          tempEvents.add({
            'id': doc.id,
            'name': doc.data()['name'] ?? "Unnamed Event",
          });
        }
      }

      int calculatedPoints = (tempOrgs.length * 2) + tempEvents.length;

      setState(() {
        registeredOrganizations = tempOrgs;
        completedEvents = tempEvents;
        totalPoints = calculatedPoints;
      });
    } catch (e) {
      print("Error loading history: $e");
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
                  _buildSection("Registered Organizations", registeredOrganizations, Icons.business, "You haven't registered for any organizations yet.", isOrg: true),
                  const SizedBox(height: 20),
                  _buildSection("Completed Events", completedEvents, Icons.event, "You haven't completed any events yet.", isOrg: false),
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

  Widget _buildLevelCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items, IconData icon, String emptyMessage, {required bool isOrg}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                          if (isOrg) {
                            _navigateToRegisteredOrgInfo(item["id"], item["name"]);
                          } else {
                            _navigateToRegisteredEventInfo(item["id"]);
                          }
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
                                Icon(isOrg ? Icons.business : Icons.event, color: Colors.red),
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

  void _navigateToRegisteredOrgInfo(String orgId, String orgName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisteredOrgInfoScreen(organizationId: orgId, organizationName: orgName),
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