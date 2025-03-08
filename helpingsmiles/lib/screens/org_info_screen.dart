import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'org_events_list_screen.dart';

class OrgInfoScreen extends StatefulWidget {
  final String organizationId;
  final String organizationName;

  const OrgInfoScreen({
    super.key,
    required this.organizationId,
    required this.organizationName,
  });

  @override
  _OrgInfoScreenState createState() => _OrgInfoScreenState();
}

class _OrgInfoScreenState extends State<OrgInfoScreen> {
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
          isLoading = false;
        });
      } else {
        setState(() {
          orgData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading organization data: $e");
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
        print("No representative data found.");
      }
    } catch (e) {
      print("Error loading representative data: $e");
    } finally {
      setState(() => isRepLoading = false);
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
                        child: Card(
                          color: Colors.white,
                          elevation: 10,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  orgData!["name"] ?? "Unnamed Organization",
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                                ),
                                const SizedBox(height: 15),
                                _buildDetailRow(Icons.phone, "Phone", orgData!["phone"] ?? "Not specified"),
                                _buildDetailRow(Icons.calendar_today, "Date Created", orgData!["date"] ?? "Not specified"),
                                _buildDetailRow(Icons.flag, "Mission", orgData!["mission"] ?? "Not specified"),
                                _buildDetailList(Icons.list, "Objectives", orgData!["objectives"] ?? []),
                                const SizedBox(height: 20),
                                _buildRepresentativeSection(),
                                const SizedBox(height: 20),
                                Center(
                                  child: Column(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _navigateToEventsList,
                                        icon: const Icon(Icons.event),
                                        label: const Text("View Upcoming Events"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton.icon(
                                        onPressed: _registerForOrganization,
                                        icon: const Icon(Icons.how_to_reg),
                                        label: const Text("Register for this Organization"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

  Widget _buildDetailList(IconData icon, String title, List<dynamic> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red),
              const SizedBox(width: 10),
              Text(
                "$title:",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ...values.map((value) => Padding(
                padding: const EdgeInsets.only(left: 30, top: 5),
                child: Text("• $value", style: const TextStyle(fontSize: 16, color: Colors.black)),
              )),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  void _navigateToEventsList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrgEventsListScreen(organizationId: widget.organizationId),
      ),
    );
  }

  Future<void> _registerForOrganization() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final volunteerDoc = await FirebaseFirestore.instance.collection('volunteers').doc(user.uid).get();

        if (!volunteerDoc.exists) {
          _showErrorDialog("Volunteer profile not found!");
          return;
        }

        final volunteerData = volunteerDoc.data() ?? {};
        final name = volunteerData['name'] ?? "Not specified";
        final email = user.email ?? "Not specified";
        final phone = volunteerData['phone'] ?? "Not specified";
        final skills = (volunteerData['skills'] as List<dynamic>?)?.cast<String>() ?? [];
        final interests = (volunteerData['interests'] as List<dynamic>?)?.cast<String>() ?? [];
        final location = volunteerData['location'] ?? "Not specified";
        final date = volunteerData['date'] ?? "Not specified";

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

        _showSuccessDialog();

      } catch (e) {
        print("Error registering for organization: $e");
        _showErrorDialog("Failed to register for the organization.");
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registration Successful!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        content: const Text("You have successfully registered for this organization.", style: TextStyle(fontSize: 16, color: Colors.black)),
        actions: [
          Center(child: CircularProgressIndicator(color: Colors.red)), 
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text(message, style: const TextStyle(fontSize: 16, color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

}






