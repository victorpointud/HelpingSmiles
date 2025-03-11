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
  final _organizationTypeController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _repNameController = TextEditingController();
  final _repLastNameController = TextEditingController();
  final _repPhoneController = TextEditingController();
  final _repEmailController = TextEditingController();

  String _organizationName = "Loading...";
  bool _isLoading = false;

  final List<String> _interests = [
    "Environment",
    "Education",
    "Health and Wellness",
    "Community and Social Development",
    "Art and Culture",
    "Sports and Recreation",
    "Human Rights and Social Justice",
    "Technology and Innovation",
    "Animals",
    "Emergency and Humanitarian Aid",
    "other"
  ];

  final List<String> _skills = [
    "All",
    "Communication",
    "Organization and logistics",
    "Teaching and mentoring",
    "Technical skills",
    "Manual skills",
    "Medical and care skills",
    "Artistic and cultural skills",
    "Sports and recreational skills",
    "Research and analytical skills",
    "Leadership and management skills",
    "other"
  ];

  String? _selectedInterest;

  String? _selectedSkills;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated."))
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      DocumentReference eventRef = await FirebaseFirestore.instance.collection('events').add({
        'organizationId': user.uid,
        'organizationName': _organizationName,
        'name': _activityNameController.text.trim(),
        'date': _dateController.text.trim(),
        'duration': _durationController.text.trim(),
        'organizationType': _organizationTypeController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'interest': _selectedInterest, 
        'skills': _selectedSkills,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await eventRef.collection('representatives').doc('info').set({
        'repName': _repNameController.text.trim(),
        'repLastName': _repLastNameController.text.trim(),
        'repPhone': _repPhoneController.text.trim(),
        'repEmail': _repEmailController.text.trim(),
      });

      _showSuccessDialog();
    } catch (e) {
      print("❌ Error al guardar actividad y representante: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving activity: $e"))
      );
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
                            _buildTextField(_organizationTypeController, "Organization Type", Icons.people),
                            _buildTextField(_locationController, "Location", Icons.location_on),
                            _buildTextField(_descriptionController, "Description", Icons.description, isMultiline: true),

                            const SizedBox(height: 20),

                            DropdownButtonFormField<String>(
                              value: _selectedInterest,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedInterest = newValue;
                                });
                              },
                              items: _interests.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                labelText: "Interest",
                                labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(Icons.favorite, color: Colors.red), // 🔥 Icono de Intereses
                              ),
                              validator: (value) => value == null ? "Please select an interest" : null,
                            ),

                            const SizedBox(height: 20),

                            DropdownButtonFormField<String>(
                              value: _selectedSkills,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedSkills = newValue;
                                });
                              },
                              items: _skills.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                labelText: "Skills",
                                labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(Icons.build, color: Colors.red),
                              ),
                              validator: (value) => value == null ? "Please select a skill" : null,
                            ),
                            const SizedBox(height: 20),

                            const SizedBox(height: 20),
                            const Text( "Activity Representative", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                            const SizedBox(height: 10),
                            _buildTextField(_repNameController, "First Name", Icons.person),
                            _buildTextField(_repLastNameController, "Last Name", Icons.person_outline),
                            _buildTextField(_repPhoneController, "Phone", Icons.phone),
                            _buildTextField(_repEmailController, "Email", Icons.email),

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

class MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;

  const MultiSelectDialog({required this.items, required this.selectedItems});

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  List<String> _tempSelectedItems = [];

  @override
  void initState() {
    super.initState();
    _tempSelectedItems = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Skills"),
      content: SingleChildScrollView(
        child: Column(
          children: widget.items.map((item) {
            return CheckboxListTile(
              title: Text(item),
              value: _tempSelectedItems.contains(item),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _tempSelectedItems.add(item);
                  } else {
                    _tempSelectedItems.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _tempSelectedItems);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}