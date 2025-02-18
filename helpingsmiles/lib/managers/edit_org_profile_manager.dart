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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _missionController = TextEditingController();
  final _objectivesController = TextEditingController();
  final _volunteerTypesController = TextEditingController();
  final _locationsController = TextEditingController();

  String _organizationName = "Loading...";

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
          _organizationName = doc.data()?['name'] ?? "";
          _nameController.text = doc.data()?['name'] ?? "";
          _emailController.text = user.email ?? "";
          _phoneController.text = doc.data()?['phone'] ?? "";
          _dateController.text = doc.data()?['date'] ?? "";
          _passwordController.text = doc.data()?['password'] ?? "";
          _missionController.text = doc.data()?['mission'] ?? "";
          _locationsController.text = (doc.data()?['locations'] as List<dynamic>?)?.join("\n") ?? "";
          _objectivesController.text = (doc.data()?['objectives'] as List<dynamic>?)?.join("\n") ?? "";
          _volunteerTypesController.text = (doc.data()?['volunteerTypes'] as List<dynamic>?)?.join("\n") ?? "";

        });
      }
    }
  }

  Future<void> _saveProfile() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No user is signed in. Please log in again.")),
    );
    return;
  }

  if (_formKey.currentState!.validate()) {
    try {
      
      if (_emailController.text.trim() != user.email || _passwordController.text.trim().isNotEmpty) {
        bool reauthenticated = await _reauthenticateUser();
        if (!reauthenticated) return;
      }

      if (_emailController.text.trim() != user.email) {
        await user.updateEmail(_emailController.text.trim());
      }

      if (_passwordController.text.trim().isNotEmpty) {
        await user.updatePassword(_passwordController.text.trim());
      }

      await FirebaseFirestore.instance.collection('organizations').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'date': _dateController.text.trim(),
        'email': _emailController.text.trim(),
        'mission': _missionController.text.trim(),
        'password': _passwordController.text.trim(), 
        'locations': _locationsController.text.trim().split("\n").where((item) => item.isNotEmpty).toList(),
        'objectives': _objectivesController.text.trim().split("\n").where((item) => item.isNotEmpty).toList(),
        'volunteerTypes': _volunteerTypesController.text.trim().split("\n").where((item) => item.isNotEmpty).toList(),
      }, SetOptions(merge: true));

      _showSuccessDialog();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: ${e.toString()}")),
      );
    }
  }
}


Future<bool> _reauthenticateUser() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return false;

  try {
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: _passwordController.text.trim(), 
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
        automaticallyImplyLeading: true,
        title: Text(
          _organizationName,
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
                              "Edit Profile",
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            const SizedBox(height: 10),
                            _buildTextField(_nameController, "Org Name", Icons.business),
                            _buildTextField(_emailController, "Email", Icons.email),
                            _buildTextField(_passwordController, "New Password (Leave blank if unchanged)", Icons.lock, isPassword: true),
                            _buildTextField(_phoneController, "Phone Number", Icons.phone),
                            _buildTextField(_dateController, "Date of Creation", Icons.calendar_today),
                            _buildTextField(_missionController, "Mission", Icons.flag),
                            _buildMultiLineTextField(_locationsController, "Locations", Icons.location_on),
                            _buildMultiLineTextField(_objectivesController, "Objectives (One per line)", Icons.list),
                            _buildMultiLineTextField(_volunteerTypesController, "Volunteer Types (One per line)", Icons.people),
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
          title: const Text("Success", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black)),
          content: const Text("Your profile has been updated successfully.", style: TextStyle(fontSize: 15, color: Colors.black)),
          actions: [
            Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            ),
          ],
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context); 
        Navigator.pop(context, true); 
      });
    }

}