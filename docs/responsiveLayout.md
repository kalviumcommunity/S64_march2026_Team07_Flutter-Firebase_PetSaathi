# Responsive Layout in Flutter (Container, Row, Column)

## 📌 Overview
This assignment focuses on understanding and implementing Flutter’s core layout widgets — **Container, Row, and Column** — to build a responsive user interface. The goal is to create a layout that adapts seamlessly across different screen sizes and orientations.

---

## 🎯 Objective

- Understand core Flutter layout widgets
- Combine widgets to build structured UI
- Implement responsive design using Flutter tools
- Ensure compatibility across multiple devices

---

## 🧠 Core Concepts

### 🔹 Container

The `Container` widget is a versatile layout component used to style and position child widgets.

#### Features:
- Padding & Margin
- Background color
- Width & Height
- Alignment

#### Example:

```dart
Container(
  padding: EdgeInsets.all(16),
  color: Colors.blue,
  child: Text('This is inside a Container'),
);
```

---

### 🔹 Row

The `Row` widget arranges its children **horizontally**.

#### Key Properties:
- `mainAxisAlignment`
- `crossAxisAlignment`

#### Example:

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Icon(Icons.home),
    Icon(Icons.search),
    Icon(Icons.person),
  ],
);
```

---

### 🔹 Column

The `Column` widget arranges its children **vertically**.

#### Example:

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text('Welcome!'),
    SizedBox(height: 10),
    ElevatedButton(onPressed: () {}, child: Text('Click Me')),
  ],
);
```

---

## 🏗️ Implementation

### 📁 File Structure

```
lib/
 └── screens/
      └── responsive_layout.dart
```

---

## 📱 Responsive Layout Description

The UI consists of:

1. **Header Section**
   - Full-width container
   - Fixed height
   - Displays title text

2. **Main Content Area**
   - Divided into two panels:
     - Left Panel
     - Right Panel
   - Adjusts layout based on screen size

---

## 💻 Complete Code

```dart
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Layout'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              height: 150,
              color: Colors.lightBlueAccent,
              child: const Center(
                child: Text(
                  'Header Section',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Responsive Content
            Expanded(
              child: screenWidth < 600
                  ? Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.amber,
                            child: const Center(
                              child: Text('Top Panel'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Container(
                            color: Colors.greenAccent,
                            child: const Center(
                              child: Text('Bottom Panel'),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.amber,
                            child: const Center(
                              child: Text('Left Panel'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            color: Colors.greenAccent,
                            child: const Center(
                              child: Text('Right Panel'),
                            ),
                          ),
                        ),
                      ],
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

## 📐 Responsive Design Strategy

### 🔹 MediaQuery

Used to get screen width:

```dart
double screenWidth = MediaQuery.of(context).size.width;
```

### 🔹 Layout Behavior

| Screen Size | Layout |
|------------|--------|
| Small (<600px) | Vertical (Column) |
| Large (≥600px) | Horizontal (Row) |

---

### 🔹 Expanded Widget

- Ensures equal space distribution
- Prevents overflow issues
- Makes layout flexible

---

## 🔄 UI Behavior

### 📱 Small Devices (Phone)
- Panels are stacked vertically
- Better readability
- Scroll-friendly

### 📲 Large Devices (Tablet)
- Panels displayed side-by-side
- Efficient use of space

---

## 🧪 Testing & Verification

### Devices Tested:

- 📱 Pixel 5 (Mobile)
- 📟 Tablet Emulator (Large Screen)

---

### ✅ Observations

- Layout adapts correctly based on screen size
- No overflow or UI breaking
- Content remains aligned and readable
- Smooth transition between layouts

---

## 📸 Screenshots

### Mobile View (Portrait)
- Header on top
- Panels stacked vertically

### Tablet View (Landscape)
- Header on top
- Panels displayed side-by-side

*(Add screenshots here in your repo)*

---

## ⚠️ Common Issues & Fixes

| Issue | Solution |
|------|---------|
| Overflow errors | Use Expanded/Flexible |
| Fixed width problems | Use MediaQuery |
| UI breaking on rotation | Use responsive layouts |
| Uneven spacing | Use SizedBox / padding |

---

## 🚀 Learning Outcomes

- Mastered core layout widgets
- Learned responsive UI design
- Understood layout adaptability
- Built device-independent UI

---

## ✅ Conclusion

This assignment demonstrates how Flutter’s layout system enables developers to create flexible and responsive interfaces. By combining `Container`, `Row`, and `Column` with responsive techniques like `MediaQuery` and `Expanded`, we can ensure a consistent user experience across devices.

---

## 📌 Next Steps

- Explore `LayoutBuilder` for advanced responsiveness
- Implement Grid-based layouts
- Integrate real data into UI
- Apply responsiveness to full apps (like PetSaathi)
