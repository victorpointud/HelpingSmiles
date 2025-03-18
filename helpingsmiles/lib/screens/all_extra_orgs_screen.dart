import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'registered_org_info_screen.dart';

class AllExtraOrgsScreen extends StatefulWidget {
  final String currentOrganizationId; 

  const AllExtraOrgsScreen({super.key, required this.currentOrganizationId});

  @override
  _AllExtraOrgsScreenState createState() => _AllExtraOrgsScreenState();
}

class _AllExtraOrgsScreenState extends State<AllExtraOrgsScreen> {
  List<Map<String, dynamic>> otherOrganizations = [];

  @override
  void initState() {
    super.initState();
    _loadOtherOrganizations();
  }

  Future<void> _loadOtherOrganizations() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('organizations').get();

      setState(() {
        otherOrganizations = querySnapshot.docs
            .where((doc) => doc.id != widget.currentOrganizationId) 
            .map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? "Unknown Organization",
            'mission': data['mission'] ?? "No mission provided",
          };
        }).toList();
      });
    } catch (e) {
      print("Error loading other organizations: $e");
    }
  }

  void _navigateToOrgInfo(String orgId, String orgName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisteredOrgInfoScreen(
          organizationId: orgId,
          organizationName: orgName,
        ),
      ),
    );
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
              child: otherOrganizations.isEmpty
                  ? const Center(
                      child: Text("No other organizations available.", style: TextStyle(color: Colors.white)),
                    )
                  : ListView.builder(
                      itemCount: otherOrganizations.length,
                      itemBuilder: (context, index) {
                        final org = otherOrganizations[index];
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.red, width: 2),
        ),
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
              const Text("Tap to view details.", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}