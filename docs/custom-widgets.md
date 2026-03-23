# 🚀 Flutter Custom Widgets & Reusability Guide

## 📌 Overview
This project demonstrates how to create and reuse **custom widgets in Flutter**.

You will learn:
- What custom widgets are
- Types of custom widgets (Stateless & Stateful)
- How to create reusable components
- How to use them across multiple screens
- Benefits of modular UI design

---

# 🧩 1. What Are Custom Widgets?

## 🔹 Definition
In Flutter, everything is a widget — including:
- Text
- Buttons
- Layouts
- Entire screens

Custom widgets are **user-defined widgets** created to reuse UI components.

---

## 🔹 Why Use Custom Widgets?

- ✅ Reduce code duplication  
- ✅ Improve readability  
- ✅ Maintain clean structure  
- ✅ Easy updates across screens  
- ✅ Follow DRY principle (Don't Repeat Yourself)

---

## 🔹 Example Use Case
Instead of writing the same card UI multiple times, create one reusable widget and use it everywhere.

---

# 🏗️ 2. Types of Custom Widgets

## 🔹 a. Stateless Custom Widget

Used when:
- UI does NOT change
- No dynamic data updates

---

## 🖥️ Example: InfoCard

```dart
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.teal),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}
```

---

## 🔹 Usage

```dart
InfoCard(
  title: 'Profile',
  subtitle: 'View your account details',
  icon: Icons.person,
),
```

---

## 🔹 b. Stateful Custom Widget

Used when:
- UI changes dynamically
- State updates (e.g., toggles, counters)

---

## 🖥️ Example: LikeButton

```dart
import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isLiked ? Icons.favorite : Icons.favorite_border,
        color: _isLiked ? Colors.red : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          _isLiked = !_isLiked;
        });
      },
    );
  }
}
```

---

## 🔹 Usage

```dart
LikeButton()
```

---

# 📁 3. Build and Reuse Custom Widgets

## 🔹 Project Structure

```
lib/
 ┣ screens/
 ┃ ┣ home_screen.dart
 ┃ ┗ details_screen.dart
 ┗ widgets/
    ┗ custom_button.dart
```

---

## 🔹 Create Custom Button

### 📄 File: `lib/widgets/custom_button.dart`

```dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const CustomButton({
    required this.label,
    required this.onPressed,
    this.color = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
```

---

# 🖥️ 4. Use Custom Widget in Screens

## 🔹 Home Screen

### 📄 `lib/screens/home_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: CustomButton(
          label: 'Go to Details',
          onPressed: () {
            Navigator.pushNamed(context, '/details');
          },
        ),
      ),
    );
  }
}
```

---

## 🔹 Details Screen

### 📄 `lib/screens/details_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class DetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: Center(
        child: CustomButton(
          label: 'Back',
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.orange,
        ),
      ),
    );
  }
}
```

---

# 🔄 5. Reusability Demonstration

## 🔹 Same Widget, Different Behavior

| Screen | Label | Action | Color |
|------|------|--------|------|
| Home | Go to Details | Navigate forward | Teal |
| Details | Back | Navigate back | Orange |

---

# 🧪 6. Testing

## ✅ Steps

1. Run the app  
2. Navigate between screens  
3. Verify:
   - Button appears on both screens  
   - Each button performs correct action  
   - UI design remains consistent  

---

# 📸 Screenshots Required

Include:
1. Home Screen with Custom Button  
2. Details Screen with Custom Button  
3. Navigation between screens  

---

# 🧠 Key Learnings

- Custom widgets improve code reuse  
- Stateless widgets are for static UI  
- Stateful widgets handle dynamic UI  
- Widgets can be reused across multiple screens  
- Flutter promotes modular design  

---

# ⚠️ Common Mistakes

| Issue | Fix |
|------|-----|
| Repeating UI code | Use custom widgets |
| Wrong widget type | Choose Stateful vs Stateless correctly |
| Hardcoded values | Use parameters |
| Styling inconsistency | Centralize design in widgets |

---

# 🏁 Conclusion

This project demonstrates:
- Creating reusable UI components  
- Using custom widgets across screens  
- Maintaining clean and scalable Flutter code  

Custom widgets are essential for building **large, maintainable, and professional Flutter applications**.
