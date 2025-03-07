import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../managers/auth_manager.dart';
import 'vol_profile_screen.dart';
import 'login_screen.dart';
import 'registered_org_info_screen.dart';
import 'event_info_screen.dart';
import 'org_info_screen.dart';
import 'registered_event_info_screen.dart';
import 'all_events_screen.dart';
import 'all_orgs_screen.dart';
import 'all_registered_events_screen.dart';
import 'all_registered_orgs_screen.dart';
import 'calendar_screen.dart';
import 'dart:math';


class VolHomeScreen extends StatefulWidget {
  const VolHomeScreen({super.key});

  @override
  VolHomeScreenState createState() => VolHomeScreenState();
}

class VolHomeScreenState extends State<VolHomeScreen> {
  String? userName;
  List<Map<String, dynamic>> organizations = [];
  List<Map<String, dynamic>> registeredOrganizations = [];
  List<Map<String, dynamic>> availableEvents = [];
  List<Map<String, dynamic>> registeredEventInfo = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadOrganizations();
    _loadAvailableEvents();
    _loadRegisteredOrganizations();
    _loadregisteredEventInfo();
  }

  List<Map<String, dynamic>> _getRandomElements(List<Map<String, dynamic>> list) {
    if (list.length <= 2) return list; 
    final random = Random();
    list.shuffle(random); 
    return list.take(2).toList();
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
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CalendarScreen()),
              );
            },
          ),
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
          Container(color: Colors.black.withAlpha(77)), // 0.3 * 255 = 77,
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    _buildSectionTitle("Available Activities"),
                    _buildEventList(_getRandomElements(availableEvents)),
                    const SizedBox(height: 10),
                    Center(
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _navigateToMoreEvents,
                            icon: const Icon(Icons.event),
                            label: const Text("More Events"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(230, 74, 63, 1),
                              foregroundColor: Colors.white,
                              iconColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    

                    const SizedBox(height: 20),
                    _buildSectionTitle("Available Organizations"),
                    _buildOrganizationList(_getRandomElements(organizations)),
                    const SizedBox(height: 10),
                    Center(
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _navigateToMoreOrgs,
                            icon: const Icon(Icons.event),
                            label: const Text("More Organizations"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(230, 74, 63, 1),
                              foregroundColor: Colors.white,
                              iconColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle("My Registered Organizations"),
                    _buildRegisteredOrganizationList(_getRandomElements(registeredOrganizations)),
                    const SizedBox(height: 10),
                    Center(
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _navigateToMoreRegisteredOrgs,
                            icon: const Icon(Icons.event),
                            label: const Text("More Registered Organizations"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(230, 74, 63, 1),
                              foregroundColor: Colors.white,
                              iconColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                    const SizedBox(height: 20),
                    _buildSectionTitle("My Registered Events"),
                    _buildRegisteredEventList(_getRandomElements(registeredEventInfo)),
                    const SizedBox(height: 10),
                    Center(
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _navigateToMoreRegisteredEvents,
                            icon: const Icon(Icons.event),
                            label: const Text("More Registered Events"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(230, 74, 63, 1),
                              foregroundColor: Colors.white,
                              iconColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],               
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const VolProfileScreen()));
  }

  void _navigateToEventInfo(String eventId) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => EventInfoScreen(eventId: eventId),),);
  }

  void _navigateToRegisteredOrgInfo(String orgId, String orgName) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => RegisteredOrgInfoScreen(organizationId: orgId,organizationName: orgName,),),);
  }

  void _navigateToRegisteredEventInfoDetails(String eventId) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => RegisteredEventInfoScreen(eventId: eventId),),);
  }
  
  void _navigateToOrgInfo(String orgId, String orgName) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => OrgInfoScreen(organizationId: orgId, organizationName: orgName,),),);
  }

 void _navigateToMoreEvents() {
  Navigator.push(context, MaterialPageRoute(builder: (_) => const AllEventsScreen()),);
}

void _navigateToMoreOrgs() {
  Navigator.push(context, MaterialPageRoute(builder: (_) => const AllOrgsScreen()),);
}

