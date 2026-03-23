# 🚀 Flutter Scrollable Views (ListView & GridView)

## 📌 Overview
This project demonstrates how to use **scrollable widgets in Flutter** to efficiently display large or dynamic data.

You will learn:
- What scrollable views are
- How to use ListView
- How to use GridView
- Difference between static and dynamic lists
- How to combine multiple scrollable widgets

---

# 📜 1. Understanding Scrollable Views

## 🔹 What are Scrollable Views?
Mobile apps often contain large amounts of data such as:
- Chat messages
- Product lists
- Social media feeds

Instead of showing everything at once, Flutter uses **scrollable widgets**.

---

## 🔹 Common Scrollable Widgets

| Widget | Purpose |
|--------|--------|
| ListView | Displays items in a list (vertical/horizontal) |
| GridView | Displays items in a grid layout |

---

# 📋 2. ListView Example

## 🔹 Basic ListView

```dart
ListView(
  children: [
    ListTile(
      leading: Icon(Icons.person),
      title: Text('User 1'),
      subtitle: Text('Online'),
    ),
    ListTile(
      leading: Icon(Icons.person),
      title: Text('User 2'),
      subtitle: Text('Offline'),
    ),
  ],
);
```

---

## 🔹 Dynamic List (ListView.builder)

```dart
ListView.builder(
  itemCount: 10,
  itemBuilder: (context, index) {
    return ListTile(
      leading: CircleAvatar(child: Text('${index + 1}')),
      title: Text('Item $index'),
      subtitle: Text('Description of item $index'),
    );
  },
);
```

---

## 🔹 Why Use ListView.builder?

- Creates items **only when needed**
- Improves performance
- Saves memory
- Best for large datasets

---

# 🧱 3. GridView Example

## 🔹 Basic GridView

```dart
GridView.count(
  crossAxisCount: 2,
  crossAxisSpacing: 10,
  mainAxisSpacing: 10,
  children: [
    Container(color: Colors.teal, child: Center(child: Text('1'))),
    Container(color: Colors.orange, child: Center(child: Text('2'))),
    Container(color: Colors.blue, child: Center(child: Text('3'))),
    Container(color: Colors.purple, child: Center(child: Text('4'))),
  ],
);
```

---

## 🔹 Dynamic Grid (GridView.builder)

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemCount: 8,
  itemBuilder: (context, index) {
    return Container(
      color: Colors.primaries[index % Colors.primaries.length],
      child: Center(
        child: Text(
          'Tile $index',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  },
);
```

---

## 🔹 Why Use GridView.builder?

- Efficient rendering
- Ideal for image galleries
- Handles large datasets smoothly

---

# 🔗 4. Combining ListView & GridView

## 📁 Create File:
```
lib/screens/scrollable_views.dart
```

---

## 🖥️ Complete Implementation

```dart
import 'package:flutter/material.dart';

class ScrollableViews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scrollable Views')),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // Title
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'ListView Example',
                style: TextStyle(fontSize: 18),
              ),
            ),

            // Horizontal ListView
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    width: 150,
                    margin: EdgeInsets.all(8),
                    color: Colors.teal[100 * (index + 2)],
                    child: Center(
                      child: Text('Card $index'),
                    ),
                  );
                },
              ),
            ),

            Divider(thickness: 2),

            // Grid Title
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'GridView Example',
                style: TextStyle(fontSize: 18),
              ),
            ),

            // GridView
            Container(
              height: 400,
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.primaries[index % Colors.primaries.length],
                    child: Center(
                      child: Text(
                        'Tile $index',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
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

# 🧪 5. Testing

## ✅ Steps

1. Run the app
2. Scroll horizontally in ListView
3. Observe GridView layout
4. Ensure smooth scrolling

---

## 📊 Expected Behavior

- ListView scrolls horizontally
- GridView displays items in 2 columns
- No overflow or rendering issues
- Smooth performance

---

# 📸 Screenshots Required

Include:
1. ListView scrolling  
2. GridView layout  
3. Combined screen  

---

# 🧠 Key Learnings

- ListView is used for linear scrolling layouts  
- GridView is used for structured layouts  
- `.builder()` improves performance  
- Scrollable widgets handle large data efficiently  
- Multiple scroll views can be combined using `SingleChildScrollView`  

---

# ⚠️ Common Mistakes

| Issue | Fix |
|------|-----|
| Overflow error | Wrap with SingleChildScrollView |
| Nested scrolling issue | Use `NeverScrollableScrollPhysics()` |
| Performance lag | Use `.builder()` |
| Items not visible | Set proper height |

---

# 🏁 Conclusion

This project demonstrates:
- Efficient scrolling using ListView and GridView  
- Dynamic UI building with builder methods  
- Combining multiple scrollable widgets in one screen  

These concepts are essential for building real-world apps like:
- E-commerce apps  
- Social media feeds  
- Dashboards  
