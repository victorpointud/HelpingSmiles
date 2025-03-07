import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'registered_event_info_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('events').get();
      Map<DateTime, List<Map<String, dynamic>>> tempEvents = {};
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('date')) {
          try {
            DateTime eventDate = DateTime.parse(data['date']); 
            DateTime normalizedDate = DateTime(eventDate.year, eventDate.month, eventDate.day);

            tempEvents[normalizedDate] = tempEvents[normalizedDate] ?? [];
            tempEvents[normalizedDate]!.add({
              'id': doc.id,
              'name': data['name'] ?? 'Unnamed Event',
              'location': data['location'] ?? 'No location provided',
              'date': data['date'] ?? 'No date available',
              'description': data['description'] ?? 'No description available',
            });
          } catch (e) {}
        }
      }

      setState(() {
        _events = tempEvents;
      });
    } catch (e) {}
  }

  void _navigateToRegisteredEventInfoDetails(String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisteredEventInfoScreen(eventId: eventId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Events Calendar",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(35),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TableCalendar(
                  focusedDay: _selectedDay,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                    });
                  },
                  eventLoader: (day) {
                    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
                    return _events[normalizedDay] ?? [];
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    defaultTextStyle: const TextStyle(color: Colors.black),
                    weekendTextStyle: const TextStyle(color: Colors.black),
                    markerDecoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.black),
                    weekendStyle: TextStyle(color: Colors.black),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: (_events[_selectedDay] ?? []).map((event) {
                    return GestureDetector(
                      onTap: () => _navigateToRegisteredEventInfoDetails(event['id']),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "📅 ${event['date']}",
                                style: const TextStyle(color: Colors.black),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "📍 ${event['location']}",
                                style: const TextStyle(color: Colors.black),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Click to see more information.",
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
