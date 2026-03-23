# 🚀 Flutter Firebase Authentication (Email & Password)

## 📌 Overview
This project demonstrates how to implement **Firebase Authentication** in Flutter using **Email & Password login/signup**.

You will learn:
- What Firebase Authentication is  
- How to enable authentication in Firebase  
- How to integrate Firebase with Flutter  
- How to build login/signup UI  
- How to handle authentication state  
- How to fix common errors  

---

# 🔐 1. What Is Firebase Authentication?

Firebase Authentication is a service that provides:
- Secure user authentication
- Backend identity management
- Easy integration with Flutter apps

---

## 🔹 Supported Methods
- Email & Password ✅ (used in this project)
- Google Sign-In
- Phone Authentication
- Apple / GitHub Login

---

# ⚙️ 2. Enable Authentication in Firebase Console

## 🔹 Steps

1. Open **Firebase Console**
2. Go to **Authentication**
3. Click **Sign-in Method**
4. Select **Email/Password**
5. Enable it
6. Click **Save**

---

# 📦 3. Add Dependencies

Update your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
```

---

## 🔹 Install Packages

```bash
flutter pub get
```

---

# 🔌 4. Initialize Firebase

## 📄 main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      home: AuthScreen(),
    );
  }
}
```

---

# 🖥️ 5. Create Authentication Screen

## 📄 File:
```
lib/screens/auth_screen.dart
```

---

## 🧾 Complete Code

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLogin = true;

  Future<void> _submitAuthForm() async {
    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLogin ? 'Login Successful!' : 'Signup Successful!',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication Error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Auth Demo')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Email Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),

            // Password Field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),

            SizedBox(height: 20),

            // Login / Signup Button
            ElevatedButton(
              onPressed: _submitAuthForm,
              child: Text(isLogin ? 'Login' : 'Signup'),
            ),

            // Toggle Mode
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(
                isLogin
                    ? 'Create new account'
                    : 'Already have an account? Login',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔹 How It Works

- User enters email & password  
- Clicks Login or Signup  
- Firebase API handles authentication  
- Success or error message displayed  

---

# 🔍 6. Verify User Authentication

## 🔹 Steps

1. Open Firebase Console  
2. Go to **Authentication → Users**  
3. Check:
   - Registered email
   - User ID  
   - Timestamp  

---

# 🔄 7. Authentication State & Logout

## 🔹 Check Auth State

```dart
FirebaseAuth.instance.authStateChanges().listen((User? user) {
  if (user == null) {
    print('User is signed out');
  } else {
    print('User is signed in: ${user.email}');
  }
});
```

---

## 🔹 Logout User

```dart
await FirebaseAuth.instance.signOut();
```

---

# 🧪 8. Testing

## ✅ Steps

1. Run the app  
2. Signup with new email  
3. Login with same credentials  
4. Verify in Firebase Console  
5. Logout user  

---

## 📊 Expected Output

- User successfully logs in  
- Firebase stores user data  
- UI responds correctly  

---

# 📸 Screenshots Required

Include:

1. Login screen  
2. Signup screen  
3. Success message  
4. Firebase Console (Users tab)  

---

# ⚠️ Common Issues & Fixes

| Error | Cause | Fix |
|------|------|-----|
| Invalid email | Wrong format | Use valid email |
| Weak password | < 6 characters | Use longer password |
| Firebase not initialized | Missing setup | Add initializeApp() |
| App crash | Dependency issue | Run `flutter pub get` |

---

# 🧠 Key Learnings

- Firebase handles authentication securely  
- Easy integration with Flutter  
- Login/signup using simple APIs  
- Real-time backend sync  
- Authentication state can be tracked  

---

# 🏁 Conclusion

This project demonstrates:
- Firebase Email/Password authentication  
- Login & Signup UI implementation  
- Backend integration with Firebase  
- State handling and logout functionality  

Firebase Authentication is essential for building:
- Secure apps  
- User-based platforms  
- Scalable applications  
