import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String? name;

  @override
  void initState() {
    super.initState();
    _loadOrganizationData();
    _activityNameController = TextEditingController(text: widget.eventData["name"]);
    _dateController = TextEditingController(text: widget.eventData["date"]);
    _durationController = TextEditingController(text: widget.eventData["duration"]);
    _volunteerTypeController = TextEditingController(text: widget.eventData["volunteerType"]);
    _locationController = TextEditingController(text: widget.eventData["location"]);
    _descriptionController = TextEditingController(text: widget.eventData["description"]);
  }

  Future<void> _loadOrganizationData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('organizations').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          name = doc['name'] ?? "Not specified";
        });
      }
    }
  }

  Future<void> _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('events').doc(widget.eventId).update({
          'name': _activityNameController.text.trim(),
          'date': _dateController.text.trim(),
          'duration': _durationController.text.trim(),
          'volunteerType': _volunteerTypeController.text.trim(),
          'location': _locationController.text.trim(),
          'description': _descriptionController.text.trim(),
        });

        _showSuccessDialog();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating activity: $e")));
      }
    }
  }

  Future<void> _deleteEvent() async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(widget.eventId).delete();
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting activity: $e")));
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Activity", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        content: const Text("Are you sure you want to delete this activity? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 34, 9, 255))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent();
            },
            child: const Text("Delete", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 17, 0))),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        content: const Text("Changes saved successfully.", style: TextStyle(fontSize: 16, color: Colors.black)),
        actions: [
          Center(
            child: CircularProgressIndicator(color: Colors.red),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          name ?? "Organization Activity",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
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
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    color: Colors.white,
                    elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Edit Activity", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                            const SizedBox(height: 10),
                            _buildTextField(_activityNameController, "Activity Name", Icons.event),
                            _buildTextField(_dateController, "Date (YYYY-MM-DD)", Icons.calendar_today),
                            _buildTextField(_durationController, "Duration (hours)", Icons.timelapse),
                            _buildTextField(_volunteerTypeController, "Volunteer Type", Icons.people),
                            _buildTextField(_locationController, "Location", Icons.location_on),
                            _buildMultiLineTextField(_descriptionController, "Description", Icons.description),
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
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          prefixIcon: Icon(icon, color: Colors.red),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value!.isEmpty ? "Please enter $label" : null,
      ),
    );
  }

  Widget _buildMultiLineTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          prefixIcon: Icon(icon, color: Colors.red),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}