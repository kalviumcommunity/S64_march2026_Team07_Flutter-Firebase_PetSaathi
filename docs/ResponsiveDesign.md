# Responsive Design in Flutter (MediaQuery & LayoutBuilder)

## 📌 Overview
This assignment demonstrates how to build **responsive and adaptive user interfaces in Flutter** using `MediaQuery` and `LayoutBuilder`. The goal is to ensure that the UI adjusts dynamically across different screen sizes such as mobile phones and tablets.

---

## 🎯 Objective

- Understand responsive design principles in Flutter
- Use `MediaQuery` to adapt UI based on screen dimensions
- Use `LayoutBuilder` to render different layouts conditionally
- Build a UI that works across multiple devices

---

## 🧠 What is Responsive Design?

Responsive design ensures that the app layout adapts to different:

- Screen sizes (mobile, tablet)
- Orientations (portrait, landscape)
- Device types

### ✅ Why It Matters

- Improves usability across devices  
- Maintains consistent UI/UX  
- Prevents layout breakage and overflow issues  
- Enhances accessibility  

---

## 📏 Using MediaQuery

`MediaQuery` provides information about the device screen such as width, height, and orientation.

### 🔹 Example

```dart
var screenWidth = MediaQuery.of(context).size.width;
var screenHeight = MediaQuery.of(context).size.height;
```

### 🔹 Responsive Container Example

```dart
Container(
  width: screenWidth * 0.8,
  height: screenHeight * 0.1,
  color: Colors.teal,
  child: Center(child: Text('Responsive Container')),
);
```

### ✅ Key Idea:
- Use percentages instead of fixed values
- UI scales automatically across devices

---

## 🧱 Using LayoutBuilder

`LayoutBuilder` allows building UI based on available space (constraints).

### 🔹 Example

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return Column(
        children: [
          Text('Mobile Layout'),
          Icon(Icons.phone_android, size: 80),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Tablet Layout'),
          SizedBox(width: 20),
          Icon(Icons.tablet, size: 100),
        ],
      );
    }
  },
);
```

### ✅ Behavior:

| Screen Width | Layout |
|-------------|--------|
| < 600 px    | Column (Mobile) |
| ≥ 600 px    | Row (Tablet) |

---

## 🔗 Combining MediaQuery & LayoutBuilder

Using both together provides powerful responsiveness.

---

## 💻 Complete Implementation

```dart
import 'package:flutter/material.dart';

class ResponsiveDemo extends StatelessWidget {
  const ResponsiveDemo({super.key});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Design Demo'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (screenWidth < 600) {
            // Mobile Layout
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.8,
                  height: 100,
                  color: Colors.tealAccent,
                  child: const Center(child: Text('Mobile View')),
                ),
              ],
            );
          } else {
            // Tablet Layout
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 250,
                  height: 150,
                  color: Colors.orangeAccent,
                  child: const Center(child: Text('Tablet Left Panel')),
                ),
                Container(
                  width: 250,
                  height: 150,
                  color: Colors.tealAccent,
                  child: const Center(child: Text('Tablet Right Panel')),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
```

---

## 🔄 Layout Behavior

### 📱 Mobile Devices
- Uses **Column layout**
- Elements stacked vertically
- Optimized for smaller screens

### 📟 Tablet Devices
- Uses **Row layout**
- Elements placed side-by-side
- Better use of wide screens

---

## 🧪 Testing & Verification

### Devices Tested:

- 📱 Mobile Emulator (Pixel 4)
- 📟 Tablet Emulator (Nexus 9 / iPad)

---

### ✅ Observations

- Layout adapts correctly to screen size
- No overflow or UI distortion
- Smooth transition between layouts
- Proper spacing and alignment maintained

---

## 📸 Screenshots

### 1️⃣ Mobile Layout
- Vertical stacking
- Compact UI

### 2️⃣ Tablet Layout
- Horizontal arrangement
- Expanded UI

*(Add your screenshots here)*

---

## ⚙️ Key Differences

### 🔹 MediaQuery vs LayoutBuilder

| Feature | MediaQuery | LayoutBuilder |
|--------|-----------|--------------|
| Based on | Screen size | Parent constraints |
| Use case | Global responsiveness | Local layout control |
| Flexibility | Medium | High |

---

## 🤔 Reflection

### 🔹 Why is responsiveness important?

- Ensures app works on all devices  
- Improves user experience  
- Prevents UI issues on different screen sizes  
- Makes app scalable  

---

### 🔹 How does LayoutBuilder differ from MediaQuery?

- `MediaQuery` gives **device-level info**
- `LayoutBuilder` gives **widget-level constraints**
- LayoutBuilder is more flexible for conditional UI rendering

---

### 🔹 How can this scale your app?

- Helps build adaptable dashboards (like PetSaathi)
- Enables reusable UI components
- Supports future device expansion (tablets, foldables)

---

## ⚠️ Common Issues & Fixes

| Issue | Solution |
|------|---------|
| Overflow errors | Use Flexible / Expanded |
| Fixed UI breaking | Avoid hardcoded sizes |
| Layout not changing | Check width conditions |
| Poor spacing | Use SizedBox & padding |

---

## 🚀 Learning Outcomes

- Learned responsive design principles
- Used MediaQuery for dynamic sizing
- Used LayoutBuilder for adaptive layouts
- Built cross-device compatible UI

---

## ✅ Conclusion

This assignment highlights how Flutter enables developers to create responsive applications using simple yet powerful tools like `MediaQuery` and `LayoutBuilder`. By adapting layouts dynamically, we can ensure a seamless experience across all devices.

---

## 📌 Next Steps

- Use `OrientationBuilder` for rotation handling
- Explore Grid layouts
- Apply responsiveness to full apps
- Integrate with real-world UI (e.g., dashboards)
