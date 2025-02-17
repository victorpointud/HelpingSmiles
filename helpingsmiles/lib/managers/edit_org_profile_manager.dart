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

  String _convertToMultiline(dynamic data) {
    if (data is List) {
      return data.join("\n"); 
    } else if (data is String) {
      return data;
    } else {
      return "";
    }
  }

  List<String> _convertToList(String text) {
    return text.trim().isNotEmpty ? text.trim().split("\n") : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Edit Organization Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileSection(Icons.flag, "Mission", _missionController),
                  _buildProfileSection(Icons.list, "Objectives (One per line)", _objectivesController),
                  _buildProfileSection(Icons.people, "Volunteer Types (One per line)", _volunteerTypesController),
                  _buildProfileSection(Icons.location_on, "Locations (One per line)", _locationsController),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Save Changes", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(IconData icon, String title, TextEditingController controller) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  TextFormField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}