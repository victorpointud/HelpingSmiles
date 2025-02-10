import 'package:flutter/material.dart';

class VolunteerProfileScreen extends StatefulWidget {
  const VolunteerProfileScreen({super.key});

  @override
  _VolunteerProfileScreenState createState() => _VolunteerProfileScreenState();
}

class _VolunteerProfileScreenState extends State<VolunteerProfileScreen> {
  List<String> interests = ["Community Service", "Environmental Work", "Education Support"];
  List<String> skills = ["First Aid", "Public Speaking", "Team Leadership"];
  List<String> activities = ["Beach Cleanup", "Charity Marathon", "Teaching Kids"];
  List<String> certifications = ["CPR Training", "Volunteer Leadership Certificate"];

  void _editProfile() {
    TextEditingController interestsController = TextEditingController(text: interests.join("\n"));
    TextEditingController skillsController = TextEditingController(text: skills.join("\n"));
    TextEditingController activitiesController = TextEditingController(text: activities.join("\n"));
    TextEditingController certificationsController = TextEditingController(text: certifications.join("\n"));

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
                const Text("Edit Volunteer Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                TextField(controller: interestsController, decoration: const InputDecoration(labelText: "Interests"), maxLines: 3),
                TextField(controller: skillsController, decoration: const InputDecoration(labelText: "Skills"), maxLines: 3),
                TextField(controller: activitiesController, decoration: const InputDecoration(labelText: "Completed Activities"), maxLines: 3),
                TextField(controller: certificationsController, decoration: const InputDecoration(labelText: "Certifications"), maxLines: 3),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      interests = interestsController.text.split("\n");
                      skills = skillsController.text.split("\n");
                      activities = activitiesController.text.split("\n");
                      certifications = certificationsController.text.split("\n");
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
        title: const Text("Volunteer Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
            CircleAvatar(radius: 50, backgroundColor: Colors.red.shade200, child: const Icon(Icons.person, size: 50, color: Colors.white)),
            const SizedBox(height: 20),
            _buildProfileSection(Icons.favorite, "Interests", interests),
            _buildProfileSection(Icons.lightbulb, "Skills", skills),
            _buildProfileSection(Icons.check_circle, "Completed Activities", activities),
            _buildProfileSection(Icons.badge, "Certifications", certifications),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(IconData icon, String title, List<String> items) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: Colors.red), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
            ...items.map((item) => Text("• $item")),
          ],
        ),
      ),
    );
  }
}
