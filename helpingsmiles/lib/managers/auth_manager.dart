import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Registers a new user and stores data in Firestore
  static Future<String?> registerUser(String email, String password, String role) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user ID
      String uid = userCredential.user!.uid;

      // Save user data in Firestore
      await _db.collection('users').doc(uid).set({
        'email': email,
        'role': role, // Stores 'volunteer' or 'organization'
        'createdAt': FieldValue.serverTimestamp(), // Timestamp for record creation
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return Firebase authentication errors
    } catch (e) {
      return 'An error occurred during registration.';
    }
  }

  /// Logs in a user and retrieves their role
  static Future<String?> loginUser(String email, String password) async {
    try {
      // Sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user ID
      String uid = userCredential.user!.uid;

      // Fetch the user's role from Firestore
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();

      if (userDoc.exists) {
        String role = userDoc.get('role'); // Retrieve role (volunteer/organization)
        return role; // Return the user's role
      } else {
        return 'User data not found.';
      }
    } on FirebaseAuthException catch (e) {
      return e.message; // Return Firebase authentication errors
    } catch (e) {
      return 'An error occurred during login.';
    }
  }
}
