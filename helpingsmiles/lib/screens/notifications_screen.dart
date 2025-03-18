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

  @override
  void initState() {
    super.initState();
    _loadUpcomingEvents();
    _loadRegisteredUsers();
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
  try {
    QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance.collection('events').get();
    List<Map<String, dynamic>> tempUsers = [];

    for (var doc in eventsSnapshot.docs) {
      final eventData = doc.data() as Map<String, dynamic>;
      String eventName = eventData['name'] ?? "Unnamed Event";

      // Cambia 'registrations' por 'request'
      QuerySnapshot requestsSnapshot = await doc.reference.collection('requests').get();
      for (var reqDoc in requestsSnapshot.docs) {
        tempUsers.add({
          'eventId': doc.id,
          'userId': reqDoc.id,
          'userData': reqDoc.data(),
          'eventName': eventName, // Agrega el nombre del evento aquí
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
                Expanded(
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView.builder(
                      itemCount: registeredUsers.length,
                      itemBuilder: (context, index) {
                        final user = registeredUsers[index];
                        return _buildUserCard(user);
                      },
                    ),
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
                    const Text("Tap to view details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
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
  // Verifica si el campo "name" no está presente o está vacío
  if (user["userData"]["name"] == null || user["userData"]["name"].isEmpty) {
    return const SizedBox.shrink(); // No muestra nada si no hay "name"
  }

  // Obtén el nombre del evento
  String eventName = user["eventName"] ?? "Event";

  // Si hay "name", construye la tarjeta
  return GestureDetector(
    onTap: () {
      // Navega a la pantalla de información del voluntario
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VolInfoScreen(volunteerId: user["userId"]),
        ),
      );
    },
    child: Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 5), // Reducir el margen vertical
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12), // Reducir el padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mensaje: "[Nombre] quiere unirse al evento [Nombre del evento]"
            Text(
              "${user["userData"]["name"]} wants to join the event $eventName",
              style: const TextStyle(
                fontSize: 16, // Reducir el tamaño de la fuente
                fontWeight: FontWeight.bold,
                color: Colors.red, // Texto en rojo
              ),
            ),
            const SizedBox(height: 8), // Reducir el espacio entre elementos
            // Email con ícono rojo
            Row(
              children: [
                const Icon(Icons.email, color: Colors.red, size: 18), // Reducir el tamaño del ícono
                const SizedBox(width: 8), // Reducir el espacio entre el ícono y el texto
                Text(
                  "Email: ${user["userData"]["email"] ?? "Email not available"}",
                  style: const TextStyle(fontSize: 14, color: Colors.black), // Reducir el tamaño de la fuente
                ),
              ],
            ),
            const SizedBox(height: 4), // Reducir el espacio entre elementos
            // Phone con ícono rojo
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.red, size: 18), // Reducir el tamaño del ícono
                const SizedBox(width: 8), // Reducir el espacio entre el ícono y el texto
                Text(
                  "Phone: ${user["userData"]["phone"] ?? "Phone not available"}",
                  style: const TextStyle(fontSize: 14, color: Colors.black), // Reducir el tamaño de la fuente
                ),
              ],
            ),
            const SizedBox(height: 4), // Reducir el espacio entre elementos
            // Role con ícono rojo
            Row(
              children: [
                const Icon(Icons.work, color: Colors.red, size: 18), // Reducir el tamaño del ícono
                const SizedBox(width: 8), // Reducir el espacio entre el ícono y el texto
                Text(
                  "Role: ${user["userData"]["role"] ?? "No Role"}",
                  style: const TextStyle(fontSize: 14, color: Colors.black), // Reducir el tamaño de la fuente
                ),
              ],
            ),
            const SizedBox(height: 8), // Reducir el espacio entre elementos
            // Botones "Reject Volunteer" y "Approved"
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Action to reject the volunteer
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Aumentar el padding
                  ),
                  child: const Text(
                    "Decline",
                    style: TextStyle(color: Colors.white, fontSize: 16), // Aumentar el tamaño de la fuente
                  ),
                ),
                const SizedBox(width: 12), // Aumentar el espacio entre los botones
                ElevatedButton(
                  onPressed: () {
                    // Action to approve the volunteer
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Color verde para el botón "Approved"
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Aumentar el padding
                  ),
                  child: const Text(
                    "Approved",
                    style: TextStyle(color: Colors.white, fontSize: 16), // Aumentar el tamaño de la fuente
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