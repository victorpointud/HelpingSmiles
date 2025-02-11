import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  /// Logs out the current user
  static Future<void> logoutUser() async => await _auth.signOut();

  /// Registers a new user and stores their role in Firestore
  static Future<String?> registerUser(String email, String password, String role) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null; // Successful registration
    } catch (e) {
      return e is FirebaseAuthException ? e.message : 'Registration error.';
    }
  }

  /// Logs in a user and verifies existence in Firestore
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
}
