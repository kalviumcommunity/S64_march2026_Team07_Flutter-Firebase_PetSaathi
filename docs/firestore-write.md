# 🚀 Flutter Firestore Write Operations (Add & Update Data)

## 📌 Overview
This project demonstrates how to perform **write operations in Cloud Firestore** using Flutter.

You will learn:
- How to add Firestore to your project  
- Different types of write operations  
- How to build a form UI for input  
- How to add and update data  
- Best practices for secure database writes  

---

# 🔧 1. Add Cloud Firestore to Project

## 🔹 Add Dependency

In `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cloud_firestore: ^5.0.0
```

---

## 🔹 Install Package

```bash
flutter pub get
```

---

## 🔹 Important

Make sure Firebase is initialized in `main.dart` before using Firestore.

---

# 📚 2. Firestore Write Operations

Firestore supports four main write operations:

---

## 🔹 a. Create / Add (Auto ID)

```dart
await FirebaseFirestore.instance
  .collection('tasks')
  .add({
    'title': 'Learn Flutter',
    'completed': false,
    'createdAt': Timestamp.now(),
  });
```

✔ Automatically generates a document ID  

---

## 🔹 b. Set (Custom ID)

```dart
await FirebaseFirestore.instance
  .collection('tasks')
  .doc('taskId123')
  .set({
    'title': 'New Task',
    'completed': false,
  });
```

✔ Creates or overwrites document  

---

## 🔹 c. Update (Modify Fields)

```dart
await FirebaseFirestore.instance
  .collection('tasks')
  .doc('taskId123')
  .update({
    'completed': true,
  });
```

✔ Updates specific fields only  

---

## 🔹 d. Delete (Optional)

```dart
await FirebaseFirestore.instance
  .collection('tasks')
  .doc('taskId123')
  .delete();
```

✔ Removes document  

---

# 🖥️ 3. Build UI for Data Input

## 🔹 Required Fields

- Title (TextField)  
- Description (TextField)  
- Submit Button  

---

## 🧾 Example UI

```dart
TextField(
  controller: _titleController,
  decoration: InputDecoration(labelText: 'Title'),
),

TextField(
  controller: _descController,
  decoration: InputDecoration(labelText: 'Description'),
),

ElevatedButton(
  onPressed: _addTask,
  child: Text('Add Task'),
)
```

---

## 🔹 Validation Rules

- Fields must not be empty  
- Trim extra spaces  
- Validate data types  

---

# ➕ 4. Add Data to Firestore

## 🔹 Add Function

```dart
Future<void> _addTask() async {
  final title = _titleController.text.trim();
  final desc = _descController.text.trim();

  if (title.isEmpty || desc.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill all fields')),
    );
    return;
  }

  await FirebaseFirestore.instance.collection('tasks').add({
    'title': title,
    'description': desc,
    'isCompleted': false,
    'createdAt': Timestamp.now(),
  });
}
```

---

## 🔹 What Happens?

- User inputs data  
- Data validated  
- New document created in Firestore  
- Stored in `tasks` collection  

---

# ✏️ 5. Update Data in Firestore

## 🔹 Add Edit Button

```dart
IconButton(
  icon: Icon(Icons.edit),
  onPressed: () => _updateTask(taskId),
)
```

---

## 🔹 Update Function

```dart
Future<void> _updateTask(String taskId) async {
  await FirebaseFirestore.instance
      .collection('tasks')
      .doc(taskId)
      .update({
        'title': 'Updated Title',
      });
}
```

---

## 🔹 What Happens?

- User triggers edit  
- Specific field updated  
- No full document overwrite  

---

# 🔐 6. Secure & Structured Writes

## 🔹 Best Practices

- ✅ Validate input before writing  
- ✅ Use correct data types  
- ✅ Add timestamps for tracking  
- ✅ Prefer `update()` over overwrite  
- ✅ Use merge when needed  

---

## 🔹 Merge Example

```dart
await FirebaseFirestore.instance
  .collection('tasks')
  .doc(taskId)
  .set(
    {'title': 'Updated'},
    SetOptions(merge: true),
  );
```

---

## 🔹 Security Tips

- Do NOT store sensitive data without rules  
- Use Firebase Security Rules  
- Restrict unauthorized access  

---

# 🧪 7. Testing Firestore Writes

## 🔹 Steps

1. Run the app  
2. Add a new task  
3. Open Firebase Console  
4. Verify new document  
5. Edit task  
6. Confirm update  
7. Refresh UI  

---

## 📊 Expected Output

- Task added successfully  
- Data visible in Firestore  
- Updates reflect instantly  
- No errors or crashes  

---

# 📸 Screenshots Required

Include:

1. Form UI  
2. Added task in app  
3. Firestore Console showing data  
4. Updated task  

---

# 🧠 Key Learnings

- Firestore supports multiple write operations  
- `.add()` creates new documents  
- `.update()` modifies specific fields  
- `.set()` can overwrite or merge  
- Validation is critical before writing  

---

# ⚠️ Common Mistakes

| Issue | Fix |
|------|-----|
| Empty fields | Add validation |
| Data overwritten | Use `update()` or merge |
| Firebase not initialized | Initialize in main.dart |
| Wrong data types | Use correct field types |

---

# 🏁 Conclusion

This project demonstrates:
- Writing data to Firestore  
- Updating existing records  
- Building form-based UI  
- Applying best practices  

Firestore write operations are essential for:
- Task management apps  
- User-generated content  
- Real-time applications  
