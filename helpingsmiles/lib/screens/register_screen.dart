import 'package:flutter/material.dart';
import '../managers/auth_manager.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController(); 

  String? _errorMessage;
  String _selectedRole = 'volunteer';

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        setState(() => _errorMessage = 'Passwords do not match.');
      }
      return;
    }

    final error = await AuthManager.registerUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
      phone: _phoneController.text.trim(),
      date: _dateController.text.trim(), 
      name: _selectedRole == 'volunteer' ? _nameController.text.trim() : null,
      lastName: _selectedRole == 'volunteer' ? _lastNameController.text.trim() : null,
      organizationName: _selectedRole == 'organization' ? _organizationController.text.trim() : null,
    );

    if (error == null) {
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        setState(() => _errorMessage = error);
      }
    }
  }

  void _navigateToLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('lib/assets/background.png'), fit: BoxFit.cover),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          Center(
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
                        const Text('Register', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 10),
                        _buildTextField(_emailController, 'Email', Icons.email),
                        _buildTextField(_passwordController, 'Password', Icons.lock, isPassword: true),
                        _buildTextField(_confirmPasswordController, 'Confirm Password', Icons.lock_outline, isPassword: true),
                        _buildRoleDropdown(),
                        
                        if (_selectedRole == 'volunteer') ...[
                          _buildTextField(_dateController, 'Date of Birth (YYYY-MM-DD)', Icons.calendar_today), 
                          _buildTextField(_nameController, 'First Name', Icons.person),
                          _buildTextField(_lastNameController, 'Last Name', Icons.person_outline),
                          _buildTextField(_phoneController, 'Phone Number', Icons.phone), 
                        ],

                        if (_selectedRole == 'organization') ...[
                          _buildTextField(_dateController, 'Date of Creation (YYYY-MM-DD)', Icons.calendar_today), 
                          _buildTextField(_organizationController, 'Organization Name', Icons.business),
                          _buildTextField(_phoneController, 'Phone Number', Icons.phone), 
                        ],

                        if (_errorMessage != null) 
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                          ),
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
                          child: const Text("Already have an account? Login", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          prefixIcon: Icon(icon, color: Colors.red),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        items: const [
          DropdownMenuItem(value: 'volunteer', child: Text('Volunteer')),
          DropdownMenuItem(value: 'organization', child: Text('Organization')),
        ],
        onChanged: (value) => setState(() => _selectedRole = value!),
        decoration: InputDecoration(
          labelText: 'Select Role',
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}