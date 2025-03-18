import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'registered_event_info_screen.dart';


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
      String eventName = eventData['name'] ?? 'Unnamed Event';
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
        'id': eventDoc.id,
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
        title: const Text(
          'Metrics',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
      ),
      body: Stack(
        children: [
          // Fondo con opacidad
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _eventsData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.red));
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading metrics', style: TextStyle(color: Colors.white)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No events registered.', style: TextStyle(color: Colors.white)));
                } else {
                  final events = snapshot.data!;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Card(
                        color: Colors.white,
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildGaugeChart(
                                title: "Acumulated Hours",
                                value: totalHours.toDouble(),
                                maxValue: 100,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 20),
                              _buildGaugeChart(
                                title: "Registered Volunteers",
                                value: totalVolunteers.toDouble(),
                                maxValue: 50,
                                color: Colors.blue,
                              ),

                              const SizedBox(height: 20),
                              const Text(
                                "Events Details",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                              ),

                              const SizedBox(height: 10),

                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  final event = events[index];
                                  return _buildEventCard(context, event); 
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
  return GestureDetector(
    onTap: () {

      Navigator.push(context, MaterialPageRoute( builder: (context) => RegisteredEventInfoScreen(eventId: event['id'])),
      );
    },
    child: Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.red, width: 2),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['name'],
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.black, size: 20),
                const SizedBox(width: 5),
                const Text(
                  "Hours: ",
                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${event['duration']}",
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.people, color: Colors.black, size: 20),
                const SizedBox(width: 5),
                const Text(
                  "Volunteers: ",
                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${event['volunteers']}",
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildGaugeChart({required String title, required double value, required double maxValue, required Color color}) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
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
                  GaugeRange(startValue: maxValue * 0.7, endValue: maxValue, color: Colors.red),

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
