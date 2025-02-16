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
    required String date, // ✅ Se almacena la fecha de nacimiento
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

      // Guardar datos generales del usuario en la colección 'users'
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'phone': phone,
        'date': date,
        'name': fullName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (role == 'volunteer') {
        await _db.collection('volunteers').doc(userCredential.user!.uid).set({
          'name': fullName,
          'email': email,
          'phone': phone,
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
          'date': date, // ⚠️ Asegúrate de que Firestore usa "date" y no "date" para organizaciones
          'missions': [],
          'objectives': [],
          'volunteerTypes': [],
          'locations': [],
        });
      }

      return null; // Successful registration
    } catch (e) {
      return e is FirebaseAuthException ? e.message : 'Registration error.';
    }
  }

  /// Retrieves the user's name from Firestore (checking both 'volunteers' and 'organizations')
  static Future<String?> getUserName(String uid) async {
    try {
      // Buscar primero en 'volunteers'
      final volunteerDoc = await _db.collection('volunteers').doc(uid).get();
      if (volunteerDoc.exists && volunteerDoc.data()?['name'] != null) {
        return volunteerDoc.get('name');
      }

      // Si no está en 'volunteers', buscar en 'organizations'
      final orgDoc = await _db.collection('organizations').doc(uid).get();
      if (orgDoc.exists && orgDoc.data()?['name'] != null) {
        return orgDoc.get('name');
      }

      // Si tampoco está en 'organizations', buscar en 'users'
      final userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data()?['name'] != null) {
        return userDoc.get('name');
      }

      return "Not specified"; // Valor por defecto si no se encuentra el nombre
    } catch (e) {
      return "Not specified"; // En caso de error
    }
  }

  /// Retrieves the full profile of a volunteer
  static Future<Map<String, dynamic>?> getVolunteerProfile(String uid) async {
    try {
      final userDoc = await _db.collection('volunteers').doc(uid).get();
      return userDoc.exists ? userDoc.data() : null;
    } catch (e) {
      return null;
    }
  }

    /// Retrieves the full profile of an organization
  static Future<Map<String, dynamic>?> getOrganizationProfile(String uid) async {
    try {
      final orgDoc = await _db.collection('organizations').doc(uid).get();
      if (orgDoc.exists) {
        final data = orgDoc.data();
        data?['email'] = await getUserEmail(uid); // Asegurar que se obtiene el email
        return data;
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
        password: password,
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

  /// Updates the profile of a volunteer or organization
  static Future<void> updateProfile({
    required String uid,
    required String role,
    String? name,
    String? email,
    String? phone,
    String? date,
  }) async {
    try {
      // Construir los datos para actualizar
      Map<String, dynamic> updatedData = {};
      if (name != null) updatedData['name'] = name;
      if (email != null) updatedData['email'] = email;
      if (phone != null) updatedData['phone'] = phone;
      if (date != null) {
        if (role == 'organization') {
          updatedData['date'] = date; // ⚠️ Se usa "date" para organizaciones
        } else {
          updatedData['date'] = date; // Se usa "date" para voluntarios
        }
      }

      // Actualizar en 'users'
      await _db.collection('users').doc(uid).set(updatedData, SetOptions(merge: true));

      // Actualizar en la colección correspondiente
      if (role == 'volunteer') {
        await _db.collection('volunteers').doc(uid).set(updatedData, SetOptions(merge: true));
      } else if (role == 'organization') {
        await _db.collection('organizations').doc(uid).set(updatedData, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
  }


    /// Retrieves the user's email from Firestore
  static Future<String?> getUserEmail(String uid) async {
    try {
      // Primero verificar en 'volunteers'
      final volunteerDoc = await _db.collection('volunteers').doc(uid).get();
      if (volunteerDoc.exists && volunteerDoc.data()?['email'] != null) {
        return volunteerDoc.get('email');
      }

      // Luego verificar en 'organizations'
      final orgDoc = await _db.collection('organizations').doc(uid).get();
      if (orgDoc.exists && orgDoc.data()?['email'] != null) {
        return orgDoc.get('email');
      }

      // Finalmente verificar en 'users'
      final userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data()?['email'] != null) {
        return userDoc.get('email');
      }

      return "Not specified"; // Si no se encuentra el email
    } catch (e) {
      return "Not specified"; // En caso de error
    }
  }

}
