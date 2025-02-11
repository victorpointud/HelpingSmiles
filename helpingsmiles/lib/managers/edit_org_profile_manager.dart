import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditOrgProfileManager extends StatefulWidget {
  const EditOrgProfileManager({super.key});

  @override
  _EditOrgProfileManagerState createState() => _EditOrgProfileManagerState();
}

class _EditOrgProfileManagerState extends State<EditOrgProfileManager> {
  final _formKey = GlobalKey<FormState>();
  final _missionController = TextEditingController();
  final _objectivesController = TextEditingController();
  final _volunteerTypesController = TextEditingController();
  final _locationsController = TextEditingController();

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
        final data = doc.data() ?? {};
        setState(() {
          _missionController.text = _convertToMultiline(data['missions']);
          _objectivesController.text = _convertToMultiline(data['objectives']);
          _volunteerTypesController.text = _convertToMultiline(data['volunteerTypes']);
          _locationsController.text = _convertToMultiline(data['locations']);
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('organizations').doc(user.uid).set({
          'missions': _convertToList(_missionController.text),
          'objectives': _convertToList(_objectivesController.text),
          'volunteerTypes': _convertToList(_volunteerTypesController.text),
          'locations': _convertToList(_locationsController.text),
        }, SetOptions(merge: true));

        Navigator.pop(context, true);
      }
    }
  }

  // Convierte una lista en un string multilineal
  String _convertToMultiline(dynamic data) {
    if (data is List) {
      return data.join("\n"); 
    } else if (data is String) {
      return data;
    } else {
      return "";
    }
  }

  // Convierte el texto de los controladores en listas separadas por líneas
  List<String> _convertToList(String text) {
    return text.trim().isNotEmpty ? text.trim().split("\n") : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Organization Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_missionController, "Mission", Icons.flag, isMultiline: true),
              _buildTextField(_objectivesController, "Objectives (One per line)", Icons.list, isMultiline: true),
              _buildTextField(_volunteerTypesController, "Volunteer Types (One per line)", Icons.people, isMultiline: true),
              _buildTextField(_locationsController, "Locations (One per line)", Icons.location_on, isMultiline: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
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
