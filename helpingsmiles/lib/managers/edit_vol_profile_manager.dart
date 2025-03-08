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

  List<String> selectedInterests = [];
  List<String> selectedSkills = [];

  String _volunteerName = "Loading...";

  final List<String> availableInterests = [
    "Education", "Environment", "Health", "Animal Care", "Community Service", "Technology", "Art & Culture", "Sports"
  ];

  final List<String> availableSkills = [
    "Communication", "Organization", "Mentoring", "Technical", "Manual Labor", "Medical", "Artistic", "Leadership"
  ];


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
          _volunteerName = doc.data()?['name'] ?? "Unknown Volunteer";
          _nameController.text = doc.data()?['name'] ?? "";
          _emailController.text = user.email ?? "";
          _phoneController.text = doc.data()?['phone'] ?? "";
          _dateController.text = doc.data()?['date'] ?? "";
          _passwordController.text = "";
          _locationController.text = doc.data()?['location'] ?? "";
          selectedInterests = List<String>.from(doc.data()?['interests'] ?? []);
          selectedSkills = List<String>.from(doc.data()?['skills'] ?? []);
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

      await FirebaseFirestore.instance.collection('volunteers').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'date': _dateController.text.trim(),
        'location': _locationController.text.trim(),
        'interests': selectedInterests,
        'skills': selectedSkills,
      }, SetOptions(merge: true));

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: ${e.toString()}")),
      );
    }
  }
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
        title: Text(
          _volunteerName,
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
                            _buildTextField(_nameController, "Full Name", Icons.person),
                            _buildTextField(_emailController, "Email", Icons.email),
                            _buildTextField(_passwordController, "New Password (Leave blank if unchanged)", Icons.lock, isPassword: true),
                            _buildTextField(_phoneController, "Phone Number", Icons.phone),
                            _buildTextField(_dateController, "Date of Birth", Icons.calendar_today),
                            _buildTextField(_locationController, "Location", Icons.location_on),
                            _buildSelectionField("Interests", selectedInterests, availableInterests, Icons.favorite, (newSelection) {
                              setState(() => selectedInterests = newSelection);
                            }),
                            _buildSelectionField("Skills", selectedSkills, availableSkills, Icons.star, (newSelection) {
                              setState(() => selectedSkills = newSelection);
                            }),
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
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        prefixIcon: Icon(icon, color: Colors.red),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (!isPassword && value!.isEmpty) {
          return "Please enter $label"; 
        }
        return null; 
      },
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