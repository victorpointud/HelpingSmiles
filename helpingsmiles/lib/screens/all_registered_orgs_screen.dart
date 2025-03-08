import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registered_org_info_screen.dart';

class AllRegisteredOrgsScreen extends StatefulWidget {
  const AllRegisteredOrgsScreen({super.key});

  @override
  _AllRegisteredOrgsScreenState createState() => _AllRegisteredOrgsScreenState();
}

class _AllRegisteredOrgsScreenState extends State<AllRegisteredOrgsScreen> {
  List<Map<String, dynamic>> organizations = [];
  List<Map<String, dynamic>> filteredOrganizations = [];
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
    _loadOrganizations(); 
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
              'date': orgDoc['date'] ?? "No date provided",
              'mission': orgDoc['mission'] ?? "No mission provided",
            });
          }
        }

        if (!mounted) return;
        setState(() {
          registeredOrganizations = tempOrganizations;
        });
      } catch (e) {
        debugPrint("Error loading registered organizations: $e");

      }
  }

  Future<void> _loadOrganizations() async {
  final querySnapshot = await FirebaseFirestore.instance.collection('organizations').get();
  
  setState(() {
    organizations = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? "Unknown Organization",
        'volunteerTypes': (data['volunteerTypes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        'locations': (data['locations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      };
    }).toList();

    filteredOrganizations = List.from(organizations);

    volunteerTypes = organizations
        .expand((org) => (org['volunteerTypes'] as List<String>))
        .toSet()
        .toList();
    volunteerTypes.insert(0, "All");

    locations = organizations
        .expand((org) => (org['locations'] as List<String>))
        .toSet()
        .toList();
    locations.insert(0, "All");
  });
}

  void _applyFilters() {
    setState(() {
      filteredRegisteredOrganizations = registeredOrganizations.where((org) {
        final matchesVolunteerType = selectedVolunteerType == "All" ||
            selectedVolunteerType == null ||
            (org['volunteerTypes'] as List<String>).contains(selectedVolunteerType);
        final matchesLocation = selectedLocation == "All" ||
            selectedLocation == null ||
            (org['locations'] as List<String>).contains(selectedLocation);
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
          "Registered Organizations",
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
          Container(color: Colors.black.withAlpha(77)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    _buildRegisteredOrganizationList(registeredOrganizations),
                    const SizedBox(height: 10),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRegisteredOrgInfo(String orgId, String orgName) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => RegisteredOrgInfoScreen(organizationId: orgId,organizationName: orgName,),),);
  }

  Widget _buildRegisteredOrganizationCard(Map<String, dynamic> org) {
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
                Text("${org["date"]} • ${org["mission"]}", style: const TextStyle(color: Colors.black)),
                const SizedBox(height: 5),
                const Text("Tap to view details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
          ),
        ),
      );
    }

  Widget _buildRegisteredOrganizationList(List<Map<String, dynamic>> registorgs) {
      if (registorgs.isEmpty) {
        return const Center(child: Text("You are not registered in any organization.", style: TextStyle(color: Colors.white)));
      }
      return Column(
        children: registorgs.map((org) => _buildRegisteredOrganizationCard(org)).toList(),
      );
    }
  
}