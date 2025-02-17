import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditOrgActivityManager extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EditOrgActivityManager({super.key, required this.eventId, required this.eventData});

  @override
  _EditOrgActivityManagerState createState() => _EditOrgActivityManagerState();
}

class _EditOrgActivityManagerState extends State<EditOrgActivityManager> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _activityNameController;
  late TextEditingController _dateController;
  late TextEditingController _durationController;
  late TextEditingController _volunteerTypeController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _activityNameController = TextEditingController(text: widget.eventData["name"]);
    _dateController = TextEditingController(text: widget.eventData["date"]);
    _durationController = TextEditingController(text: widget.eventData["duration"]);
    _volunteerTypeController = TextEditingController(text: widget.eventData["volunteerType"]);
    _locationController = TextEditingController(text: widget.eventData["location"]);
    _descriptionController = TextEditingController(text: widget.eventData["description"]);
  }

  Future<void> _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('events').doc(widget.eventId).update({
        'name': _activityNameController.text.trim(),
        'date': _dateController.text.trim(),
        'duration': _durationController.text.trim(),
        'volunteerType': _volunteerTypeController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
      });

      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteEvent() async {
    await FirebaseFirestore.instance.collection('events').doc(widget.eventId).delete();
    Navigator.pop(context, true);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Activity"),
        content: const Text("Are you sure you want to delete this activity?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              _deleteEvent();
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Edit Activity",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileSection(Icons.event, "Activity Name", _activityNameController),
                  _buildProfileSection(Icons.calendar_today, "Date (YYYY-MM-DD)", _dateController),
                  _buildProfileSection(Icons.timelapse, "Duration (hours)", _durationController),
                  _buildProfileSection(Icons.people, "Volunteer Type", _volunteerTypeController),
                  _buildProfileSection(Icons.location_on, "Location", _locationController),
                  _buildProfileList(Icons.description, "Description", _descriptionController),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _updateEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Save Changes", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: _confirmDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Delete Activity", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(IconData icon, String title, TextEditingController controller, {bool isPassword = false}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  TextFormField(
                    controller: controller,
                    obscureText: isPassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileList(IconData icon, String title, TextEditingController controller) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: Colors.red),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            ]),
            TextFormField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}