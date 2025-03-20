import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'registered_event_info_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllRegisteredEventsScreen extends StatefulWidget {
  const AllRegisteredEventsScreen({super.key});

  @override
  _AllRegisteredEventsScreenState createState() => _AllRegisteredEventsScreenState();
}

class _AllRegisteredEventsScreenState extends State<AllRegisteredEventsScreen> {
  List<Map<String, dynamic>> registeredEvents = [];
  List<Map<String, dynamic>> filteredRegisteredEvents = [];
  String? selectedDuration;
  String? selectedInterest;
  String? selectedSkill;
  List<String> durations = [];
  List<String> interests = [];
  List<String> skills = [];

  @override
  void initState() {
    super.initState();
    _loadRegisteredEvents();
  }

  Future<void> _loadRegisteredEvents() async {
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
        // Verifica si el campo 'name' existe en el documento
        String name = eventDoc.data().containsKey('name') ? eventDoc['name'] : "Not provided";

        // Verifica si el campo 'date' existe en el documento
        String date = eventDoc.data().containsKey('date') ? eventDoc['date'] : "Not provided";

        // Verifica si el campo 'location' existe en el documento
        String location = eventDoc.data().containsKey('location') ? eventDoc['location'] : "Not provided";

        // Verifica si el campo 'duration' existe en el documento
        String duration = eventDoc.data().containsKey('duration') ? eventDoc['duration'].toString() : "Not provided";

        // Verifica si el campo 'interest' existe en el documento
        List<String> interestList = [];
        if (eventDoc.data().containsKey('interest')) {
          if (eventDoc['interest'] is List) {
            interestList = (eventDoc['interest'] as List).map((e) => e.toString()).toList();
          } else if (eventDoc['interest'] is String) {
            interestList = [eventDoc['interest'].toString()]; // Si es un String, conviértelo a una lista
          }
        } else {
          interestList = ["Not provided"]; // Valor predeterminado si el campo no existe
        }

        // Verifica si el campo 'skills' existe en el documento
        List<String> skillsList = [];
        if (eventDoc.data().containsKey('skills') && eventDoc['skills'] is List) {
          skillsList = (eventDoc['skills'] as List).map((e) => e.toString()).toList();
        } else {
          skillsList = ["Not provided"]; // Valor predeterminado si el campo no existe
        }

        // Añade el evento a la lista temporal
        tempEvents.add({
          'id': eventId,
          'name': name,
          'date': date,
          'location': location,
          'duration': duration,
          'interest': interestList,
          'skills': skillsList,
        });
      }
    }

    if (!mounted) return;

    setState(() {
      registeredEvents = tempEvents;
      filteredRegisteredEvents = List.from(registeredEvents);

      // Obtener intereses únicos para los filtros
      interests = registeredEvents
          .expand((event) => (event['interest'] as List<String>))
          .toSet()
          .toList();
      interests.insert(0, "All");

      // Obtener duraciones únicas para los filtros
      durations = registeredEvents
          .map((event) => event['duration'].toString())
          .toSet()
          .toList();
      durations.insert(0, "All");

      // Obtener habilidades únicas para los filtros
      skills = registeredEvents
          .expand((event) => (event['skills'] as List<String>))
          .toSet()
          .toList();
      skills.insert(0, "All");
    });

  } catch (e) {
    print("Error loading registered events: $e");
  }
}

  void _applyFilters() {
    setState(() {
      filteredRegisteredEvents = registeredEvents.where((org) {

        final matchesInterest = selectedInterest == "All" ||
            selectedInterest == null ||
            org['interest'].contains(selectedInterest);

        final matchesSkill = selectedSkill == "All" ||
            selectedSkill == null ||
            org['skills'].contains(selectedSkill);

        final matchesDuration = selectedDuration == "All" ||
            selectedDuration == null ||
            org['duration'].contains(selectedDuration);

        return matchesInterest && matchesSkill && matchesDuration;
      }).toList();
    });
  }

  void _showFilterPopUp() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.all(10),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Filter Events", style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDropdown("Duration", selectedDuration, durations, (value) {
                  setState(() => selectedDuration = value);
                }),
                const SizedBox(height: 10),
                _buildDropdown("Interest", selectedInterest, interests, (value) {
                  setState(() => selectedInterest = value);
                }),
                const SizedBox(height: 10),
                _buildDropdown("Skills", selectedSkill, skills, (value) {
                  setState(() => selectedSkill = value);
                }),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedDuration = null;
                  selectedInterest = null;
                  selectedSkill = null;
                  filteredRegisteredEvents = List.from(registeredEvents);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Clear Filters", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                _applyFilters();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Apply Filters", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown(String label, String? selectedValue, List<String> options, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (value) => onChanged(value),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: _showFilterPopUp,
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: filteredRegisteredEvents.isEmpty
                  ? const Center(child: Text("No events found.", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: filteredRegisteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredRegisteredEvents[index];
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
    onTap: () => _navigateToRegisteredEventInfo(event["id"]),
    child: Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.red, width: 2),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event["name"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 5),
            Text(
              "${event["date"]} • ${event["location"]} • ${event["duration"]}h • ${event["interest"].join(", ")}",
              style: const TextStyle(color: Colors.black),
            ),
            const Text("Tap to view details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    ),
  );
}
  void _navigateToRegisteredEventInfo(String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisteredEventInfoScreen(eventId: eventId),
      ),
    );
  }
}