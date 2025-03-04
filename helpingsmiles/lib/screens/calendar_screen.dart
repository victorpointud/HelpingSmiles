import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final List<Map<String, dynamic>> events;
  
  const CalendarScreen({super.key, required this.events});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _eventsByDate = {};

  @override
  void initState() {
    super.initState();
    _groupEventsByDate();
  }

  void _groupEventsByDate() {
    final Map<DateTime, List<String>> groupedEvents = {};
    for (var event in widget.events) {
      DateTime eventDate = DateTime.parse(event["date"]);
      if (!groupedEvents.containsKey(eventDate)) {
        groupedEvents[eventDate] = [];
      }
      groupedEvents[eventDate]!.add(event["name"]);
    }
    setState(() {
      _eventsByDate = groupedEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Text(
            "Event Calendar",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return _eventsByDate[day] ?? [];
            },
            headerStyle: const HeaderStyle(formatButtonVisible: false),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _selectedDay != null && _eventsByDate[_selectedDay] != null
                ? ListView(
                    children: _eventsByDate[_selectedDay]!
                        .map((event) => ListTile(
                              title: Text(event, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              leading: const Icon(Icons.event, color: Colors.red),
                            ))
                        .toList(),
                  )
                : const Center(child: Text("No events on this day")),
          ),
        ],
      ),
    );
  }
}
