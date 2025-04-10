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
  String? selectedDuration;
  String? selectedInterest;
  String? selectedSkill;
  List<String> durations = [];
  List<String> interests = [];
  List<String> skills = [];

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
        'duration': data['duration'] ?? "No duration provided",
        'interest': data['interest'] ?? "No interest provided",
        'skills': (data['skills'] != null && data['skills'] is List) 
            ? (data['skills'] as List).map((e) => e.toString()).toList()
            : [], 
      };
    }).toList();

    filteredEvents = List.from(events);

    durations = events.map((event) => event['duration'].toString()).toSet().toList();
    durations.insert(0, "All");

    interests = events.map((event) => event['interest'].toString()).toSet().toList();
    interests.insert(0, "All");

    skills = events
        .where((event) => event['skills'] != null) 
        .expand((event) => (event['skills'] as List<dynamic>).map((e) => e.toString())) 
        .toSet()
        .toList();

    skills.insert(0, "All"); 
  });
}


  void _applyFilters() {
    setState(() {
      filteredEvents = events.where((event) {
        final matchesDuration = selectedDuration == "All" || selectedDuration == null || event['duration'] == selectedDuration;
        final matchesInterest = selectedInterest == "All" || selectedInterest == null || event['interest'] == selectedInterest;
        final matchesSkill = selectedSkill == "All" || selectedSkill == null || (event['skills'] as List<String>).contains(selectedSkill);
        return matchesDuration && matchesInterest && matchesSkill;
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
                  filteredEvents = List.from(events);
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
              Text("${event["date"]} • ${event["duration"]}h • ${event["interest"]}", style: const TextStyle(color: Colors.black)),
              const Text("Tap to view details.", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
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