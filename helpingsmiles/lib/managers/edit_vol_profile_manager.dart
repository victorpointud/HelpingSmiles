import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditVolProfileManager extends StatefulWidget {
  const EditVolProfileManager({super.key});

  @override
  _EditVolProfileManagerState createState() => _EditVolProfileManagerState();
}

class _EditVolProfileManagerState extends State<EditVolProfileManager> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _interestsController = TextEditingController();
  final _skillsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVolunteerData();
  }

  Future<void> _loadVolunteerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('volunteers').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _locationController.text = doc['location'] ?? "";
          _interestsController.text = (doc['interests'] as List<dynamic>?)?.join("\n") ?? "";
          _skillsController.text = (doc['skills'] as List<dynamic>?)?.join("\n") ?? "";
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('volunteers').doc(user.uid).set({
          'location': _locationController.text.trim(),
          'interests': _interestsController.text.trim().split("\n"),
          'skills': _skillsController.text.trim().split("\n"),
        }, SetOptions(merge: true));

        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Volunteer Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_locationController, "Location", Icons.location_on),
              _buildTextField(_interestsController, "Interests (One per line)", Icons.favorite, isMultiline: true),
              _buildTextField(_skillsController, "Skills (One per line)", Icons.star, isMultiline: true),
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
