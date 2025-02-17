import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static Future<void> logoutUser() async => await _auth.signOut();

  static Future<String?> registerUser({
    required String email,
    required String password,
    required String role,
    required String phone,
    required String date,
    String? name,
    String? lastName,
    String? organizationName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String fullName = role == 'volunteer' ? "$name $lastName" : organizationName ?? "No Name";

      await _db.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'phone': phone,
        'date': date,
        'name': fullName,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (role == 'volunteer') {
        await _db.collection('volunteers').doc(userCredential.user!.uid).set({
          'name': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'date': date,
          'location': "",
          'interests': [],
          'skills': [],
        });
      } else if (role == 'organization') {
        await _db.collection('organizations').doc(userCredential.user!.uid).set({
          'name': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'date': date,
          'missions': [],
          'objectives': [],
          'volunteerTypes': [],
          'locations': [],
        });
      }

      return null;
    } catch (e) {
      return e is FirebaseAuthException ? e.message : 'Registration error.';
    }
  }

  static Future<String?> getUserName(String uid) async {
    try {
      final volunteerDoc = await _db.collection('volunteers').doc(uid).get();
      if (volunteerDoc.exists && volunteerDoc.data()?['name'] != null) {
        return volunteerDoc.get('name');
      }

      final orgDoc = await _db.collection('organizations').doc(uid).get();
      if (orgDoc.exists && orgDoc.data()?['name'] != null) {
        return orgDoc.get('name');
      }

      final userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data()?['name'] != null) {
        return userDoc.get('name');
      }

      return "Not specified";
    } catch (e) {
      return "Not specified";
    }
  }

  static Future<Map<String, dynamic>?> getVolunteerProfile(String uid) async {
    try {
      final userDoc = await _db.collection('volunteers').doc(uid).get();
      return userDoc.exists ? userDoc.data() : null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getOrganizationProfile(String uid) async {
    try {
      final orgDoc = await _db.collection('organizations').doc(uid).get();
      if (orgDoc.exists) {
        final data = orgDoc.data();
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> loginUser(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _db.collection('users').doc(userCredential.user!.uid).get();
      return userDoc.exists ? null : 'User not found in Firestore.';
    } catch (e) {
      return e is FirebaseAuthException ? e.message : 'Login error.';
    }
  }

  static Future<String?> getUserRole(String uid) async {
    try {
      final userDoc = await _db.collection('users').doc(uid).get();
      return userDoc.exists ? userDoc.get('role') : 'Role not found';
    } catch (e) {
      return 'Error retrieving role.';
    }
  }

  static Future<String?> getOrganizationName(String uid) async {
    try {
      final doc = await _db.collection('organizations').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['name'] ?? "No Name Available";
      } else {
        return "Organization Not Found";
      }
    } catch (e) {
      return "Error retrieving organization";
    }
  }

  static Future<void> updateProfile({
    required String uid,
    required String role,
    String? name,
    String? email,
    String? phone,
    String? date,
    String? password,
  }) async {
    try {
      Map<String, dynamic> updatedData = {};
      if (name != null) updatedData['name'] = name;
      if (email != null) updatedData['email'] = email;
      if (phone != null) updatedData['phone'] = phone;
      if (password != null) updatedData['password'] = password;
      if (date != null) {
        if (role == 'organization') {
          updatedData['date'] = date;
        } else {
          updatedData['date'] = date;
        }
      }

      await _db.collection('users').doc(uid).set(updatedData, SetOptions(merge: true));

      if (role == 'volunteer') {
        await _db.collection('volunteers').doc(uid).set(updatedData, SetOptions(merge: true));
      } else if (role == 'organization') {
        await _db.collection('organizations').doc(uid).set(updatedData, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
  }
}