import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthManager {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Registra un nuevo usuario y lo almacena en Firestore
  static Future<String?> registerUser(String email, String password, String role) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar en Firestore
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role, // Puede ser 'admin' o 'user'
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      return e.message; // Devuelve el error si falla
    }
  }

  /// Inicia sesión con Firebase Authentication
  static Future<String?> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      return e.message; // Devuelve el error si falla
    }
  }

  /// Obtiene el usuario actual
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Obtiene la información del usuario desde Firestore
  static Future<Map<String, dynamic>?> getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
      return doc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  /// Cierra sesión
  static Future<void> logout() async {
    await _auth.signOut();
  }
}
