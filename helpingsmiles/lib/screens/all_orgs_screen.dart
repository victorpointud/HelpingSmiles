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
  List<Map<String, dynamic>> filteredOrganizations = [];
  String? selectedMission;
  String? selectedDate;
  List<String> missions = [];
  List<String> dates = [];
  

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
          'date': data['date'] ?? "No date provided",
        };
      }).toList();

      filteredOrganizations = List.from(organizations);

      missions = organizations.map((org) => org['mission'].toString()).toSet().toList();
      missions.insert(0, "All");

      dates = organizations.map((org) => org['date'].toString()).toSet().toList();
      dates.insert(0, "All");
    });
  }

  void _applyFilters() {
    setState(() {
      filteredOrganizations = organizations.where((org) {
        final matchesMission = selectedMission == "All" || selectedMission == null || org['mission'] == selectedMission;
        final matchesDate = selectedDate == "All" || selectedDate == null || org['date'] == selectedDate;
        return matchesMission && matchesDate;
      }).toList();
    });
  }

  void _showFilterPopUp() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.all(10),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filter Organizations",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdown("Mission", selectedMission, missions, (value) {
                setState(() => selectedMission = value);
              }),
              const SizedBox(height: 10),
              _buildDropdown("Date Created", selectedDate, dates, (value) {
                setState(() => selectedDate = value);
              }),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedMission = null;
                  selectedDate = null;
                  filteredOrganizations = List.from(organizations);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Clear Filters", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                _applyFilters();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Apply Filters", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown(String label, String? selectedValue, List<String> options, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (value) => onChanged(value),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: _showFilterPopUp,
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: filteredOrganizations.isEmpty
                  ? const Center(child: Text("No organizations found.", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: filteredOrganizations.length,
                      itemBuilder: (context, index) {
                        final org = filteredOrganizations[index];
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
              Text(org["name"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 5),
              Text("${org["date"]} • ${org["mission"]} ", style: const TextStyle(color: Colors.black, fontSize: 16)),
              const SizedBox(height: 5),
              const Text("Tap to view details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
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