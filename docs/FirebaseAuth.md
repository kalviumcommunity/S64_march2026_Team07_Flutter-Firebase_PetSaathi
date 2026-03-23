# Firebase Authentication Flow in Flutter (Login / Signup System)

## 📌 Overview
This assignment demonstrates how to implement a complete **authentication flow in Flutter using Firebase Authentication**. The app supports user signup, login, session persistence, and logout with real-time navigation using `authStateChanges()`.

---

## 🎯 Objective

- Implement Firebase Authentication in Flutter
- Build Login and Signup UI
- Manage user sessions dynamically
- Enable automatic navigation based on auth state
- Handle authentication errors gracefully

---

## 🔄 Authentication Flow

A typical Firebase authentication flow works as follows:

1. User signs up → Account created in Firebase
2. User logs in → Firebase returns authenticated session
3. App listens to auth state → Decides which screen to show
4. User logs out → Session cleared → Redirect to login screen

---

## 📦 Dependencies

Add the following dependencies in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
```

Run:

```bash
flutter pub get
```

---

## ⚙️ Firebase Initialization

### 🔹 main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Flow Demo',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
```

---

## 🔑 Key Concept: authStateChanges()

- Listens to login/logout events
- Automatically updates UI
- Removes need for manual navigation

---

## 🧑‍💻 Auth Screen (Login & Signup)

### 📁 File:
```
lib/screens/auth_screen.dart
```

### 🔹 Features:

- Email input
- Password input
- Login / Signup button
- Toggle between Login & Signup modes
- Error handling using SnackBars

---

### 💻 Example Logic:

```dart
Future<void> submitAuthForm(
  String email,
  String password,
  bool isLogin,
  BuildContext ctx,
) async {
  try {
    if (isLogin) {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } else {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
  } catch (err) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text('Authentication failed')),
    );
  }
}
```

---

## 🏠 Home Screen (Logged-in State)

### 📁 File:
```
lib/screens/home_screen.dart
```

### 💻 Example:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.email}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'You are logged in!',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
```

---

## 🚪 Logout Flow

```dart
FirebaseAuth.instance.signOut();
```

### 🔄 What Happens:

- User session is cleared
- `authStateChanges()` emits null
- App automatically navigates back to AuthScreen

---

## 🔁 Seamless Navigation

### ✅ Achieved Using:

- `StreamBuilder`
- `FirebaseAuth.instance.authStateChanges()`

### 🔹 Benefits:

- No manual navigation needed
- Real-time UI updates
- Clean architecture

---

## 🧪 Testing & Verification

### ✅ Test Cases:

| Action | Expected Result |
|------|---------------|
| Sign Up | User created in Firebase |
| Login | Navigate to HomeScreen |
| Logout | Return to AuthScreen |
| Invalid Email | Error shown |
| Wrong Password | Error shown |
| Existing Account | Error handled |

---

## 📸 Screenshots

### 1️⃣ Auth Screen
- Login & Signup UI

### 2️⃣ Home Screen
- Welcome message with email

### 3️⃣ Firebase Console
- Users list showing registered accounts

*(Add screenshots here)*

---

## ⚠️ Error Handling

Common errors handled:

- Invalid email format
- Weak password
- Email already in use
- Incorrect password

---

## ⚙️ Key Observations

- Firebase handles authentication securely
- Stream-based UI simplifies navigation
- Minimal backend setup required
- Real-time session handling improves UX

---

## 🤔 Reflection

### 🔹 Why is authentication important?

- Secures user data
- Enables personalized experience
- Controls access to features

---

### 🔹 Why use authStateChanges()?

- Automatically listens to auth changes
- Eliminates manual routing logic
- Improves performance and UX

---

### 🔹 How does this scale?

- Can be extended with:
  - Google Sign-In
  - Phone OTP login
  - Role-based access (Pet Owner / Caregiver)

---

## 🚀 Learning Outcomes

- Implemented full authentication flow
- Used Firebase Auth APIs effectively
- Built dynamic UI with StreamBuilder
- Managed user sessions in real-time

---

## ✅ Conclusion

This assignment demonstrates how to build a complete and scalable authentication system in Flutter using Firebase. With real-time auth state handling and minimal setup, Firebase provides a powerful solution for modern mobile applications.

---

## 📌 Next Steps

- Add Google Sign-In
- Implement password reset
- Store user data in Firestore
- Add role-based dashboards (PetSaathi use-case)
