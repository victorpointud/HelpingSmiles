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
        title: const Text("Delete Event"),
        content: const Text("Are you sure you want to delete this event?"),
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
      appBar: AppBar(title: const Text("Edit Activity")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_activityNameController, "Activity Name", Icons.event),
              _buildTextField(_dateController, "Date (YYYY-MM-DD)", Icons.calendar_today),
              _buildTextField(_durationController, "Duration (hours)", Icons.timelapse),
              _buildTextField(_volunteerTypeController, "Volunteer Type", Icons.people),
              _buildTextField(_locationController, "Location", Icons.location_on),
              _buildTextField(_descriptionController, "Description", Icons.description, isMultiline: true),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _updateEvent, child: const Text("Save Changes")),
                  ElevatedButton(
                    onPressed: _confirmDelete,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Delete Event", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        maxLines: isMultiline ? 3 : 1,
      ),
    );
  }
}
