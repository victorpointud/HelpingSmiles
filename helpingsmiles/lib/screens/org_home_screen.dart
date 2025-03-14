import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../managers/auth_manager.dart';
import 'org_profile_screen.dart';
import 'login_screen.dart';
import '../managers/add_org_event_manager.dart';
import '../managers/edit_org_event_manager.dart';
import 'registered_vol_info_screen.dart';
import 'registered_org_info_screen.dart';
import 'all_org_events_screen.dart';
import 'all_extra_orgs_screen.dart';
import 'calendar_screen.dart';
import 'org_history_screen.dart';
import 'notifications_screen.dart';

class OrgHomeScreen extends StatefulWidget {
  const OrgHomeScreen({super.key});

  @override
  OrgHomeScreenState createState() => OrgHomeScreenState();
}

class OrgHomeScreenState extends State<OrgHomeScreen> {
  String? organizationName;
  String? organizationId;
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> otherOrganizations = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizationData();
    _loadOtherOrganizations();
  }

  Future<void> _loadOrganizationData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      String? orgName = await AuthManager.getOrganizationName(user.uid);
      if (orgName == null || orgName.isEmpty) {
        orgName = "Unknown Organization";
      }

      if (!mounted) return;
      setState(() {
        organizationName = orgName;
        organizationId = user.uid; 
      });
      debugPrint("Organization ID Loaded: $organizationId");

      _loadEvents(user.uid);
    } catch (e) {
      debugPrint(" Error retrieving organization: $e");
    }
  }
}

  Future<void> _loadOtherOrganizations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('organizations').get();
      if (!mounted) return;

      setState(() {
        otherOrganizations = querySnapshot.docs
            .where((doc) => doc.id != user.uid)
            .map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? "Unknown Organization",
            'mission': data['mission'] ?? "No mission provided",
          };
        }).toList();
      });
    } catch (e) {
      debugPrint("Error loading other organizations: $e");
    }
  }

  Future<void> _loadEvents(String userId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('organizationId', isEqualTo: userId)
          .get();

      if (!mounted) return;

      setState(() {
        events = querySnapshot.docs.map((doc) {
          final eventData = doc.data();
          eventData["id"] = doc.id;
          return eventData;
        }).toList();
      });
    } catch (e) {
      debugPrint("Error loading events: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          "$organizationName",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications, color: Colors.black), onPressed: _navigateToNotifications),
          IconButton(icon: const Icon(Icons.event, color: Colors.black), onPressed: _navigateToCalendar),
          IconButton(icon: const Icon(Icons.check, color: Colors.black), onPressed: _navigateToOrgHistory),
          IconButton(icon: const Icon(Icons.person, color: Colors.black), onPressed: _navigateToProfile),
          IconButton(icon: const Icon(Icons.logout, color: Colors.red), onPressed: _logout),
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
        Container(color: Colors.black.withAlpha(77)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Upcoming Events"),
                  _buildEventList(_getRandomElements(events)),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: organizationId != null ? _navigateToAllOrgEvents : null,
                      icon: const Icon(Icons.event),
                      label: const Text("More Events"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(230, 74, 63, 1),
                        foregroundColor: Colors.white,
                        iconColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _buildSectionTitle("Other Organizations"),
                  _buildOtherOrganizationsList(_getRandomElements(otherOrganizations.toList())),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: organizationId != null ? _navigateToAllExtraOrgs : null,
                      icon: const Icon(Icons.event),
                      label: const Text("More Organizations"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(230, 74, 63, 1),
                        foregroundColor: Colors.white,
                        iconColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _buildSectionTitle("Volunteers Enrolled"),
                  const SizedBox(height: 10),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navigateToVolunteers,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 255, 255), 
                          padding: const EdgeInsets.symmetric(vertical: 16), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("View Volunteers", style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 247, 16, 16))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => _navigate(context, const AddOrgEventManager()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<Map<String, dynamic>> _getRandomElements(List<Map<String, dynamic>> list) {
    if (list.length <= 2) return list; 
    final random = Random();
    list.shuffle(random); 
    return list.take(2).toList();
  }

  void _navigate(BuildContext context, Widget screen) {
    if (!mounted) return;

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((result) {
      if (mounted && result == true) _loadOrganizationData();
    });
  }

  void _navigateToCalendar() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CalendarScreen()));
  }

  void _navigateToOrgHistory() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => OrgHistoryScreen()));
  }

  void _navigateToNotifications() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsScreen()));
  }

  void _navigateToVolunteers() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisteredVolInfoScreen()));
  }

  void _logout() async {
    await AuthManager.logoutUser();

    if (!mounted) return; 

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _navigateToAllOrgEvents() {
  if (organizationId != null) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AllOrgEventsScreen(organizationId: organizationId!)),
    );
  } else {
    debugPrint("Error: organizationId is null");

  }
}

  void _navigateToAllExtraOrgs() {
  if (organizationId != null) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AllExtraOrgsScreen(currentOrganizationId: organizationId!)),
    );
  } else {
    debugPrint("Error: organizationId is null");
  }
}

  void _navigateToProfile() {
  if (organizationId != null && organizationName != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrgProfileScreen(
          organizationId: organizationId!,
          organizationName: organizationName!,
        ),
      ),
    );
  } else {
    debugPrint("Error: organizationId or organizationName is null");
  }
}

  void _navigateToRegisteredOrgInfo(String orgId, String orgName) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => RegisteredOrgInfoScreen(
        organizationId: orgId,
        organizationName: orgName,
      ),
    ),
  );
}

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildEventList(List<Map<String, dynamic>> events) {
    if (events.isEmpty) {
      return const Center(child: Text("No upcoming events. Add one!", style: TextStyle(color: Colors.white)));
    }
    return Column(
      children: events.map((event) => _buildEventCard(event)).toList(),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return GestureDetector(
      onTap: () => _navigate(context, EditOrgEventManager(eventId: event["id"], eventData: event)),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(event["name"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              Text("${event["date"]} • ${event["location"]}", style: const TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 5),
              const Text("Click to edit", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherOrganizationsList(List<Map<String, dynamic>> otherOrganizations) {
    if (otherOrganizations.isEmpty) {
      return const Center(
        child: Text("No other organizations found.", style: TextStyle(color: Colors.white)),
      );
    }
    return Column(
      children: otherOrganizations.map((org) => _buildOrganizationCard(org)).toList(),
    );
  }

  Widget _buildOrganizationCard(Map<String, dynamic> org) {
    return GestureDetector(
      onTap: () => _navigateToRegisteredOrgInfo(org["id"], org["name"]),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(org["name"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              Text(org["mission"], style: const TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 5),
              const Text("Tap to view details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}