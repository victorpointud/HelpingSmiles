import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart'; 

class OrgMetricsScreen extends StatefulWidget {
  final String organizacionId;

  const OrgMetricsScreen({super.key, required this.organizacionId});

  @override
  OrgMetricsScreenState createState() => OrgMetricsScreenState();
}

class OrgMetricsScreenState extends State<OrgMetricsScreen> {
  late Future<List<Map<String, dynamic>>> _eventsData;
  int totalHours = 0;
  int totalVolunteers = 0;

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
    int accumulatedHours = 0;
    int accumulatedVolunteers = 0;

    for (var eventDoc in eventsSnapshot.docs) {
      var eventData = eventDoc.data() as Map<String, dynamic>;
      String eventName = eventData['name'] ?? 'Sin nombre';
      int eventDuration = int.tryParse(eventData['duration'].toString()) ?? 0;

      QuerySnapshot registrationsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventDoc.id)
          .collection('registrations')
          .get();

      int registeredVolunteers = registrationsSnapshot.docs.length;
      
      accumulatedHours += eventDuration;
      accumulatedVolunteers += registeredVolunteers;

      eventsList.add({
        'name': eventName,
        'duration': eventDuration,
        'volunteers': registeredVolunteers,
      });
    }

    setState(() {
      totalHours = accumulatedHours;
      totalVolunteers = accumulatedVolunteers;
    });

    return eventsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Métricas de Eventos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _eventsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.red));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar métricas', style: TextStyle(color: Colors.black)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay eventos registrados.', style: TextStyle(color: Colors.black)));
          } else {
            final events = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 🛠️ Indicador de Horas Acumuladas
                  _buildGaugeChart(
                    title: "Horas Acumuladas",
                    value: totalHours.toDouble(),
                    maxValue: 100, // Puedes cambiarlo según la escala deseada
                    color: Colors.red,
                  ),

                  // 🛠️ Indicador de Voluntarios Registrados
                  _buildGaugeChart(
                    title: "Voluntarios Registrados",
                    value: totalVolunteers.toDouble(),
                    maxValue: 50, // Puedes cambiarlo según la escala deseada
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 20),
                  const Text("Detalles de Eventos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),

                  // 📝 Lista de eventos con métricas
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        color: Colors.white,
                        elevation: 3,
                        margin: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ListTile(
                            title: Text(
                              event['name'],
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Horas acumuladas: ${event['duration']}",
                                    style: const TextStyle(color: Colors.black, fontSize: 14)),
                                Text("Voluntarios registrados: ${event['volunteers']}",
                                    style: const TextStyle(color: Colors.black, fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // 📊 Método para construir el gráfico de tipo medidor (Gauge Chart)
  Widget _buildGaugeChart({required String title, required double value, required double maxValue, required Color color}) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: maxValue,
                ranges: <GaugeRange>[
                  GaugeRange(startValue: 0, endValue: maxValue * 0.3, color: Colors.green),
                  GaugeRange(startValue: maxValue * 0.3, endValue: maxValue * 0.7, color: Colors.orange),
                  GaugeRange(startValue: maxValue * 0.7, endValue: maxValue, color: color),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(value: value, needleColor: Colors.black),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Text(
                      "${value.toInt()}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    angle: 90,
                    positionFactor: 0.5,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
