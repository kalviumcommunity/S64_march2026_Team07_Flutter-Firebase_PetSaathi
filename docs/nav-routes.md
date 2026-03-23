# 🚀 Flutter Multi-Screen Navigation Guide

## 📌 Overview
This project demonstrates how to implement **multi-screen navigation** in Flutter using the `Navigator` class.

You will learn:
- How navigation works in Flutter
- How to create multiple screens
- How to use named routes
- How to pass data between screens

---

# 🔁 1. Understanding Navigation in Flutter

## 🔹 What is Navigation?
In Flutter, apps often have multiple screens such as:
- Login Screen
- Home Screen
- Settings Screen

Navigation allows users to move between these screens.

Flutter uses a **stack-based system**:
- New screens are pushed onto the stack
- Old screens are popped off the stack

---

## 🔹 Navigator Methods

| Method | Description |
|-------|------------|
| `Navigator.push()` | Navigate to a new screen |
| `Navigator.pop()` | Go back to previous screen |
| `Navigator.pushNamed()` | Navigate using route name |
| `Navigator.popNamed()` | Pop using route name |

---

# 📁 2. Project Structure

```
lib/
 ┣ main.dart
 ┗ screens/
    ┣ home_screen.dart
    ┗ second_screen.dart
```

---

# 🖥️ 3. Create Screens

## 🔹 Home Screen (`home_screen.dart`)

```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/second');
          },
          child: Text('Go to Second Screen'),
        ),
      ),
    );
  }
}
```

---

## 🔹 Second Screen (`second_screen.dart`)

```dart
import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Second Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Back to Home'),
        ),
      ),
    );
  }
}
```

---

# ⚙️ 4. Define Routes in main.dart

```dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/second_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Initial Screen
      initialRoute: '/',

      // Route Mapping
      routes: {
        '/': (context) => HomeScreen(),
        '/second': (context) => SecondScreen(),
      },
    );
  }
}
```

---

## 🔹 Key Concepts

### initialRoute
- Defines the starting screen of the app
- `/` usually represents Home Screen

### routes
- A map connecting route names to screens
- Example:
  - `'/' → HomeScreen`
  - `'/second' → SecondScreen`

---

# 🧪 5. Testing Navigation

## ✅ Steps to Verify

1. Run the app
2. Click **"Go to Second Screen"**
   - App navigates to second screen
3. Click **"Back to Home"**
   - App returns to home screen

---

## 🔄 Navigation Flow

```
Home Screen → Second Screen → Back to Home
```

---

# 🔗 6. Passing Data Between Screens

## 🔹 Send Data from Home Screen

```dart
Navigator.pushNamed(
  context,
  '/second',
  arguments: 'Hello from Home!',
);
```

---

## 🔹 Receive Data in Second Screen

```dart
import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final message =
        ModalRoute.of(context)!.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(title: Text('Second Screen')),
      body: Center(
        child: Text(message ?? 'No data received'),
      ),
    );
  }
}
```

---

## 🔹 How It Works

1. Data is passed using `arguments`
2. Received using `ModalRoute`
3. Used inside UI

---

# 🧠 Key Learnings

- Flutter uses a **stack-based navigation system**
- `Navigator.push()` adds a screen
- `Navigator.pop()` removes a screen
- Named routes simplify navigation
- Data can be passed between screens easily

---

# ⚠️ Common Mistakes

| Issue | Fix |
|------|-----|
| Route not found | Check route name in `routes` |
| Navigation not working | Ensure correct context is used |
| Data not received | Check `arguments` type |
| App crashes | Verify null safety |

---

# 📸 Screenshots Required

Include:
1. Home Screen UI  
2. Second Screen UI  
3. Navigation transition  

---

# 🏁 Conclusion

This project demonstrates:
- Multi-screen navigation in Flutter  
- Route-based navigation system  
- Data sharing between screens  

Navigation is a core concept for building real-world Flutter applications like dashboards, authentication flows, and settings pages.
