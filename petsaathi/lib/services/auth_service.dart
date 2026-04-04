import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();


  Future<User?> signUp(String email, String password, String role) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save role to Firestore
      if (userCredential.user != null) {
        final defaultName = email.split('@').first;
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          role: role,
          name: defaultName,
          avatarUrl: null,
          isAvailable: true,
          trustScore: 5.0,
          location: 'New York, US', // Default
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toMap());
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Signup FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e, st) {
      debugPrint('Signup Error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Login FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e, st) {
      debugPrint('Login Error: $e');
      debugPrint('$st');
      rethrow;
    }
  }
  
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'];
      }
      return null;
    } catch (e, st) {
      debugPrint('Get Role Error: $e');
      debugPrint('$st');
      return null;
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(uid, doc.data()!);
      }
      return null;
    } catch (e, st) {
      debugPrint('Get Profile Error: $e');
      debugPrint('$st');
      return null;
    }
  }

  Stream<UserModel?> watchCurrentUserProfile() {
    final user = currentUser;
    if (user == null) {
      return Stream.value(null);
    }
    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return UserModel.fromMap(user.uid, data);
    });
  }

  Future<void> updateProfile({
    required String name,
    required String? location,
    required bool isAvailable,
  }) async {
    final user = currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'location': location,
        'isAvailable': isAvailable,
      });
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}