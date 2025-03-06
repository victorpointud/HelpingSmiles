import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FeedbackScreen extends StatefulWidget {
  final String activityId;
  final String volunteerId;

  const FeedbackScreen({super.key, required this.activityId, required this.volunteerId});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 3.0; // Valor inicial

  void _submitFeedback() async {
    if (_commentController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('activity_feedback').add({
      'activityId': widget.activityId,
      'volunteerId': widget.volunteerId,
      'comment': _commentController.text,
      'rating': _rating,
      'timestamp': Timestamp.now(),
    });

    Navigator.pop(context); // Cierra la pantalla después de enviar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deja tu comentario")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("¿Cómo fue tu experiencia?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // Campo de texto para el comentario
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Escribe tu opinión aquí...",
              ),
            ),

            const SizedBox(height: 20),

            // Selector de estrellas
            const Text("Calificación:", style: TextStyle(fontSize: 16)),
            Slider(
              value: _rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: _rating.toString(),
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // Botón de enviar
            Center(
              child: ElevatedButton(
                onPressed: _submitFeedback,
                child: const Text("Enviar comentario"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
