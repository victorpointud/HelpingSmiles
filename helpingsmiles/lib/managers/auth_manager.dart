import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> logoutUser() async {
      await _auth.signOut();
    }
  /// Registers a new user and stores data in Firestore
  static Future<String?> registerUser(String email, String password, String role) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await _db.collection('users').doc(uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An error occurred during registration.';
    }
  }

  /// Logs in a user and navigates based on role
  static Future<String?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return null; // Login successful
      } else {
        return 'User data not found.';
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An error occurred during login.';
    }
  }

  /// Retrieves the user role from Firestore
  static Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.get('role');
      } else {
        return 'Role not found';
      }
    } catch (e) {
      return 'Error retrieving role';
    }
  }
}
