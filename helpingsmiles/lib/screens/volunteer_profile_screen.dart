import 'package:flutter/material.dart';

class VolunteerProfileScreen extends StatelessWidget {
  const VolunteerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer Profile"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Interests:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("• Community Service\n• Environmental Work"),
            const SizedBox(height: 10),

            const Text("Skills:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("• First Aid\n• Public Speaking"),
            const SizedBox(height: 10),

            const Text("Activities Completed:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("• Beach Cleanup\n• Charity Marathon"),
            const SizedBox(height: 10),

            const Text("Certifications:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("• CPR Training\n• Volunteer Leadership Certificate"),
          ],
        ),
      ),
    );
  }
}
