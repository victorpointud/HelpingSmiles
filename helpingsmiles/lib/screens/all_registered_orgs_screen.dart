import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllRegisteredOrgsScreen extends StatefulWidget {
  const AllRegisteredOrgsScreen({super.key});

  @override
  _AllRegisteredOrgsScreenState createState() => _AllRegisteredOrgsScreenState();
}

class _AllRegisteredOrgsScreenState extends State<AllRegisteredOrgsScreen> {
  List<Map<String, dynamic>> registeredOrganizations = [];

  @override
  void initState() {
    super.initState();
    _loadRegisteredOrganizations();
  }

  Future<void> _loadRegisteredOrganizations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final orgsSnapshot = await FirebaseFirestore.instance.collection('organizations').get();
      List<Map<String, dynamic>> tempOrganizations = [];

      for (var orgDoc in orgsSnapshot.docs) {
        final regRef = orgDoc.reference.collection('registrations').doc(user.uid);
        final regDoc = await regRef.get();

        if (regDoc.exists) {
          tempOrganizations.add({
            'id': orgDoc.id,
            'name': orgDoc['name'] ?? "Unknown Organization",
            'mission': orgDoc['mission'] ?? "No mission provided",
          });
        }
      }

      setState(() {
        registeredOrganizations = tempOrganizations;
      });
    } catch (e) {
      print("Error loading registered organizations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Registered Organizations")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: registeredOrganizations.length,
        itemBuilder: (context, index) {
          final org = registeredOrganizations[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(org["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(org["mission"]),
            ),
          );
        },
      ),
    );
  }
}