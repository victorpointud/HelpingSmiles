import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../managers/auth_manager.dart';
import 'organization_profile_screen.dart';
import 'login_screen.dart';
import '../managers/add_org_activity_manager.dart'; // Updated import
import '../managers/edit_org_activity_manager.dart'; // Updated import


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
        orgName = "Unknown Organization"; // ✅ Manejo de caso cuando es nulo
      }

      if (!mounted) return; // ✅ Evita llamar setState si el widget ya no está montado
      setState(() {
        organizationName = orgName;
      });

      _loadEvents(user.uid);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        organizationName = "Error retrieving organization"; // ✅ Mensaje de error adecuado
      });
      print("Error fetching organization name: $e"); // Debugging
    }
  }
}


  Future<void> _loadEvents(String userId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print("User not authenticated");
    return;
  }

  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('organizationId', isEqualTo: userId)
        .get();

    if (!mounted) return; // Evita errores si el widget fue descartado

    setState(() {
      events = querySnapshot.docs.map((doc) {
        final eventData = doc.data();
        eventData["id"] = doc.id; // ✅ Agregar ID del documento
        return eventData;
      }).toList();
    });
  } catch (e) {
    print("Error loading events: $e");
  }
}



  void _navigate(BuildContext context, Widget screen) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((result) {
    if (result == true) _loadOrganizationData(); // Reload after changes
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
        title: Text("Welcome, $organizationName!", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Color.fromARGB(255, 0, 0, 0)),
            onPressed: () => _navigate(context, const OrganizationProfileScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color.fromARGB(255, 255, 0, 0)),
            onPressed: () async {
              await AuthManager.logoutUser();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [    
            _buildSectionTitle("Upcoming Events"),
            _buildEventList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => _navigate(context, const AddOrgActivityManager()),
        child: const Icon(Icons.add, color: Color.fromARGB(255, 255, 255, 255)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEventList() {
    if (events.isEmpty) {
      return const Center(child: Text("No upcoming events. Add one!"));
    }
    return Column(
      children: events.map((event) => _buildEventCard(event)).toList(),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return GestureDetector(
      onTap: () => _navigate(context, EditOrgActivityManager(eventId: event["id"], eventData: event)), // Edit Event
      onLongPress: () => _confirmDelete(event["id"]), // Delete on Long Press
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          title: Text(event["name"], style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 0, 0))),
          subtitle: Text("${event["date"]} • ${event["location"]}"),
          trailing: const Icon(Icons.event, color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
    );
  }
}
