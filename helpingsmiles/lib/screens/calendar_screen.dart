import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

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
        debugPrint("📄 Documento Firestore: $data");

        if (data.containsKey('date')) {
          try {
            // Convertir la cadena 'YYYY-MM-DD' a DateTime
            DateTime eventDate = DateTime.parse(data['date']); 

            // Normalizar la fecha (quitar horas, minutos, segundos)
            DateTime normalizedDate = DateTime(eventDate.year, eventDate.month, eventDate.day);

            // Agregar al mapa de eventos
            tempEvents[normalizedDate] = tempEvents[normalizedDate] ?? [];
            tempEvents[normalizedDate]!.add({
              'name': data['name'] ?? 'Unnamed Event',
              'location': data['location'] ?? 'No location provided',
            });

            debugPrint("Evento agregado: $normalizedDate -> ${tempEvents[normalizedDate]}");

          } catch (e) {
            debugPrint("Error al convertir la fecha: ${data['date']} -> $e");
          }
        }
      }

      setState(() {
        _events = tempEvents;
      });

      debugPrint("Eventos cargados en _events: $_events");
    } catch (e) {
      debugPrint("Error cargando eventos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Event Calendar")),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
              });
            },
            eventLoader: (day) {
              DateTime normalizedDay = DateTime(day.year, day.month, day.day);
              debugPrint("🔎 Buscando eventos para: $normalizedDay");
              return _events[normalizedDay] ?? [];
            },
          ),
          Expanded(
            child: ListView(
              children: (_events[_selectedDay] ?? []).map((event) {
                return ListTile(
                  title: Text(event['name']),
                  subtitle: Text(event['location']),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}