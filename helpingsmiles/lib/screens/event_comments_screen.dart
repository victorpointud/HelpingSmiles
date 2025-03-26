import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventCommentsScreen extends StatefulWidget {
  final String eventId;

  const EventCommentsScreen({super.key, required this.eventId});

  @override
  EventCommentsScreenState createState() => EventCommentsScreenState();
}

class EventCommentsScreenState extends State<EventCommentsScreen> {
  List<Map<String, dynamic>> feedbackList = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    debugPrint("Fetching comments for eventId: ${widget.eventId}");

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('activity_feedback')
          .where('eventId', isEqualTo: widget.eventId)
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> tempFeedbackList = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] ?? 'Unknown User';
        final feedback = data['feedback'] ?? '';
        final timestamp = data['timestamp'];

        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        final userName = userDoc.exists && userDoc.data() != null
            ? userDoc.data()!['name'] ?? 'Unknown User'
            : 'Unknown User';

        tempFeedbackList.add({
          'feedback': feedback,
          'userName': userName,
          'timestamp': timestamp,
        });
      }

      setState(() {
        feedbackList = tempFeedbackList;
      });
    } catch (e) {
      debugPrint("Error loading comments: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Event Feedback",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recent Comments:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  feedbackList.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Text(
                              "There are no comments yet.",
                              style: TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.6)),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: feedbackList.length,
                            itemBuilder: (context, index) {
                              final comment = feedbackList[index];
                              return Card(
                                elevation: 6,
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.red, width: 3),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.account_circle, color: Colors.red, size: 30),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              comment['userName'],
                                              style: const TextStyle(
                                                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        comment['feedback'],
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Date: ${comment['timestamp'] != null ? comment['timestamp'].toDate().toString() : 'No Date'}",
                                        style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.7)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
