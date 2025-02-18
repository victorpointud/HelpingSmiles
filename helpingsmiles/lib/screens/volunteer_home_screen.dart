import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../managers/auth_manager.dart';
import 'volunteer_profile_screen.dart';
import 'login_screen.dart';
import 'registered_organizations_screen.dart';
import 'event_details_screen.dart';

class VolunteerHomeScreen extends StatefulWidget {
  const VolunteerHomeScreen({super.key});

  @override
  _VolunteerHomeScreenState createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
  String? userName;
  List<Map<String, dynamic>> organizations = [];
  List<Map<String, dynamic>> registeredOrganizations = [];
  List<Map<String, dynamic>> registeredEvents = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadOrganizations();
    _loadRegisteredOrganizations();
    _loadRegisteredEvents();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? fullName = await AuthManager.getUserName(user.uid);
      if (mounted) {
        setState(() {
          userName = fullName ?? "Unknown Volunteer";
        });
      }
    }
  }

  Future<void> _loadOrganizations() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('organizations').get();
      if (!mounted) return;
      setState(() {
        organizations = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? "Unknown Organization",
            'mission': data['mission'] ?? "Unknown Mission",
          };
        }).toList();
      });
    } catch (e) {
      print("Error loading organizations: $e");
    }
  }
Future<void> _loadRegisteredOrganizations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final orgsSnapshot = await FirebaseFirestore.instance.collection('organizations').get();
      List<Map<String, dynamic>> tempOrganizations = [];

      for (var orgDoc in orgsSnapshot.docs) {
        final regRef = orgDoc.reference.collection('registrations').doc(user.uid);
        final regDoc = await regRef.get();

        if (regDoc.exists) {
          tempOrganizations.add({
            'id': orgDoc.id,
            'name': orgDoc['name'] ?? "Unknown Organization",
            'mission': orgDoc['mission'] ?? "No mission provided",
          });
        }
      }

      if (!mounted) return;
      setState(() {
        registeredOrganizations = tempOrganizations;
      });
    } catch (e) {
      print("Error loading registered organizations: $e");
    }
  }

  Future<void> _loadRegisteredEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('registrations')
          .where('userId', isEqualTo: user.uid)
          .get();

      List<Map<String, dynamic>> tempEvents = [];

      for (var doc in querySnapshot.docs) {
        final eventRef = doc.reference.parent.parent;
        if (eventRef != null) {
          final eventDoc = await eventRef.get();
          if (eventDoc.exists) {
            tempEvents.add({
              'id': eventDoc.id,
              'name': eventDoc['name'] ?? "Unknown Event",
              'date': eventDoc['date'] ?? "No date provided",
              'location': eventDoc['location'] ?? "No location provided",
            });
          }
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

  void _logout() async {
    await AuthManager.logoutUser();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _navigateToProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const VolunteerProfileScreen()));
  }

  void _navigateToEventDetails(String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailsScreen(eventId: eventId),
      ),
    );
  }

  void _navigateToOrganizationDetails(String orgId, String orgName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisteredOrganizationsScreen(
          organizationId: orgId,
          organizationName: orgName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          "Welcome, ${userName ?? 'Loading...'}!",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
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
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("All Organizations"),
                    _buildOrganizationList(),

                    const SizedBox(height: 20),
                    _buildSectionTitle("My Registered Organizations"),
                    _buildRegisteredOrganizationList(),

                    const SizedBox(height: 20),
                    _buildSectionTitle("My Registered Events"),
                    _buildRegisteredEventList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildOrganizationList() {
    if (organizations.isEmpty) {
      return const Center(child: Text("No organizations available.", style: TextStyle(color: Colors.white)));
    }
    return Column(
      children: organizations.map((org) => _buildOrganizationCard(org)).toList(),
    );
  }

  Widget _buildOrganizationCard(Map<String, dynamic> org) {
    return GestureDetector(
      onTap: () => _navigateToOrganizationDetails(org["id"], org["name"]),
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
              Text(org["name"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 5),
              Text(org["mission"], style: const TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 5),
              const Text("Click to see more info", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisteredOrganizationList() {
    if (registeredOrganizations.isEmpty) {
      return const Center(child: Text("You are not registered in any organization.", style: TextStyle(color: Colors.white)));
    }
    return Column(
      children: registeredOrganizations.map((org) => _buildOrganizationCard(org)).toList(),
    );
  }

  Widget _buildRegisteredEventList() {
    if (registeredEvents.isEmpty) {
      return const Center(child: Text("You are not registered in any events.", style: TextStyle(color: Colors.white)));
    }
    return Column(
      children: registeredEvents.map((event) => _buildEventCard(event)).toList(),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return GestureDetector(
      onTap: () => _navigateToEventDetails(event["id"]),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.white,
        child: ListTile(
          title: Text(event["name"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          subtitle: Text("${event["date"]} • ${event["location"]}", style: const TextStyle(color: Colors.black)),
        ),
      ),
    );
  }
}