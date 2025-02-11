import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../managers/auth_manager.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await AuthManager.loginUser(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (error == null) {
      final user = FirebaseAuth.instance.currentUser;
      final role = await AuthManager.getUserRole(user!.uid);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(title: 'Welcome, $role!')),
      );
    } else {
      setState(() => _errorMessage = error);
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/background.png'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.6), // Dark Overlay
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        _buildTextField(_emailController, 'Email', Icons.email),
                        _buildTextField(_passwordController, 'Password', Icons.lock, isPassword: true),
                        if (_errorMessage != null) 
                          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _navigateToRegister,
                          child: const Text("Don't have an account? Register"),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}
