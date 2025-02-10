import 'package:flutter/material.dart';

class OrganizationProfileScreen extends StatelessWidget {
  const OrganizationProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organization Profile'), backgroundColor: Colors.red),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Mission:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Our mission is to support underprivileged communities through volunteer efforts."),
            const SizedBox(height: 10),

            const Text("Objectives:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("• Provide educational support\n• Promote environmental sustainability\n• Organize charity events"),
          ],
        ),
      ),
    );
  }
}
