import 'package:flutter/material.dart';

class OrganizationProfileScreen extends StatefulWidget {
  const OrganizationProfileScreen({super.key});

  @override
  _OrganizationProfileScreenState createState() => _OrganizationProfileScreenState();
}

class _OrganizationProfileScreenState extends State<OrganizationProfileScreen> {
  String mission = "Our mission is to support underprivileged communities through volunteer efforts.";
  String objectives = "• Provide educational support\n• Promote environmental sustainability\n• Organize charity events";
  int volunteers = 50; // Número de voluntarios actualmente

  void _editProfile() {
    TextEditingController missionController = TextEditingController(text: mission);
    TextEditingController objectivesController = TextEditingController(text: objectives);
    TextEditingController volunteersController = TextEditingController(text: volunteers.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Edit Organization Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                TextField(controller: missionController, decoration: const InputDecoration(labelText: "Mission")),
                const SizedBox(height: 10),
                TextField(controller: objectivesController, decoration: const InputDecoration(labelText: "Objectives"), maxLines: 3),
                const SizedBox(height: 10),
                TextField(controller: volunteersController, decoration: const InputDecoration(labelText: "Number of Volunteers"), keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      mission = missionController.text;
                      objectives = objectivesController.text;
                      volunteers = int.tryParse(volunteersController.text) ?? volunteers;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: const Text("Save Changes"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Organization Profile",
          style: TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFFE57373), 
        actions: [
          IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: _editProfile),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo de la organización con un diseño llamativo
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.red.shade200,
              child: const Icon(Icons.business, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Contenedor de información bien estructurado
            _buildProfileSection(Icons.compass_calibration, "Mission", mission),
            _buildProfileSection(Icons.star, "Objectives", objectives),
            _buildProfileSection(Icons.people, "Volunteers", "$volunteers active volunteers"),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(IconData icon, String title, String content) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.red),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
