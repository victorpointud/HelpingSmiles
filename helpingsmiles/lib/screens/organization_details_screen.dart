import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/event_list_screen.dart';

class OrganizationDetailsScreen extends StatefulWidget {
  final String organizationId;
  final String organizationName;

  const OrganizationDetailsScreen({
    super.key,
    required this.organizationId,
    required this.organizationName,
  });

  @override
  _OrganizationDetailsScreenState createState() => _OrganizationDetailsScreenState();
}

class _OrganizationDetailsScreenState extends State<OrganizationDetailsScreen> {
  String? phone;
  String? date;
  List<String> missions = [];
  List<String> objectives = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizationData();
  }

  Future<void> _loadOrganizationData() async {
    final doc = await FirebaseFirestore.instance.collection('organizations').doc(widget.organizationId).get();
    if (doc.exists) {
      setState(() {
        phone = doc.data()?['phone'] ?? "Not specified";
        date = doc.data()?['date'] ?? "Not specified";
        missions = (doc.data()?['missions'] as List<dynamic>?)?.cast<String>() ?? [];
        objectives = (doc.data()?['objectives'] as List<dynamic>?)?.cast<String>() ?? [];
      });
    }
  }

  /// 🔹 **Función para inscribirse a la organización**
  Future<void> _registerForOrganization() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Obtener información del voluntario desde Firestore
        final volunteerDoc = await FirebaseFirestore.instance
            .collection('volunteers')
            .doc(user.uid)
            .get();

        if (!volunteerDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Volunteer profile not found!")),
          );
          return;
        }

        // Datos del voluntario
        final volunteerData = volunteerDoc.data() ?? {};
        final name = volunteerData['name'] ?? "Not specified";
        final email = user.email ?? "Not specified";
        final phone = volunteerData['phone'] ?? "Not specified";
        final skills = (volunteerData['skills'] as List<dynamic>?)?.cast<String>() ?? [];
        final interests = (volunteerData['interests'] as List<dynamic>?)?.cast<String>() ?? [];
        final location = volunteerData['location'] ?? "Not specified";
        final date = volunteerData['date'] ?? "Not specified";

        // Guardar el registro en la subcolección 'registrations' dentro de la organización
        await FirebaseFirestore.instance
            .collection('organizations')
            .doc(widget.organizationId)
            .collection('registrations')
            .doc(user.uid)
            .set({
          'userId': user.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'skills': skills,
          'interests': interests,
          'location': location,
          'date': date,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully registered for the organization!")),
        );
      } catch (e) {
        print("Error registering for organization: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to register for organization.")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.organizationName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(Icons.phone, "Phone", phone ?? "Not specified"),
            _buildProfileSection(Icons.calendar_today, "Date Created", date ?? "Not specified"),
            _buildProfileList(Icons.flag, "Mission", missions),
            _buildProfileList(Icons.list, "Objectives", objectives),

            // 📌 Botón para ver los eventos
            const SizedBox(height: 20),
            Center( // 📌 Centrar los botones
              child: ElevatedButton.icon(
                onPressed: _navigateToEventList,
                icon: const Icon(Icons.event),
                label: const Text("View Upcoming Events"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Center( // 📌 Centrar los botones
              child: ElevatedButton.icon(
                onPressed: _registerForOrganization,
                icon: const Icon(Icons.how_to_reg),
                label: const Text("Suscribe to this Organization"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
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
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content),
      ),
    );
  }

  Widget _buildProfileList(IconData icon, String title, List<String> items) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
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

  void _navigateToEventList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventListScreen(organizationId: widget.organizationId),
      ),
    );
  }
}