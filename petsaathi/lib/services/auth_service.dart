import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> signUp(String email, String password, String role) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save role to Firestore
      if (userCredential.user != null) {
        final defaultName = email.split('@').first;
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'role': role,
          'name': defaultName,
          'avatarUrl': null,
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      
      return userCredential.user;
    } catch (e, st) {
      debugPrint('Signup Error: $e');
      debugPrint('$st');
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e, st) {
      debugPrint('Login Error: $e');
      debugPrint('$st');
      return null;
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

  Stream<UserProfile?> watchCurrentUserProfile() {
    final user = currentUser;
    if (user == null) {
      return Stream.value(null);
    }
    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return UserProfile(
        uid: user.uid,
        role: (data['role'] as String?) ?? 'owner',
        email: (data['email'] as String?) ?? '',
        name: (data['name'] as String?) ?? 'Pet Parent',
        avatarUrl: data['avatarUrl'] as String?,
      );
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

class UserProfile {
  final String uid;
  final String role;
  final String email;
  final String name;
  final String? avatarUrl;

  const UserProfile({
    required this.uid,
    required this.role,
    required this.email,
    required this.name,
    required this.avatarUrl,
  });
}