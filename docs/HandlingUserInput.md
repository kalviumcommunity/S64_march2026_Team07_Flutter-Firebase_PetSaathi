# User Input Form in Flutter (TextField, Form & Validation)

## 📌 Overview
This assignment demonstrates how to build a **user input form in Flutter** using `TextField`, `TextFormField`, `ElevatedButton`, and `Form` widgets. It focuses on collecting user input, validating data, and providing feedback through UI elements like error messages and SnackBars.

---

## 🎯 Objective

- Understand Flutter input widgets
- Build a form with multiple fields
- Implement validation logic
- Provide real-time user feedback
- Manage form state efficiently

---

## 🧠 Core Concepts

### 🔹 TextField

The `TextField` widget is used to capture user input.

#### Features:
- Accepts text input
- Supports keyboard types (email, number, etc.)
- Can be styled using `InputDecoration`

#### Example:

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Enter your name',
    border: OutlineInputBorder(),
  ),
);
```

---

### 🔹 ElevatedButton

Used to trigger actions like submitting a form.

#### Example:

```dart
ElevatedButton(
  onPressed: () {
    print('Button pressed!');
  },
  child: Text('Submit'),
);
```

---

### 🔹 Form & TextFormField

The `Form` widget groups multiple input fields and allows validation using a `GlobalKey`.

#### Features:
- Manages form state
- Validates inputs using `validator`
- Works with `TextFormField`

---

## 🏗️ Implementation

### 📁 File Structure

```
lib/
 └── screens/
      └── user_input_form.dart
```

---

## 📱 Form Description

The form includes:

- **Name Field**
- **Email Field**
- **Submit Button**

Validation ensures:
- Fields are not empty
- Email format is valid

---

## 💻 Complete Code

```dart
import 'package:flutter/material.dart';

class UserInputForm extends StatefulWidget {
  const UserInputForm({super.key});

  @override
  State<UserInputForm> createState() => _UserInputFormState();
}

class _UserInputFormState extends State<UserInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Input Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!value.contains('@')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Form Submitted Successfully!'),
                        ),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🔄 Validation & Feedback Flow

### ❌ When Validation Fails:
- Error message appears below the input field
- User is prompted to correct input

### ✅ When Validation Succeeds:
- SnackBar displays success message
- Data is considered valid

---

## 🧪 Testing & Verification

### ✅ Steps Performed

- Ran app on emulator/device
- Entered valid and invalid inputs
- Observed validation behavior

---

## 📸 Screenshots

### 1️⃣ Initial State
- Empty form fields

### 2️⃣ Validation Errors
- Empty name → Error message shown
- Invalid email → Error message shown

### 3️⃣ Success State
- Valid input → SnackBar displayed

*(Add screenshots here in your repo)*

---

## ⚙️ Key Observations

- `TextFormField` simplifies validation compared to `TextField`
- `Form` widget manages multiple inputs efficiently
- `GlobalKey<FormState>` helps control validation flow
- User feedback improves usability and experience

---

## 🤔 Reflection

### 🔹 Why is input validation important?

- Prevents incorrect or incomplete data
- Improves user experience
- Ensures data integrity
- Reduces backend errors

---

### 🔹 Difference between TextField and TextFormField

| Feature | TextField | TextFormField |
|--------|----------|--------------|
| Validation | ❌ No built-in | ✅ Built-in |
| Form Integration | ❌ | ✅ |
| Use Case | Simple input | Forms with validation |

---

### 🔹 How does form state management help?

- Centralized validation using `Form`
- Cleaner and structured code
- Easy to validate multiple fields at once
- Improves maintainability

---

## ⚠️ Common Issues & Fixes

| Issue | Solution |
|------|---------|
| Validation not working | Check `Form` key usage |
| No error messages | Ensure `validator` returns string |
| UI not updating | Use `setState` if needed |
| Controllers not disposed | Dispose in `dispose()` method |

---

## 🚀 Learning Outcomes

- Learned Flutter form handling
- Implemented input validation
- Improved UI/UX with feedback
- Understood state management in forms

---

## ✅ Conclusion

This assignment demonstrates how to build a structured and user-friendly input form in Flutter. By combining `TextFormField`, `Form`, and validation logic, we can ensure accurate data collection and enhance the overall user experience.

---

## 📌 Next Steps

- Add password fields with validation
- Implement form reset functionality
- Connect form to Firebase backend
- Use advanced validation libraries
