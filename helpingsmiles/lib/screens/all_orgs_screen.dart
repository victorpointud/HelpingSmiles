import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllOrgsScreen extends StatefulWidget {
  const AllOrgsScreen({super.key});

  @override
  _AllOrgsScreenState createState() => _AllOrgsScreenState();
}

class _AllOrgsScreenState extends State<AllOrgsScreen> {
  List<Map<String, dynamic>> organizations = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('organizations').get();
    setState(() {
      organizations = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? "Unknown Organization",
          'mission': data['mission'] ?? "No mission provided",
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Organizations")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: organizations.length,
        itemBuilder: (context, index) {
          final org = organizations[index];
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