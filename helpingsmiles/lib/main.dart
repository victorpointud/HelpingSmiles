import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'managers/auth_manager.dart';
import 'screens/volunteer_home_screen.dart';
import 'screens/organization_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _initialScreen = const SplashScreen();

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  void _checkUserSession() async {
    await Future.delayed(const Duration(seconds: 3));

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String? role = await AuthManager.getUserRole(user.uid);

      if (role == "volunteer") {
        setState(() {
          _initialScreen = const VolunteerHomeScreen();
        });
      } else if (role == "organization") {
        setState(() {
          _initialScreen = const OrganizationHomeScreen();
        });
      } else {
        setState(() {
          _initialScreen = const LoginScreen();
        });
      }
    } else {
      setState(() {
        _initialScreen = const LoginScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Helping Smiles',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _initialScreen,
    );
  }
}