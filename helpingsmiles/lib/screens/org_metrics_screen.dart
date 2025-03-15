import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrgMetricsScreen extends StatefulWidget {
  final String organizacionId; // ID de la organización actual

  const OrgMetricsScreen({super.key, required this.organizacionId});

  @override
  OrgMetricsScreenState createState() => OrgMetricsScreenState();
}

class OrgMetricsScreenState extends State<OrgMetricsScreen> {
  late Future<List<Map<String, dynamic>>> _eventsData;

  @override
  void initState() {
    super.initState();
    _eventsData = fetchEventsMetrics();
  }

  Future<List<Map<String, dynamic>>> fetchEventsMetrics() async {
    QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('organizationId', isEqualTo: widget.organizacionId)
        .get();

    List<Map<String, dynamic>> eventsList = [];

    for (var eventDoc in eventsSnapshot.docs) {
      var eventData = eventDoc.data() as Map<String, dynamic>;
      String eventName = eventData['name'] ?? 'Sin nombre';
      int eventDuration = int.tryParse(eventData['duration'].toString()) ?? 0;

      // Acceder a la subcolección 'registrations' dentro del evento
      QuerySnapshot registrationsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventDoc.id) // ID del evento
          .collection('registrations') // Subcolección de inscripciones
          .get();

      int registeredVolunteers = registrationsSnapshot.docs.length;

      eventsList.add({
        'name': eventName,
        'duration': eventDuration,
        'volunteers': registeredVolunteers,
      });
    }

    return eventsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      appBar: AppBar(
        title: Text('Métricas de Eventos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red, // Barra roja
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _eventsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.red));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar métricas', style: TextStyle(color: Colors.black)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay eventos registrados.', style: TextStyle(color: Colors.black)));
          } else {
            final events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  color: Colors.white, // Tarjeta blanca
                  elevation: 3,
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.red, width: 2), // Borde rojo
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListTile(
                      title: Text(
                        event['name'],
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Horas acumuladas: ${event['duration']}",
                              style: TextStyle(color: Colors.black, fontSize: 14)),
                          Text("Voluntarios registrados: ${event['volunteers']}",
                              style: TextStyle(color: Colors.black, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
