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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController(); // Date of Birth
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
          _nameController.text = doc.data()?['name'] ?? "Unknown";
          _emailController.text = user.email ?? "";
          _phoneController.text = doc.data()?['phone'] ?? "";
          _dateController.text = doc.data()?['date'] ?? "";
          _locationController.text = doc.data()?['location'] ?? "";
          _interestsController.text = (doc.data()?['interests'] as List<dynamic>?)?.join("\n") ?? "";
          _skillsController.text = (doc.data()?['skills'] as List<dynamic>?)?.join("\n") ?? "";
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          // ✅ Actualizar email si fue cambiado
          if (_emailController.text.trim() != user.email) {
            await user.updateEmail(_emailController.text.trim());
          }

          // ✅ Actualizar contraseña si fue ingresada una nueva
          if (_passwordController.text.trim().isNotEmpty) {
            await user.updatePassword(_passwordController.text.trim());
          }

          // ✅ Guardar los cambios en Firestore
          await FirebaseFirestore.instance.collection('volunteers').doc(user.uid).set({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'date': _dateController.text.trim(),
            'location': _locationController.text.trim(),
            'interests': _interestsController.text.trim().split("\n"),
            'skills': _skillsController.text.trim().split("\n"),
          }, SetOptions(merge: true));

          Navigator.pop(context, true);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating profile: $e")));
        }
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
              _buildTextField(_nameController, "Full Name", Icons.person),
              _buildTextField(_emailController, "Email", Icons.email),
              _buildTextField(_passwordController, "New Password (Leave blank if unchanged)", Icons.lock, isPassword: true),
              _buildTextField(_phoneController, "Phone Number", Icons.phone),
              _buildTextField(_dateController, "Date of Birth (YYYY-MM-DD)", Icons.calendar_today),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isMultiline = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        maxLines: isMultiline ? 3 : 1,
      ),
    );
  }
}
