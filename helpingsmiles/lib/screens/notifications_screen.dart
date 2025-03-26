import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_info_screen.dart';
import 'vol_info_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> upcomingEvents = [];
  List<Map<String, dynamic>> registeredUsers = [];
  List<Map<String, dynamic>> organizationRequests = [];

  @override
  void initState() {
    super.initState();
    _loadUpcomingEvents();
    _loadRegisteredUsers();
    _loadOrganizationRequests();
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

  Future<void> _loadRegisteredUsers() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return; 

  try {
    final orgId = user.uid;

    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('organizationId', isEqualTo: orgId) 
        .get();

    List<Map<String, dynamic>> tempUsers = [];

    for (var eventDoc in eventsSnapshot.docs) {
      final eventData = eventDoc.data();
      final eventId = eventDoc.id;
      final eventName = eventData['name'] ?? "Unnamed Event";

      final requestsSnapshot = await eventDoc.reference.collection('requests').get();

      for (var reqDoc in requestsSnapshot.docs) {
        tempUsers.add({
          'eventId': eventId,
          'userId': reqDoc.id,
          'userData': reqDoc.data(),
          'eventName': eventName,
        });
      }
    }

    setState(() {
      registeredUsers = tempUsers;
    });
  } catch (e) {
    print("Error loading registered users: $e");
  }
}

  Future<void> _loadOrganizationRequests() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return; 

  try {
    final orgId = user.uid;
    final requestsOrgRef = FirebaseFirestore.instance
        .collection('organizations')
        .doc(orgId)
        .collection('requestsOrg');

    final requestsOrgSnapshot = await requestsOrgRef.get();
    List<Map<String, dynamic>> tempOrgs = [];

    for (var reqDoc in requestsOrgSnapshot.docs) {
      tempOrgs.add({
        'orgId': orgId,
        'requestId': reqDoc.id,
        'orgData': reqDoc.data(),
      });
    }

    setState(() {
      organizationRequests = tempOrgs;
    });
  } catch (e) {
    print("Error loading organization requests: $e");
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
          child: Column(
            children: [
              if (upcomingEvents.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: upcomingEvents.length,
                    itemBuilder: (context, index) {
                      final event = upcomingEvents[index];
                      return _buildNotificationCard(event);
                    },
                  ),
                ),
              if (registeredUsers.isNotEmpty || organizationRequests.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView.builder(
                      itemCount: registeredUsers.length + organizationRequests.length,
                      itemBuilder: (context, index) {
                        if (index < registeredUsers.length) {
                          final user = registeredUsers[index];
                          return _buildUserCard(user);
                        } else {
                          final orgIndex = index - registeredUsers.length;
                          final orgRequest = organizationRequests[orgIndex];
                          return _buildOrgCard(orgRequest);
                        }
                      },
                    ),
                  ),
                ),
              if (upcomingEvents.isEmpty && registeredUsers.isEmpty && organizationRequests.isEmpty)
                const Center(
                  child: Text(
                    "No upcoming notifications.",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
            ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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

  Widget _buildUserCard(Map<String, dynamic> user) {
  if (user["userData"]["name"] == null || user["userData"]["name"].isEmpty) {
    return const SizedBox.shrink();
  }

  String eventName = user["eventName"] ?? "Event";

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VolInfoScreen(volunteerId: user["userId"]),
        ),
      );
    },
    child: Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${user["userData"]["name"]} wants to join the event $eventName",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.email, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Email: ${user["userData"]["email"] ?? "Email not available"}",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Phone: ${user["userData"]["phone"] ?? "Phone not available"}",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.work, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Role: ${user["userData"]["role"] ?? "No Role"}",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final eventId = user["eventId"];
                    final userId = user["userId"];

                    try {
                      final requestRef = FirebaseFirestore.instance
                          .collection('events')
                          .doc(eventId)
                          .collection('requests')
                          .doc(userId);

                      final requestDoc = await requestRef.get();
                      if (requestDoc.exists) {
                        await requestRef.delete();
                        _loadRegisteredUsers();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User request declined successfully.")),
                        );
                      }
                    } catch (e) {
                      print("Error declining user request: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Error declining user request.")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    "Decline",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    final eventId = user["eventId"];
                    final userId = user["userId"];

                    try {
                      final registrationRef = FirebaseFirestore.instance
                          .collection('events')
                          .doc(eventId)
                          .collection('registrations')
                          .doc(userId);

                      final registrationDoc = await registrationRef.get();
                      if (registrationDoc.exists) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Error: The user is already registered."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final requestRef = FirebaseFirestore.instance
                          .collection('events')
                          .doc(eventId)
                          .collection('requests')
                          .doc(userId);

                      final requestDoc = await requestRef.get();
                      if (requestDoc.exists) {
                        await registrationRef.set(requestDoc.data()!);
                        await requestRef.delete();
                        _loadRegisteredUsers();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("User successfully registered."),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      print("Error approving user: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("An error occurred while approving the user."),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    "Approve",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildOrgCard(Map<String, dynamic> orgRequest) {
  final orgData = orgRequest["orgData"] as Map<String, dynamic>;

  return Card(
    elevation: 4,
    margin: const EdgeInsets.symmetric(vertical: 5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Organization Request: ${orgData["name"] ?? "Unnamed Organization"}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.email, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Text(
                "Email: ${orgData["email"] ?? "Email not available"}",
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Text(
                "Phone: ${orgData["phone"] ?? "Phone not available"}",
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_city, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Text(
                "Location: ${orgData["location"] ?? "No location provided"}",
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final orgId = orgRequest["orgId"];
                  final requestId = orgRequest["requestId"];

                  try {
                    final requestRef = FirebaseFirestore.instance
                        .collection('organizations')
                        .doc(orgId)
                        .collection('requestsOrg')
                        .doc(requestId);
                    final requestDoc = await requestRef.get();
                    if (!requestDoc.exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Error: The request does not exist in requestsOrg."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    await requestRef.delete();
                    _loadOrganizationRequests();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Organization request declined and removed from requestsOrg."),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    print("Error declining organization request: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("An error occurred while declining the organization request: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  "Decline",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  final orgId = orgRequest["orgId"];
                  final requestId = orgRequest["requestId"];

                  try {
                    final requestRef = FirebaseFirestore.instance
                        .collection('organizations')
                        .doc(orgId)
                        .collection('requestsOrg')
                        .doc(requestId);
                    final requestDoc = await requestRef.get();

                    if (!requestDoc.exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Error: The request does not exist in requestsOrg."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    final registrationRef = FirebaseFirestore.instance
                        .collection('organizations')
                        .doc(orgId)
                        .collection('registrations')
                        .doc(requestId);
                    await registrationRef.set(requestDoc.data()!);
                    await requestRef.delete();
                    _loadOrganizationRequests();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Organization approved and moved to registrations."),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    print("Error approving organization: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("An error occurred while approving the organization: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  "Approve",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
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
}