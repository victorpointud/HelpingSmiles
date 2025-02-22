import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helpingsmiles/screens/registered_org_info_screen.dart';


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

  void _navigateToRegisteredOrgInfo(String orgId, String orgName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisteredOrgInfoScreen(organizationId: orgId, organizationName: orgName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "My Registered Organizations",
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
              padding: const EdgeInsets.all(16),
              child: registeredOrganizations.isEmpty
                  ? const Center(child: Text("You are not registered in any organization.", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: registeredOrganizations.length,
                      itemBuilder: (context, index) {
                        final org = registeredOrganizations[index];
                        return GestureDetector(
                          onTap: () => _navigateToRegisteredOrgInfo(org["id"], org["name"]),
                          child: Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}