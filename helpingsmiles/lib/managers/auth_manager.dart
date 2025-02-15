import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  /// Logs out the current user
  static Future<void> logoutUser() async => await _auth.signOut();

  /// Registers a new user and stores their role + organization name (if applicable)
  static Future<String?> registerUser({
    required String email,
    required String password,
    required String role,
    required String phoneNumber, // New field
    String? name,
    String? lastName,
    String? dateOfBirth, // Only for volunteers
    String? organizationName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      await _db.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'phone': phoneNumber,
        'name': role == 'volunteer' ? "$name $lastName" : organizationName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    

      return null; // Successful registration
    } catch (e) {
      return e is FirebaseAuthException ? e.message : 'Registration error.';
    }
  }

static Future<String?> getUserName(String uid) async {
    try {
      final userDoc = await _db.collection('users').doc(uid).get();
      return userDoc.exists ? userDoc.get('name') : "Volunteer";
    } catch (e) {
      return "Volunteer"; // Default name in case of error
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
