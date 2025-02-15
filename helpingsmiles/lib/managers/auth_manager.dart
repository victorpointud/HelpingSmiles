import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  /// Logs out the current user
  static Future<void> logoutUser() async => await _auth.signOut();

  /// Registers a new user and stores their role, name, phone, and date of birth
  static Future<String?> registerUser({
    required String email,
    required String password,
    required String role,
    required String phone,
    required String dateOfBirth, // ✅ Ahora se almacena la fecha de nacimiento
    String? name,
    String? lastName,
    String? organizationName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      String fullName = role == 'volunteer' ? "$name $lastName" : organizationName ?? "No Name";

      await _db.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'phone': phone,
        'dateOfBirth': dateOfBirth, // ✅ Se guarda la fecha de nacimiento
        'name': fullName, 
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (role == 'volunteer') {
        await _db.collection('volunteers').doc(userCredential.user!.uid).set({
          'name': fullName, 
          'email': email, // ✅ Ahora se guarda también el email
          'phone': phone,
          'dateOfBirth': dateOfBirth, // ✅ Se guarda también en la colección de voluntarios
          'location': "",
          'interests': [],
          'skills': [],
        });
      }

      return null; // Successful registration
    } catch (e) {
      return e is FirebaseAuthException ? e.message : 'Registration error.';
    }
  }

  /// Retrieves the user's name from Firestore (prioritizing 'volunteers' collection)
  static Future<String?> getUserName(String uid) async {
    try {
      // Check in 'volunteers' collection first
      final volunteerDoc = await _db.collection('volunteers').doc(uid).get();
      if (volunteerDoc.exists && volunteerDoc.data()!.containsKey('name')) {
        return volunteerDoc.get('name');
      }

      // If not found in 'volunteers', check in 'users' collection
      final userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data()!.containsKey('name')) {
        return userDoc.get('name');
      }

      return "Not specified"; // Default value if no name found
    } catch (e) {
      return "Not specified"; // Default in case of error
    }
  }

  /// Retrieves the full profile of the user (including phone, email, and dateOfBirth)
  static Future<Map<String, dynamic>?> getVolunteerProfile(String uid) async {
    try {
      final userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Logs in a user and verifies their role
  static Future<String?> loginUser(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

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
        return doc.data()?['name'] ?? "No Name Available"; 
      } else {
        return "Organization Not Found"; 
      }
    } catch (e) {
      return "Error retrieving organization"; 
    }
  }
}
