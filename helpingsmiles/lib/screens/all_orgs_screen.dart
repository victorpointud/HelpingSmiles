import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'org_info_screen.dart'; 

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "All Organizations",
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
              child: organizations.isEmpty
                  ? const Center(child: Text("No organizations available.", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: organizations.length,
                      itemBuilder: (context, index) {
                        final org = organizations[index];
                        return _buildOrganizationCard(org);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationCard(Map<String, dynamic> org) {
    return GestureDetector(
      onTap: () => _navigateToOrgInfo(org["id"], org["name"]),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(org["name"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 5),
              Text(org["mission"], style: const TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 5),
              const Text("Click to see more info", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToOrgInfo(String orgId, String orgName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrgInfoScreen(organizationId: orgId, organizationName: orgName),
      ),
    );
  }
}