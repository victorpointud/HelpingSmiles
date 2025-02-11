import 'package:flutter/material.dart';

class OrganizationProfileScreen extends StatefulWidget {
  const OrganizationProfileScreen({super.key});

  @override
  _OrganizationProfileScreenState createState() => _OrganizationProfileScreenState();
}

class _OrganizationProfileScreenState extends State<OrganizationProfileScreen> {
  String mission = "Supporting communities through volunteer efforts.";
  String objectives = "• Education support\n• Environmental sustainability\n• Charity events";

  void _editProfile() {
    TextEditingController missionController = TextEditingController(text: mission);
    TextEditingController objectivesController = TextEditingController(text: objectives);

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(missionController, "Mission"),
            _buildTextField(objectivesController, "Objectives"),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  mission = missionController.text;
                  objectives = objectivesController.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(controller: controller, decoration: InputDecoration(labelText: label)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Organization Profile"), actions: [IconButton(icon: const Icon(Icons.edit), onPressed: _editProfile)]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.business, size: 50)),
            _buildProfileSection("Mission", mission),
            _buildProfileSection("Objectives", objectives),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(content)),
    );
  }
}
