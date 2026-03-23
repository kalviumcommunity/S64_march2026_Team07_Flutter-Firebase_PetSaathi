# 🚀 Flutter Firebase Integration (Complete Guide)

## 📌 Overview
This project demonstrates how to integrate Firebase into a Flutter application, including Authentication and Firestore database with full CRUD functionality.

---

## 🔧 Step 1: Create Firebase Project
1. Go to Firebase Console
2. Click "Add Project"
3. Enter project name
4. Disable Google Analytics (optional)
5. Click "Create Project"

---

## 📱 Step 2: Add Your Flutter App

### Android Setup
1. Click "Add App" → Android
2. Enter your package name (from android/app/build.gradle)
3. Download `google-services.json`
4. Place it inside:
   android/app/

### iOS Setup
1. Click "Add App" → iOS
2. Enter Bundle ID
3. Download `GoogleService-Info.plist`
4. Place it inside:
   ios/Runner/

---

## ⚙️ Step 3: Install FlutterFire CLI

Run:
dart pub global activate flutterfire_cli

Then configure Firebase:
flutterfire configure

---

## 📦 Step 4: Add Dependencies

Open pubspec.yaml and add:

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0

Then run:
flutter pub get

---

## 🔌 Step 5: Initialize Firebase

In main.dart:

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

---

## 🔐 Step 6: Firebase Authentication Service

Create file:
lib/services/auth_service.dart

Add:

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

---

## 🖥️ Step 7: Signup Screen

Create:
lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: "Email"),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: "Password"),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: () async {
              var user = await _auth.signUp(
                emailController.text,
                passwordController.text,
              );
              if (user != null) {
                Navigator.pushNamed(context, '/home');
              }
            },
            child: Text("Signup"),
          ),
        ],
      ),
    );
  }
}

---

## 🖥️ Step 8: Login Screen

Create:
lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: "Email"),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: "Password"),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: () async {
              var user = await _auth.login(
                emailController.text,
                passwordController.text,
              );
              if (user != null) {
                Navigator.pushNamed(context, '/home');
              }
            },
            child: Text("Login"),
          ),
        ],
      ),
    );
  }
}

---

## 🎯 Step 9: Home Screen

Display logged-in user:

Text("Welcome, ${FirebaseAuth.instance.currentUser?.email}");

---

## 🗄️ Step 10: Firestore Service

Create:
lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data);
  }

  Stream<QuerySnapshot> getUserData() {
    return _db.collection('users').snapshots();
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> deleteUserData(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }
}

---

## 📊 Step 11: Display Firestore Data

Use StreamBuilder:

StreamBuilder(
  stream: FirestoreService().getUserData(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();

    var docs = snapshot.data!.docs;

    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(docs[index]['name']),
        );
      },
    );
  },
);

---

## 🧪 Step 12: Testing

Perform these tests:

- Signup new user
- Login with same credentials
- Logout user
- Add Firestore data
- Update Firestore data
- Delete Firestore data
- Verify real-time updates in app

---

## 📸 Screenshots Required

Take screenshots of:

1. User successfully logged in
2. Firestore data displayed in app
3. Firebase Console:
   - Authentication users
   - Firestore records

---

## ⚠️ Common Errors

- Firebase not initialized → Add await Firebase.initializeApp()
- App crash → Check config file placement
- Auth error → Check email/password format
- Firestore permission error → Update Firestore rules

---

## 🏁 Conclusion

This project successfully integrates Firebase Authentication and Firestore with Flutter. It allows users to sign up, log in, and perform real-time database operations with a smooth UI experience.
