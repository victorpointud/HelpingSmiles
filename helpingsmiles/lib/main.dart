import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';
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
  late Widget _initialScreen;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  void _checkUserSession() async {
    // Verifica si hay un usuario autenticado
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Si el usuario está autenticado, ve a HomeScreen
      _initialScreen = HomeScreen(title: 'Welcome Back!');
    } else {
      // Si no hay usuario, ve a LoginScreen
      _initialScreen = const LoginScreen();
    }
    setState(() {}); // Redibuja la UI con la pantalla correcta
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Helping Smiles',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _initialScreen ?? const SplashScreen(), // Muestra SplashScreen mientras carga
    );
  }
}