void _navigateToMoreRegisteredEvents() {
  Navigator.push(context, MaterialPageRoute(builder: (_) => const AllRegisteredEventsScreen()),);
}

void _navigateToMoreRegisteredOrgs() {
  Navigator.push(context, MaterialPageRoute(builder: (_) => const AllRegisteredOrgsScreen()),);
}

  Future<void> _loadAvailableEvents() async {
      try {
        final querySnapshot = await FirebaseFirestore.instance.collection('events').get();
        if (!mounted) return;
        setState(() {
          availableEvents = querySnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'] ?? "Unknown Event",
              'date': data['date'] ?? "No date provided",
              'location': data['location'] ?? "No location provided",
            };
          }).toList();
        });
      } catch (e) {
      debugPrint("Error loading available events: $e");
      }
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
      debugPrint("Error loading organizationss: $e");
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
        debugPrint("Error loading registered organizations: $e");

      }
    }

  Future<void> _loadregisteredEventInfo() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    List<Map<String, dynamic>> tempEvents = [];

    final eventsSnapshot = await FirebaseFirestore.instance.collection('events').get();

    for (var eventDoc in eventsSnapshot.docs) {
      final eventId = eventDoc.id;

      final registrationRef = eventDoc.reference.collection('registrations').doc(user.uid);
      final registrationDoc = await registrationRef.get();

      if (registrationDoc.exists) {
        tempEvents.add({
          'id': eventId,
          'name': eventDoc['name'] ?? "Unknown Event",
          'date': eventDoc['date'] ?? "No date provided",
          'location': eventDoc['location'] ?? "No location provided",
        });
      }
    }

    if (!mounted) return;
    setState(() {
      registeredEventInfo = tempEvents;
    });
        debugPrint("Registered Events Loaded: $registeredEventInfo");

  } catch (e) {
    debugPrint(" Error loading registered events: $e");
  }
}

  void _logout() async {
    await AuthManager.logoutUser();

    if (!mounted) return; // Verifica si el widget sigue en pantalla antes de navegar

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildEventList(List<Map<String, dynamic>> events) {
    if (events.isEmpty) {
      return const Center(child: Text("No events available.", style: TextStyle(color: Colors.white)));
    }
    return Column(
      children: events.map((event) => _buildEventCard(event)).toList(),
    );
  }

  Widget _buildOrganizationList(List<Map<String, dynamic>> orgs) {
    if (orgs.isEmpty) {
      return const Center(child: Text("No organizations available.", style: TextStyle(color: Colors.white)));
    }
    return Column(
      children: orgs.map((org) => _buildOrganizationCard(org)).toList(),
    );
  }

  Widget _buildOrganizationCard(Map<String, dynamic> org) {
    return GestureDetector(
      onTap: () => _navigateToOrgInfo(org["id"], org["name"]),
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

  Widget _buildRegisteredOrganizationCard(Map<String, dynamic> org) {
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

  Widget _buildRegisteredOrganizationList(List<Map<String, dynamic>> registorgs) {
    if (registorgs.isEmpty) {
      return const Center(child: Text("You are not registered in any organization.", style: TextStyle(color: Colors.white)));
    }
    return Column(
      children: registorgs.map((org) => _buildRegisteredOrganizationCard(org)).toList(),
    );
  }

  Widget _buildRegisteredEventList(List<Map<String, dynamic>> registevent) {
    if (registevent.isEmpty) {
      return const Center(child: Text("You are not registered in any events.", style: TextStyle(color: Colors.white)));
    }
    return Column(
      children: registevent.map((event) => _buildRegisteredEventCard(event)).toList(),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return GestureDetector(
      onTap: () => _navigateToEventInfo(event["id"]),
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
              Text(event["name"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 5),
              Text("${event["date"]} • ${event["location"]}", style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 5),
              const Text("Click to see more info", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisteredEventCard(Map<String, dynamic> event) {
    return GestureDetector(
      onTap: () => _navigateToRegisteredEventInfoDetails(event["id"]),
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
              Text(event["name"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 5),
              Text("${event["date"]} • ${event["location"]}", style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 5),
              const Text("Click to see more info", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

}

