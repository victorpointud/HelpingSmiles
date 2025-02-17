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

  String _organizationName = "Loading...";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrganizationData();
  }

  Future<void> _loadOrganizationData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('organizations').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _organizationName = doc.data()?['name'] ?? "Unknown Organization";
        });
      }
    }
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not authenticated.")));
      setState(() => _isLoading = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('events').add({
        'organizationId': user.uid,
        'organizationName': _organizationName,
        'name': _activityNameController.text.trim(),
        'date': _dateController.text.trim(),
        'duration': _durationController.text.trim(),
        'volunteerType': _volunteerTypeController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving activity: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        content: const Text("The activity has been added successfully.", style: TextStyle(fontSize: 16, color: Colors.black)),
        actions: [
          Center(child: CircularProgressIndicator(color: Colors.red)),
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
          " $_organizationName",
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
                            const Text(
                              "Add New Event",
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            const SizedBox(height: 10),
                            _buildTextField(_activityNameController, "Activity Name", Icons.event),
                            _buildTextField(_dateController, "Date (YYYY-MM-DD)", Icons.calendar_today),
                            _buildTextField(_durationController, "Duration (hours)", Icons.timelapse),
                            _buildTextField(_volunteerTypeController, "Volunteer Type", Icons.people),
                            _buildTextField(_locationController, "Location", Icons.location_on),
                            _buildTextField(_descriptionController, "Description", Icons.description, isMultiline: true),
                            const SizedBox(height: 20),
                            _isLoading
                                ? const CircularProgressIndicator(color: Colors.red)
                                : _buildSaveButton(),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          prefixIcon: Icon(icon, color: Colors.red),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        maxLines: isMultiline ? 3 : 1,
        validator: (value) => value!.isEmpty ? "Please enter $label" : null,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveActivity,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("Save Activity", style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}