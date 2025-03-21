import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../managers/edit_org_profile_manager.dart';
import '../../screens/org_metrics_screen.dart'; 


class OrgProfileScreen extends StatefulWidget {
  final String organizationId;
  final String organizationName;

  const OrgProfileScreen({
    super.key,
    required this.organizationId,
    required this.organizationName,
  });

  @override
  OrgProfileScreenState createState() => OrgProfileScreenState();
}

class OrgProfileScreenState extends State<OrgProfileScreen> {
  Map<String, dynamic>? orgData;
  Map<String, dynamic>? representativeData;
  bool isLoading = true;
  bool isRepLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrganizationData();
    _loadRepresentativeData();
  }

  Future<void> _loadOrganizationData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('organizations').doc(widget.organizationId).get();
      if (doc.exists) {
        setState(() {
          orgData = doc.data();
        });
      } else {
        setState(() {
          orgData = null;
        });
      }
    } catch (e) {
      debugPrint("Error loading organization data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadRepresentativeData() async {
    try {
      final repDoc = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(widget.organizationId)
          .collection('representatives')
          .doc('info')
          .get();

      if (repDoc.exists && repDoc.data() != null) {
        setState(() {
          representativeData = repDoc.data();
        });
      } else {
        debugPrint("No representative data found.");
      }
    } catch (e) {
      debugPrint("Error loading representative data: $e");
    } finally {
      setState(() => isRepLoading = false);
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditOrgProfileManager(organizationId: widget.organizationId)), 
    ).then((result) {
      if (result == true) _loadOrganizationData();
    });
  }

void _navigateToMetrics() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => OrgMetricsScreen(organizacionId: widget.organizationId)),
  );
}

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        content: const Text("Are you sure you want to delete your account? This action cannot be undone.",
            style: TextStyle(fontSize: 16, color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      await FirebaseFirestore.instance.collection('organizations').doc(widget.organizationId).delete();
      await FirebaseAuth.instance.currentUser?.delete();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting account: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.organizationName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: _navigateToEditProfile,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDeleteAccount,
          ),
        ],
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.red))
                : orgData == null
                    ? const Center(child: Text("Organization not found.", style: TextStyle(color: Colors.white)))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Card(
                            color: Colors.white,
                            elevation: 10,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow(Icons.phone, "Phone", orgData!["phone"] ?? "Not specified"),
                                  _buildDetailRow(Icons.calendar_today, "Date Created", orgData!["date"] ?? "Not specified"),
                                  _buildDetailRow(Icons.flag, "Mission", orgData!["mission"] ?? "Not specified"),
                                  _buildDetailList(Icons.list, "Objectives", orgData!["objectives"] ?? []),
                                  _buildDetailList(Icons.people, "Volunteer Types", orgData!["volunteerTypes"] ?? []),
                                  _buildDetailList(Icons.location_on, "Locations", orgData!["locations"] ?? []),
                                  const SizedBox(height: 20),
                                  _buildRepresentativeSection(),
                                  const SizedBox(height: 20),
                                  Center(
                                  child: ElevatedButton(
                                    onPressed: _navigateToMetrics,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: const BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 2),
                                      ),
                                    ),
                                    child: const Text("View Metrics", style: TextStyle(color: Colors.white, fontSize: 16)),
                                  ),
                                ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: value,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailList(IconData icon, String title, List<dynamic> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 32, top: 5),
              child: Text("Not specified", style: TextStyle(fontSize: 16, color: Colors.black)),
            )
          else
            Column(
              children: items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 32, top: 5),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color.fromARGB(255, 0, 0, 0), size: 16),
                    const SizedBox(width: 5),
                    Expanded(child: Text(item, style: const TextStyle(fontSize: 16, color: Colors.black))),
                  ],
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRepresentativeSection() {
    if (isRepLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (representativeData == null) {
      return Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.red, width: 2),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "No representative assigned for this organization.",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      );
    }

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.red, width: 2),
      ),  
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Representative",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.person, "Name", "${representativeData!['repName']} ${representativeData!['repLastName']}"),
            _buildDetailRow(Icons.email, "Email", representativeData!['repEmail']),
            _buildDetailRow(Icons.phone, "Phone", representativeData!['repPhone']),
          ],
        ),
      ),
    );
  }
}