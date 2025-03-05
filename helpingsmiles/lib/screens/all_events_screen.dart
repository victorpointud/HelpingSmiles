import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_info_screen.dart';

class AllEventsScreen extends StatefulWidget {
  const AllEventsScreen({super.key});

  @override
  _AllEventsScreenState createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredEvents = [];
  TextEditingController searchController = TextEditingController();
  String? selectedDuration; // Para almacenar la duración seleccionada
  String? selectedInterest; // Para almacenar el interés seleccionado
  List<String> durations = []; // Lista de duraciones únicas
  List<String> interests = []; // Lista de intereses únicos

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('events').get();
    setState(() {
      events = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? "Unnamed Event",
          'date': data['date'] ?? "No date provided",
          'location': data['location'] ?? "No location provided",
          'duration': data['duration'] ?? "No duration provided", // Manejar null
          'interest': data['interest'] ?? "No interest provided", // Manejar null
        };
      }).toList();
      filteredEvents = List.from(events);

      // Obtener las duraciones únicas de los eventos
      durations = events.map((event) => event['duration'].toString()).toSet().toList();
      durations.insert(0, "All"); // Agregar la opción "All" para mostrar todos los eventos

      // Obtener los intereses únicos de los eventos
      interests = events.map((event) => event['interest'].toString()).toSet().toList();
      interests.insert(0, "All"); // Agregar la opción "All" para mostrar todos los eventos
    });
  }

  void _filterEvents(String query) {
    setState(() {
      filteredEvents = events.where((event) {
        final name = event['name'].toString().toLowerCase();
        return name.contains(query.toLowerCase()); // Solo busca en el nombre del evento
      }).toList();
    });
  }

  void _filterByDuration(String? duration) {
    setState(() {
      selectedDuration = duration;
      _applyFilters();
    });
  }

  void _filterByInterest(String? interest) {
    setState(() {
      selectedInterest = interest;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      filteredEvents = events.where((event) {
        final matchesDuration = selectedDuration == "All" || selectedDuration == null || event['duration'] == selectedDuration;
        final matchesInterest = selectedInterest == "All" || selectedInterest == null || event['interest'] == selectedInterest;
        return matchesDuration && matchesInterest; // Aplicar ambos filtros
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "All Events",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(180), // Aumentamos la altura para los dropdowns
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onChanged: _filterEvents,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<String>(
                  value: selectedDuration,
                  decoration: InputDecoration(
                    hintText: 'Filter by duration',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  items: durations.map((duration) {
                    return DropdownMenuItem(
                      value: duration,
                      child: Text(duration),
                    );
                  }).toList(),
                  onChanged: _filterByDuration,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<String>(
                  value: selectedInterest,
                  decoration: InputDecoration(
                    hintText: 'Filter by interest',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  items: interests.map((interest) {
                    return DropdownMenuItem(
                      value: interest,
                      child: Text(interest),
                    );
                  }).toList(),
                  onChanged: _filterByInterest,
                ),
              ),
            ],
          ),
        ),
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: filteredEvents.isEmpty
                  ? const Center(child: Text("No events found.", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        return _buildEventCard(event);
                      },
                    ),
            ),
          ),
        ],
      ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event["name"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 5),
              Text("${event["date"]} • ${event["location"]}", style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 5),
              Text("Duration: ${event["duration"]}", style: const TextStyle(color: Colors.black)), // Mostrar la duración
              const SizedBox(height: 5),
              Text("Interest: ${event["interest"]}", style: const TextStyle(color: Colors.black)), // Mostrar el interés
              const SizedBox(height: 5),
              const Text("Click to see more info", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
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
}