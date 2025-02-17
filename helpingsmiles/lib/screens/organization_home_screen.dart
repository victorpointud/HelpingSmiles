import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../managers/auth_manager.dart';
import 'organization_profile_screen.dart';
import 'login_screen.dart';
import '../managers/add_org_activity_manager.dart';
import '../managers/edit_org_activity_manager.dart';

class OrganizationHomeScreen extends StatefulWidget {
  const OrganizationHomeScreen({super.key});

  @override
  _OrganizationHomeScreenState createState() => _OrganizationHomeScreenState();
}

class _OrganizationHomeScreenState extends State<OrganizationHomeScreen> {
  String? organizationName;
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizationData();
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
        });

        _loadEvents(user.uid);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          organizationName = "Error retrieving organization";
        });
      }
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
      print("Error loading events: $e");
    }
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((result) {
      if (result == true) _loadOrganizationData();
    });
  }

  Future<void> _deleteEvent(String eventId) async {
    await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
    _loadOrganizationData();
  }

  void _confirmDelete(String eventId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Event"),
        content: const Text("Are you sure you want to delete this event?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              _deleteEvent(eventId);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
      automaticallyImplyLeading: false,
      title: Text(
        "Welcome, ${organizationName ?? 'Loading...'}!",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.person, color: Colors.black), onPressed: _navigateToProfile),
        IconButton(icon: const Icon(Icons.logout, color: Colors.red), onPressed: _logout),
      ],
      toolbarHeight: kToolbarHeight,
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
        Container(color: Colors.black.withOpacity(0.6)),
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Upcoming Events"),
                        _buildEventList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.red,
      onPressed: () => _navigate(context, const AddOrgActivityManager()),
      child: const Icon(Icons.add, color: Colors.white),
    ),
  );
}
  void _logout() async {
      await AuthManager.logoutUser();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }

  void _navigateToProfile() {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const OrganizationProfileScreen()));
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

  Widget _buildEventList() {
    if (events.isEmpty) {
      return const Center(child: Text("No upcoming events. Add one!", style: TextStyle(color: Colors.white)));
    }
    return Column(
      children: events.map((event) => _buildEventCard(event)).toList(),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return GestureDetector(
      onTap: () => _navigate(context, EditOrgActivityManager(eventId: event["id"], eventData: event)),
      onLongPress: () => _confirmDelete(event["id"]),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.white,
        child: ListTile(
          title: Text(event["name"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          subtitle: Text("${event["date"]} • ${event["location"]}", style: const TextStyle(color: Colors.black)),
          trailing: const Icon(Icons.event, color: Colors.black),
        ),
      ),
    );
  }
}