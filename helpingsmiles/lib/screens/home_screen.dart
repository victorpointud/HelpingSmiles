import 'package:flutter/material.dart';

/// Pantalla principal después de iniciar sesión correctamente.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Text('Welcome to Helping Smiles'),
      ),
    );
  }
}
