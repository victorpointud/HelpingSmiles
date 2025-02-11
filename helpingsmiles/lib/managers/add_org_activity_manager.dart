import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddOrgActivityManager extends StatefulWidget {
  const AddOrgActivityManager({super.key});

  @override
  _AddOrgActivityManagerState createState() => _AddOrgActivityManagerState();
}

class _AddOrgActivityManagerState extends State<AddOrgActivityManager> {
  final _formKey = GlobalKey<FormState>();
  final _activityNameController = TextEditingController();
  final _dateController = TextEditingController();
  final _durationController = TextEditingController();
  final _volunteerTypeController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = "User not authenticated.";
        _isLoading = false;
      });
      return;
    }

    try {
      // 🔹 Get user role from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final role = userDoc.exists ? userDoc['role'] : null;

      if (role != "organization") {
        setState(() {
          _errorMessage = "Permission denied: Only organizations can add events.";
          _isLoading = false;
        });
        return;
      }

      await FirebaseFirestore.instance.collection('events').add({
        'organizationId': user.uid,
        'name': _activityNameController.text.trim(),
        'date': _dateController.text.trim(),
        'duration': _durationController.text.trim(),
        'volunteerType': _volunteerTypeController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(), // 🔹 Save creation time
      });

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = "Error saving event: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Activity")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              _buildTextField(_activityNameController, "Activity Name", Icons.event),
              _buildTextField(_dateController, "Date (YYYY-MM-DD)", Icons.calendar_today),
              _buildTextField(_durationController, "Duration (hours)", Icons.timelapse),
              _buildTextField(_volunteerTypeController, "Volunteer Type", Icons.people),
              _buildTextField(_locationController, "Location", Icons.location_on),
              _buildTextField(_descriptionController, "Description", Icons.description, isMultiline: true),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveActivity,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Save Activity", style: TextStyle(color: Colors.white)),
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
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        maxLines: isMultiline ? 3 : 1,
        validator: (value) => value!.isEmpty ? "Please enter $label" : null,
      ),
    );
  }
}
