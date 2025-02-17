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
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _interestsController = TextEditingController();
  final _skillsController = TextEditingController();
  String? name;

  @override
  void initState() {
    super.initState();
    _loadVolunteerData();
  }

  Future<void> _loadVolunteerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('volunteers').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            name = doc.data()?['name'] ?? "Not specified";
            _nameController.text = doc.data()?['name'] ?? "Unknown";
            _emailController.text = user.email ?? "";
            _phoneController.text = doc.data()?['phone'] ?? "";
            _dateController.text = doc.data()?['date'] ?? "";
            _passwordController.text = ""; // No cargamos contraseñas en los campos
            _locationController.text = doc.data()?['location'] ?? "";
            _interestsController.text = (doc.data()?['interests'] as List<dynamic>?)?.join("\n") ?? "";
            _skillsController.text = (doc.data()?['skills'] as List<dynamic>?)?.join("\n") ?? "";
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading profile: $e")));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          // Reautenticación si se quiere cambiar email o contraseña
          if (_emailController.text.trim() != user.email || _passwordController.text.trim().isNotEmpty) {
            bool reauthenticated = await _reauthenticateUser();
            if (!reauthenticated) return;
          }

          // Actualizar email si cambió
          if (_emailController.text.trim() != user.email) {
            await user.updateEmail(_emailController.text.trim());
          }

          // Actualizar contraseña si se ingresó una nueva
          if (_passwordController.text.trim().isNotEmpty) {
            await user.updatePassword(_passwordController.text.trim());
          }

          // Actualizar Firestore con la nueva información
          await FirebaseFirestore.instance.collection('volunteers').doc(user.uid).set({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'date': _dateController.text.trim(),
            'location': _locationController.text.trim(),
            'interests': _interestsController.text.trim().split("\n").where((item) => item.isNotEmpty).toList(),
            'skills': _skillsController.text.trim().split("\n").where((item) => item.isNotEmpty).toList(),
          }, SetOptions(merge: true));

          _showSuccessDialog();

        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating profile: $e")));
        }
      }
    }
  }

  Future<bool> _reauthenticateUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return false;

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _passwordController.text.trim(), // ⚠️ El usuario debe ingresar la contraseña actual
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reauthentication failed: ${e.toString()}")),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          name ?? "Volunteer Profile",
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
                            const Text("Edit Profile", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                            const SizedBox(height: 10),
                            _buildTextField(_nameController, "Full Name", Icons.person),
                            _buildTextField(_emailController, "Email", Icons.email),
                            _buildTextField(_passwordController, "New Password (Leave blank if unchanged)", Icons.lock, isPassword: true),
                            _buildTextField(_phoneController, "Phone Number", Icons.phone),
                            _buildTextField(_dateController, "Date of Birth", Icons.calendar_today),
                            _buildTextField(_locationController, "Location", Icons.location_on),
                            _buildMultiLineTextField(_interestsController, "Interests (One per line)", Icons.favorite),
                            _buildMultiLineTextField(_skillsController, "Skills (One per line)", Icons.star),
                            const SizedBox(height: 20),
                            _buildSaveButton(),
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("Save Changes", style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Your profile has been updated successfully."),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      Navigator.pop(context, true);
    });
  }
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
