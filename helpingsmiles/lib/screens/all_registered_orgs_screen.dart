import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'registered_org_info_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllRegisteredOrgsScreen extends StatefulWidget {
  const AllRegisteredOrgsScreen({super.key});

  @override
  _AllRegisteredOrgsScreenState createState() => _AllRegisteredOrgsScreenState();
}

class _AllRegisteredOrgsScreenState extends State<AllRegisteredOrgsScreen> {
  List<Map<String, dynamic>> registeredOrganizations = [];
  List<Map<String, dynamic>> filteredRegisteredOrganizations = [];
  String? selectedVolunteerType;
  String? selectedLocation;
  List<String> volunteerTypes = [];
  List<String> locations = [];
  

  @override
  void initState() {
    super.initState();
    _loadRegisteredOrganizations();
  }

 Future<void> _loadRegisteredOrganizations() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    List<Map<String, dynamic>> tempOrganizations = [];
    final orgsSnapshot = await FirebaseFirestore.instance.collection('organizations').get();

    for (var orgDoc in orgsSnapshot.docs) {
      final orgId = orgDoc.id;
      final registrationRef = orgDoc.reference.collection('registrations').doc(user.uid);
      final registrationDoc = await registrationRef.get();

      if (registrationDoc.exists) {
        tempOrganizations.add({
          'id': orgId,
          'name': orgDoc['name'] ?? "Unknown Organization",
          'volunteerTypes': (orgDoc['volunteerTypes'] != null && orgDoc['volunteerTypes'] is List)
              ? (orgDoc['volunteerTypes'] as List).map((e) => e.toString()).toList()
              : [],
          'locations': (orgDoc['locations'] != null && orgDoc['locations'] is List)
              ? (orgDoc['locations'] as List).map((e) => e.toString()).toList()
              : [],
        });
      }
    }

    if (!mounted) return;

    setState(() {
      registeredOrganizations = tempOrganizations;
      filteredRegisteredOrganizations = List.from(registeredOrganizations);

      // 🔹 Carga opciones únicas para dropdowns
      volunteerTypes = registeredOrganizations
          .expand((org) => (org['volunteerTypes'] as List<String>))
          .toSet()
          .toList();
      volunteerTypes.insert(0, "All");

      locations = registeredOrganizations
          .expand((org) => (org['locations'] as List<String>))
          .toSet()
          .toList();
      locations.insert(0, "All");
    });

  } catch (e) {
    print("Error loading registered organizations: $e");
  }
}


  void _applyFilters() {
    setState(() {
      filteredRegisteredOrganizations = registeredOrganizations.where((org) {
        final matchesVolunteerType = selectedVolunteerType == "All" ||
            selectedVolunteerType == null ||
            org['volunteerTypes'].contains(selectedVolunteerType);

        final matchesLocation = selectedLocation == "All" ||
            selectedLocation == null ||
            org['locations'].contains(selectedLocation);

        return matchesVolunteerType && matchesLocation;
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
              const Text("Filter Organizations", style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDropdown("Volunteer Type", selectedVolunteerType, volunteerTypes, (value) {
                  setState(() => selectedVolunteerType = value);
                }),
                const SizedBox(height: 10),
                _buildDropdown("Location", selectedLocation, locations, (value) {
                  setState(() => selectedLocation = value);
                }),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedVolunteerType = null;
                  selectedLocation = null;
                  filteredRegisteredOrganizations = List.from(registeredOrganizations);
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
              child: filteredRegisteredOrganizations.isEmpty
                  ? const Center(child: Text("No organizations found.", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: filteredRegisteredOrganizations.length,
                      itemBuilder: (context, index) {
                        final org = filteredRegisteredOrganizations[index];
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
      onTap: () => _navigateToRegisteredOrgInfo(org["id"], org["name"]),
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
              Text(
                "Volunteer Types: ${org["volunteerTypes"].join(", ")}",
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                "Locations: ${org["locations"].join(", ")}",
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 5),
              const Text("Tap to view details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRegisteredOrgInfo(String orgId, String orgName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisteredOrgInfoScreen(organizationId: orgId, organizationName: orgName),
      ),
    );
  }
}