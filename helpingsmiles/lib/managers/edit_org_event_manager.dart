import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditOrgEventManager extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EditOrgEventManager({super.key, required this.eventId, required this.eventData});

  @override
  _EditOrgEventManagerState createState() => _EditOrgEventManagerState();
}

class _EditOrgEventManagerState extends State<EditOrgEventManager> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _dateController  = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repNameController = TextEditingController();
  final _repLastNameController = TextEditingController();
  final _repPhoneController = TextEditingController();
  final _repEmailController = TextEditingController();

  List<String> selectedVolunteerTypes = [];
  List<String> selectedLocations = [];

  final List<String> availableVolunteerTypes = [
    "Administration", "Education", "Medical Assistance", "Community Service", 
    "Environmental", "Technology", "Sports", "Other"
  ];

  final List<String> availableLocations = [
    "Venezuela", "USA", "Colombia", "Spain", "Mexico", "Argentina",
    "Germany", "France", "Italy", "Canada", "Brasil", "Online"
  ];

  bool? eventStatus;

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  
  Future<void> _loadEventData() async {
  try {
    final doc = await FirebaseFirestore.instance.collection('events').doc(widget.eventId).get();

    if (doc.exists) {
      setState(() {
        _eventNameController.text = doc.data()?['name'] ?? "";
        _dateController.text = doc.data()?['date'] ?? "";
        _durationController.text = doc.data()?['duration'] ?? "";
        _descriptionController.text = doc.data()?['description'] ?? "";
        selectedVolunteerTypes = List<String>.from(doc.data()?['volunteerTypes'] ?? []);
        selectedLocations = List<String>.from(doc.data()?['locations'] ?? []);
        eventStatus = doc.data()?['status'] ?? true;
      });

      _loadRepresentativeData(); 
      debugPrint("Event document does not exist.");
    }
  } catch (e) {
    debugPrint("Error loading event data: $e");
  }
}

  Future<void> _loadRepresentativeData() async {
  try {
    final repDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('representatives')
        .doc('info')
        .get();

    if (repDoc.exists) {
      setState(() {
        _repNameController.text = repDoc.data()?['repName'] ?? "";
        _repLastNameController.text = repDoc.data()?['repLastName'] ?? "";
        _repPhoneController.text = repDoc.data()?['repPhone'] ?? "";
        _repEmailController.text = repDoc.data()?['repEmail'] ?? "";
      });
    } else {
      debugPrint("Representative document does not exist.");
    }
  } catch (e) {
    debugPrint("Error loading representative data: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Edit Event",
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
            
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    color: Colors.white,
                    elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTextField(_eventNameController, "Event Name", Icons.event),
                            _buildTextField(_dateController, "Date (YYYY-MM-DD)", Icons.calendar_today),
                            _buildTextField(_durationController, "Duration (hours)", Icons.timelapse),
                            _buildMultiLineTextField(_descriptionController, "Description", Icons.description),
                            _buildSelectionField("Volunteer Types", selectedVolunteerTypes, availableVolunteerTypes, Icons.people, (newSelection) {
                              setState(() => selectedVolunteerTypes = newSelection);
                            }),
                            _buildSelectionField("Locations", selectedLocations, availableLocations, Icons.location_on, (newSelection) {
                              setState(() => selectedLocations = newSelection);
                            }),
                            _buildStatusField(),
                            const SizedBox(height: 20),
                            const Text("Representative Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                            _buildTextField(_repNameController, "Representative First Name", Icons.person),
                            _buildTextField(_repLastNameController, "Representative Last Name", Icons.person_outline),
                            _buildTextField(_repPhoneController, "Representative Phone", Icons.phone),
                            _buildTextField(_repEmailController, "Representative Email", Icons.email),
                            const SizedBox(height: 20),
                            _buildSaveButton(),
                          ],
                        ),
                      ),
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

  Widget _buildStatusField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: _showStatusDialog,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: "Status",
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            prefixIcon: const Icon(Icons.toggle_on, color: Colors.red),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                eventStatus != null ? (eventStatus! ? "Open" : "Close") : "Tap to select",
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Status", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Open"),
                leading: Radio<bool>(
                  value: true,
                  groupValue: eventStatus,
                  onChanged: (value) {
                    setState(() => eventStatus = value);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text("Close"),
                leading: Radio<bool>(
                  value: false,
                  groupValue: eventStatus,
                  onChanged: (value) {
                    setState(() => eventStatus = value);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveEventChanges() async {
  if (_formKey.currentState!.validate()) {
    try {

      await FirebaseFirestore.instance.collection('events').doc(widget.eventId).set({
        'name': _eventNameController.text.trim(),
        'date': _dateController.text.trim(),
        'duration': _durationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'volunteerTypes': selectedVolunteerTypes.isNotEmpty ? selectedVolunteerTypes : [],
        'locations': selectedLocations.isNotEmpty ? selectedLocations : [],
        'status': eventStatus ?? true,
      }, SetOptions(merge: true));

      debugPrint("Event updated successfully!");

      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('representatives')
          .doc('info')
          .set({
        'repName': _repNameController.text.trim(),
        'repLastName': _repLastNameController.text.trim(),
        'repPhone': _repPhoneController.text.trim(),
        'repEmail': _repEmailController.text.trim(),
      }, SetOptions(merge: true));

      debugPrint("Representative updated successfully!");

      _showSuccessDialog();

    } catch (e) {
      debugPrint("Error updating event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating event: ${e.toString()}")),
      );
    }
  }
}

  void _showMultiSelectDialog(List<String> options, List<String> selectedList, String title, Function(List<String>) onSelected) {
    showDialog(
      context: context,
      builder: (context) {
        List<String> tempSelected = List.from(selectedList);
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: options.map((option) {
                    return ListTile(
                      title: Text(option, style: const TextStyle(color: Colors.black)),
                      leading: Icon(
                        tempSelected.contains(option) ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: tempSelected.contains(option) ? Colors.red : Colors.grey,
                      ),
                      onTap: () {
                        setState(() {
                          if (tempSelected.contains(option)) {
                            tempSelected.remove(option);
                          } else {
                            tempSelected.add(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                onSelected(tempSelected);
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectionField(String label, List<String> selectedList, List<String> options, IconData icon, Function(List<String>) onSelected) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: InkWell(
      onTap: () => _showMultiSelectDialog(options, selectedList, "Select $label", onSelected),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          prefixIcon: Icon(icon, color: Colors.red),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedList.isNotEmpty ? selectedList.join(", ") : "Tap to select",
                style: const TextStyle(color: Colors.black, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.red),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildMultiLineTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          prefixIcon: Icon(icon, color: Colors.red),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveEventChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("Save Changes", style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  void _showSuccessDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black)),
          content: const Text("Your profile has been updated successfully.", style: TextStyle(fontSize: 15, color: Colors.black)),
          actions: [
            Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            ),
          ],
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context); 
        Navigator.pop(context, true); 
      });
    }

}