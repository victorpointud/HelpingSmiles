import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteersScreen extends StatefulWidget {
  final String eventId;

  const VolunteersScreen({super.key, required this.eventId});

  @override
  _VolunteersScreenState createState() => _VolunteersScreenState();
}

class _VolunteersScreenState extends State<VolunteersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Volunteers",
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .doc(widget.eventId)
                    .collection('registrations')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No volunteers found for this event.",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  // Filtrar voluntarios que tengan al menos un campo válido
                  final volunteers = snapshot.data!.docs.where((doc) {
                    final volunteer = doc.data() as Map<String, dynamic>;
                    return volunteer["name"] != null && volunteer["name"] != "No Name" ||
                           volunteer["email"] != null && volunteer["email"] != "No Email" ||
                           volunteer["phone"] != null && volunteer["phone"] != "No Phone" ||
                           volunteer["role"] != null && volunteer["role"] != "No Role";
                  }).toList();

                  if (volunteers.isEmpty) {
                    return const Center(
                      child: Text(
                        "No valid volunteers found for this event.",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: volunteers.length,
                    itemBuilder: (context, index) {
                      final volunteer = volunteers[index].data() as Map<String, dynamic>;
                      final registrationId = volunteers[index].id;
                      return _buildVolunteerCard(volunteer, registrationId);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerCard(Map<String, dynamic> volunteer, String registrationId) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(volunteer["name"] ?? "No Name", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 5),
            _buildDetailRow(Icons.email, "Email", volunteer["email"] ?? "No Email"),
            _buildDetailRow(Icons.phone, "Phone", volunteer["phone"] ?? "No Phone"),
            _buildDetailRow(Icons.people, "Role", volunteer["role"] ?? "No Role"),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () => _rejectVolunteer(registrationId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Reject Volunteer", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _rejectVolunteer(String registrationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('registrations')
          .doc(registrationId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Volunteer Rejected Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error Rejecting Volunteer: $e")),
      );
    }
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}