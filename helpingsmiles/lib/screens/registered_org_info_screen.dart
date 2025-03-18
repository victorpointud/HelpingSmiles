import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisteredOrgInfoScreen extends StatefulWidget {
  final String organizationId;
  final String organizationName;

  const RegisteredOrgInfoScreen({
    super.key,
    required this.organizationId,
    required this.organizationName,
  });

  @override
  _RegisteredOrgInfoScreenState createState() => _RegisteredOrgInfoScreenState();
}

class _RegisteredOrgInfoScreenState extends State<RegisteredOrgInfoScreen> {
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
                                _buildDetailRow(Icons.phone, "Phone", orgData!["phone"] ?? "Not specified"),
                                _buildDetailRow(Icons.calendar_today, "Date Created", orgData!["date"] ?? "Not specified"),
                                _buildDetailRow(Icons.flag, "Mission", orgData!["mission"] ?? "Not specified"),
                                _buildDetailList(Icons.list, "Objectives", orgData!["objectives"] ?? []),
                                const SizedBox(height: 20),
                                _buildRepresentativeSection(),
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