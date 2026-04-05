# 🔐 Securing Firebase with Authentication & Firestore Rules

## 📌 Overview
This project demonstrates how to secure **Cloud Firestore** using:
- Firebase Authentication  
- Firestore Security Rules  

You will learn:
- Why Firestore security is important  
- How to enable authentication  
- How to write secure Firestore rules  
- How to restrict user access  
- How to test and validate rules  

---

# ⚠️ 1. Why Securing Firestore Matters

## 🔹 Importance

- 🔒 Protects sensitive user data  
- 👤 Ensures only authenticated users access data  
- 🚫 Prevents unauthorized writes/deletes  
- 🛡️ Stops spam and malicious activity  
- 🧑‍💼 Enables role-based access (admin vs user)  
- 🚀 Required for production apps  

---

## ❌ Default Problem (Test Mode)

Firestore starts in **test mode**:

```js
allow read, write: if true;
```

👉 This means:
- Anyone can read/write your database  
- Completely unsafe for real apps  

---

# 🔧 2. Firebase Authentication Setup

## 🔹 Step 1: Add Dependencies

```yaml
dependencies:
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
```

---

## 🔹 Install Packages

```bash
flutter pub get
```

---

## 🔹 Step 2: Initialize Firebase

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

---

## 🔹 Step 3: Enable Authentication

In Firebase Console:

1. Go to **Authentication**
2. Click **Sign-in Method**
3. Enable:
   - Email/Password OR
   - Google / Phone / others

---

## 🔹 Step 4: Sign In User

```dart
final auth = FirebaseAuth.instance;

Future<UserCredential> signIn(String email, String pass) {
  return auth.signInWithEmailAndPassword(
    email: email,
    password: pass,
  );
}
```

---

## 🔹 Current User

```dart
final user = FirebaseAuth.instance.currentUser;
```

---

# 🔐 3. Firestore Security Rules

## 🔹 What Rules Control

- Who can read data  
- Who can write data  
- Conditions for access  

---

## ❌ Unsafe Rule (Never Use in Production)

```js
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

---

## ✅ Secure Rule (Recommended)

```js
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null
                         && request.auth.uid == uid;
    }
  }
}
```

---

## 🔹 What This Ensures

- User must be authenticated  
- User can only access their own data  
- No cross-user data access  

---

# 📡 4. Firestore Access from Flutter

## 🔹 Write Data (Secure)

```dart
final uid = FirebaseAuth.instance.currentUser!.uid;

await FirebaseFirestore.instance
    .collection('users')
    .doc(uid)
    .set({
  'name': 'John Doe',
  'lastLogin': DateTime.now(),
});
```

---

## 🔹 Read Data (Secure)

```dart
final uid = FirebaseAuth.instance.currentUser!.uid;

final data = await FirebaseFirestore.instance
    .collection('users')
    .doc(uid)
    .get();

print(data.data());
```

---

## ⚠️ If Access Denied

- Throws `FirebaseException`  
- Means rules are blocking request  

---

# 🧪 5. Testing Firestore Rules

## 🔹 Firebase Console Testing

1. Go to **Firestore Database**
2. Open **Rules Tab**
3. Click **Rules Playground**

---

## 🔹 Simulate Requests

- Authenticated user (with UID)  
- Unauthenticated user  
- Test read/write operations  

---

# 🧩 6. Minimal Example

## 🔹 Flutter Service

```dart
class FirestoreService {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  Future<void> updateUserProfile() async {
    final uid = auth.currentUser!.uid;

    await db.collection('users').doc(uid).set({
      'updatedAt': DateTime.now(),
    });
  }
}
```

---

## 🔹 Matching Firestore Rule

```js
match /users/{uid} {
  allow read, write: if request.auth.uid == uid;
}
```

---

# 🛡️ 7. Advanced Security Ideas

## 🔹 Role-Based Access

```js
allow read: if request.auth != null;
allow write: if request.auth.token.admin == true;
```

---

## 🔹 Restrict Fields

```js
allow write: if request.resource.data.keys().hasOnly(['name', 'email']);
```

---

## 🔹 Validate Data

```js
allow write: if request.resource.data.name is string
             && request.resource.data.name.size() > 0;
```

---

# 📸 Screenshots Required

Include:

1. Authentication enabled in Firebase  
2. Firestore rules setup  
3. Successful write/read operation  
4. Rules Playground test results  

---

# 🧠 Key Learnings

- Firestore must be secured before production  
- Authentication verifies user identity  
- Rules enforce access control  
- UID-based access ensures data isolation  
- Testing rules is critical  

---

# ⚠️ Common Issues & Fixes

| Issue | Cause | Fix |
|------|------|-----|
| PERMISSION_DENIED | Rules blocking access | Match UID with auth |
| Write fails | User not logged in | Ensure authentication |
| Open database | Test mode enabled | Replace rules |
| Auth works locally but fails | Missing SHA keys | Add SHA-1/SHA-256 |

---

# 🏁 Conclusion

This project demonstrates:
- Securing Firestore with Authentication  
- Writing safe and scalable rules  
- Restricting user access properly  
- Testing and validating rules  

Proper security ensures:
- Safe user data  
- Scalable backend  
- Production-ready applications  
