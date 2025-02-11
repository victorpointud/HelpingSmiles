import 'package:flutter/material.dart';
import '../managers/auth_manager.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _organizationNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  String _selectedRole = 'volunteer';

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    final error = await AuthManager.registerUser(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _selectedRole,
      organizationName: _selectedRole == 'organization' ? _organizationNameController.text.trim() : null,
    );

    if (error == null) {
      Navigator.pop(context);
    } else {
      setState(() => _errorMessage = error);
    }
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          'Register',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(_emailController, 'Email', Icons.email),
                        _buildTextField(_passwordController, 'Password', Icons.lock, isPassword: true),
                        _buildTextField(_confirmPasswordController, 'Confirm Password', Icons.lock_outline, isPassword: true),
                        _buildRoleDropdown(),
                        if (_selectedRole == 'organization')
                          _buildTextField(_organizationNameController, "Organization Name", Icons.business),
                        const SizedBox(height: 10),
                        if (_errorMessage != null) 
                          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _navigateToLogin,
                          child: const Text("Already have an account? Login"),
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

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      items: const [
        DropdownMenuItem(value: 'volunteer', child: Text('Volunteer')),
        DropdownMenuItem(value: 'organization', child: Text('Organization')),
      ],
      onChanged: (value) => setState(() => _selectedRole = value!),
      decoration: const InputDecoration(labelText: 'Select Role'),
    );
  }
}
