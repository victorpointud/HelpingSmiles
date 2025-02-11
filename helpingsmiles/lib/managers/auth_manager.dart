import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  /// Logs out the current user
  static Future<void> logoutUser() async => await _auth.signOut();

  /// Registers a new user and stores their role + organization name (if applicable)
  static Future<String?> registerUser(String email, String password, String role, {String? organizationName}) async {
  try {
    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = userCredential.user!.uid;

    // Guarda en la colección de usuarios
    await _db.collection('users').doc(uid).set({
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Si es una organización, guarda en la colección de organizaciones
    if (role == "organization" && organizationName != null) {
      await _db.collection('organizations').doc(uid).set({
        'name': organizationName,
        'mission': "",
        'objectives': [],
        'volunteerTypes': [],
        'locations': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return null; // Éxito
  } catch (e) {
    return e is FirebaseAuthException ? e.message : 'Registration error.';
  }
}


  /// Logs in a user and verifies their role
  static Future<String?> loginUser(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final userDoc = await _db.collection('users').doc(userCredential.user!.uid).get();
      return userDoc.exists ? null : 'User not found in Firestore.';
    } catch (e) {
      return e is FirebaseAuthException ? e.message : 'Login error.';
    }
  }

  /// Retrieves the user role from Firestore
  static Future<String?> getUserRole(String uid) async {
    try {
      final userDoc = await _db.collection('users').doc(uid).get();
      return userDoc.exists ? userDoc.get('role') : 'Role not found';
    } catch (e) {
      return 'Error retrieving role.';
    }
  }

  /// Retrieves the organization name from Firestore
  static Future<String?> getOrganizationName(String uid) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('organizations').doc(uid).get();

    if (doc.exists) {
      return doc.data()?['name'] ?? "No Name Available"; // ✅ Verifica que haya datos
    } else {
      return "Organization Not Found"; // ✅ Manejo si no hay organización
    }
  } catch (e) {
    print("Error retrieving organization name: $e");
    return "Error retrieving organization"; // ✅ Evita mostrar null
  }
}

}
