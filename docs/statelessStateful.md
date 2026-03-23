# Stateless vs Stateful Widgets Demo App

## 📌 Overview
This assignment demonstrates the difference between **StatelessWidget** and **StatefulWidget** in Flutter by building a simple interactive application. The app showcases how static and dynamic UI components behave and update based on user interaction.

---

## 🎯 Objective

- Understand the difference between Stateless and Stateful widgets
- Build a demo app combining both widget types
- Implement user interaction to trigger UI updates
- Observe how Flutter efficiently rebuilds UI components

---

## 🧠 Concept Explanation

### 🔹 Stateless Widget

A `StatelessWidget` is immutable, meaning it does not hold any internal state. Once built, it remains unchanged unless its parent widget rebuilds it with new data.

#### Key Characteristics:
- No internal state
- Lightweight and fast
- Used for static UI elements

#### Example:

```dart
class GreetingWidget extends StatelessWidget {
  final String name;

  const GreetingWidget({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text('Hello, $name!');
  }
}
```

✅ This widget only updates if the parent passes a new value.

---

### 🔹 Stateful Widget

A `StatefulWidget` maintains mutable state that can change over time. It allows dynamic updates in response to user interaction or data changes.

#### Key Characteristics:
- Has internal state
- Uses `setState()` to update UI
- Suitable for interactive components

#### Example:

```dart
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int count = 0;

  void increment() {
    setState(() {
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: increment,
          child: Text('Increase'),
        ),
      ],
    );
  }
}
```

✅ `setState()` triggers a rebuild of only the affected UI parts.

---

## 🏗️ Implementation

### 📁 File Structure

```
lib/
 └── screens/
      └── stateless_stateful_demo.dart
```

---

## 📱 Demo App Description

The app consists of:

### 1️⃣ Stateless Component (Header)
- Displays static text: **"Interactive Counter App"**
- Does not change during interaction

### 2️⃣ Stateful Component (Counter)
- Displays a counter value
- Updates when the button is pressed

---

## 💻 Complete Code

```dart
import 'package:flutter/material.dart';

class StatelessStatefulDemo extends StatelessWidget {
  const StatelessStatefulDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stateless vs Stateful Demo"),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HeaderWidget(),
            SizedBox(height: 20),
            CounterWidget(),
          ],
        ),
      ),
    );
  }
}

// Stateless Widget (Static UI)
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Interactive Counter App",
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

// Stateful Widget (Dynamic UI)
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int count = 0;

  void incrementCounter() {
    setState(() {
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Count: $count',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: incrementCounter,
          child: const Text("Increase"),
        ),
      ],
    );
  }
}
```

---

## 🔄 UI Interaction Flow

1. App loads with:
   - Header text (static)
   - Counter value = 0

2. User presses button:
   - `setState()` is triggered
   - Counter updates instantly

3. UI Behavior:
   - Header (Stateless) → ❌ No change
   - Counter (Stateful) → ✅ Updates dynamically

---

## 📊 Testing & Verification

### ✅ Steps Performed

- Ran app on emulator/device
- Interacted with button
- Observed UI changes

---

### 📸 Screenshots

#### Initial State
- Counter shows **0**
- Header visible

#### After Interaction
- Counter increases (e.g., 1, 2, 3...)
- Header remains unchanged

*(Add screenshots here in your repo)*

---

## ⚙️ Key Observations

- Stateless widgets are efficient for static UI
- Stateful widgets allow dynamic interaction
- `setState()` updates only required parts of UI
- Flutter rebuilds UI efficiently without affecting performance

---

## 🚀 Learning Outcomes

- Clear understanding of widget types
- Hands-on experience with UI updates
- Learned how Flutter manages rendering efficiently
- Built a foundation for advanced state management

---

## ⚠️ Common Mistakes

| Mistake | Fix |
|--------|-----|
| Forgetting `setState()` | Wrap state changes inside `setState()` |
| Using Stateful unnecessarily | Use Stateless for static UI |
| Rebuilding entire UI | Keep widgets modular |

---

## ✅ Conclusion

This assignment successfully demonstrates how **Stateless and Stateful widgets work together** in Flutter. While Stateless widgets handle static content, Stateful widgets enable dynamic, interactive experiences, making Flutter apps responsive and efficient.

---

## 📌 Next Steps

- Explore advanced state management (Provider, Riverpod)
- Build more interactive UI components
- Integrate backend (Firebase) for real-world data
