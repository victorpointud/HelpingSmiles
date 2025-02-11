import 'package:flutter/material.dart';

class VolunteerProfileScreen extends StatefulWidget {
  const VolunteerProfileScreen({super.key});

  @override
  _VolunteerProfileScreenState createState() => _VolunteerProfileScreenState();
}

class _VolunteerProfileScreenState extends State<VolunteerProfileScreen> {
  List<String> interests = ["Community Service", "Environmental Work", "Education Support"];
  List<String> skills = ["First Aid", "Public Speaking", "Team Leadership"];

  void _editProfile() {
    TextEditingController interestsController = TextEditingController(text: interests.join("\n"));
    TextEditingController skillsController = TextEditingController(text: skills.join("\n"));

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(interestsController, "Interests"),
            _buildTextField(skillsController, "Skills"),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  interests = interestsController.text.split("\n");
                  skills = skillsController.text.split("\n");
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
      appBar: AppBar(title: const Text("Volunteer Profile"), actions: [IconButton(icon: const Icon(Icons.edit), onPressed: _editProfile)]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            _buildProfileSection("Interests", interests),
            _buildProfileSection("Skills", skills),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items.map((item) => Text("• $item")).toList()),
      ),
    );
  }
}
