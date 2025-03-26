import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditOrgProfileManager extends StatefulWidget {
  final String organizationId;

  const EditOrgProfileManager({super.key, required this.organizationId});

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
  final _repNameController = TextEditingController();
  final _repLastNameController = TextEditingController();
  final _repPhoneController = TextEditingController();
  final _repEmailController = TextEditingController();

  List<String> selectedVolunteerTypes = [];
  List<String> selectedLocations = [];

  final List<String> availableVolunteerTypes = [
    "Administration", "Education", "Medical Assistance", "Community Service", 
    "Environmental", "Technology", "Sports", "Other"
  ];

  final List<String> availableLocations = [
    "Venezuela", "USA", "Colombia", "Spain", "Mexico", "Argentina",
    "Germany", "France", "Italy", "Canada", "Brasil", "Online"
  ];

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
          _objectivesController.text = (doc.data()?['objectives'] as List<dynamic>?)?.join("\n") ?? "";
          selectedVolunteerTypes = List<String>.from(doc.data()?['volunteerTypes'] ?? []);
          selectedLocations = List<String>.from(doc.data()?['locations'] ?? []);
        });

        _loadRepresentativeData(user.uid);
      }
    }
  }

  Future<void> _loadRepresentativeData(String organizationId) async {
    final repDoc = await FirebaseFirestore.instance
        .collection('organizations')
        .doc(organizationId)
        .collection('representatives')
        .doc('info')
        .get();

    if (repDoc.exists) {
      setState(() {
        _repNameController.text = repDoc.data()?['repName'] ?? "";
        _repLastNameController.text = repDoc.data()?['repLastName'] ?? "";
        _repPhoneController.text = repDoc.data()?['repPhone'] ?? "";
        _repEmailController.text = repDoc.data()?['repEmail'] ?? "";
      });
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
        bool isEmailChanged = _emailController.text.trim() != user.email;
        bool isPasswordChanged = _passwordController.text.trim().isNotEmpty;

        if (isEmailChanged || isPasswordChanged) {
          bool reauthenticated = await _reauthenticateUser();
          if (!reauthenticated) return;
        }

        if (isEmailChanged) {
          await user.updateEmail(_emailController.text.trim());
        }

        if (isPasswordChanged) {
          await user.updatePassword(_passwordController.text.trim());
        }

        await FirebaseFirestore.instance.collection('organizations').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'date': _dateController.text.trim(),
          'email': _emailController.text.trim(),
          'mission': _missionController.text.trim(),
          'volunteerTypes': selectedVolunteerTypes,
          'locations': selectedLocations,
        }, SetOptions(merge: true));

        await FirebaseFirestore.instance
            .collection('organizations')
            .doc(user.uid)
            .collection('representatives')
            .doc('info')
            .set({
          'repName': _repNameController.text.trim(),
          'repLastName': _repLastNameController.text.trim(),
          'repPhone': _repPhoneController.text.trim(),
          'repEmail': _repEmailController.text.trim(),
        }, SetOptions(merge: true));

        _showSuccessDialog();

      } catch (e) {
          if (!mounted) return;
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
                            _buildMultiLineTextField(_objectivesController, "Objectives (One per line)", Icons.list),         
                            const SizedBox(height: 20),
                            _buildSelectionField("Volunteer Types", selectedVolunteerTypes, availableVolunteerTypes, Icons.people, (newSelection) {
                              setState(() => selectedVolunteerTypes = newSelection);
                            }),
                            _buildSelectionField("Locations", selectedLocations, availableLocations, Icons.location_on, (newSelection) {
                              setState(() => selectedLocations = newSelection);
                            }),
                            const SizedBox(height: 20),
                            const Text("Representative Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                            const SizedBox(height: 20),
                            _buildTextField(_repNameController, "Representative First Name", Icons.person),
                            _buildTextField(_repLastNameController, "Representative Last Name", Icons.person_outline),
                            _buildTextField(_repPhoneController, "Representative Phone", Icons.phone),
                            _buildTextField(_repEmailController, "Representative Email", Icons.email),
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

  void _showMultiSelectDialog(List<String> options, List<String> selectedList, String title, Function(List<String>) onSelected) {
    showDialog(
      context: context,
      builder: (context) {
        List<String> tempSelected = List.from(selectedList);
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: options.map((option) {
                    return ListTile(
                      title: Text(option, style: const TextStyle(color: Colors.black)),
                      leading: Icon(
                        tempSelected.contains(option) ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: tempSelected.contains(option) ? Colors.red : Colors.grey,
                      ),
                      onTap: () {
                        setState(() {
                          if (tempSelected.contains(option)) {
                            tempSelected.remove(option);
                          } else {
                            tempSelected.add(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                onSelected(tempSelected);
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectionField(String label, List<String> selectedList, List<String> options, IconData icon, Function(List<String>) onSelected) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: InkWell(
      onTap: () => _showMultiSelectDialog(options, selectedList, "Select $label", onSelected),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          prefixIcon: Icon(icon, color: Colors.red),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedList.isNotEmpty ? selectedList.join(", ") : "Tap to select",
                style: const TextStyle(color: Colors.black, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
      ),
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
          prefixIcon: Icon(icon, color: Colors.red),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
