# Assignment: Creating Themed UIs Using Dark Mode and Dynamic Colors in Flutter

## Overview
Modern mobile applications are expected to support **light mode**, **dark mode**, and **dynamic color themes**. These features improve user experience, accessibility, and application design consistency.

Dark mode has become a standard feature in production-ready applications because it helps in:

- reducing eye strain
- improving readability in low-light environments
- saving battery on OLED screens
- enhancing visual aesthetics

Flutter provides a powerful and flexible theming system that allows developers to define themes globally and switch them dynamically during runtime.

This assignment explains how to create themed UIs in Flutter using:

- Light Theme
- Dark Theme
- Dynamic Theme Switching
- Theme Persistence
- Material 3 Dynamic Colors

---

## Objective
The objective of this assignment is to learn how to:

- apply themes globally in Flutter
- create custom light and dark themes
- switch themes dynamically
- persist theme preferences
- use Material 3 dynamic colors

By the end of this assignment, the app will support full theme customization.

---

## 1. Why Theming Matters
Theming is an important part of modern application design.

### Key Benefits

### 1. Improves User Experience
Users can choose the theme according to their preference.

Example:
- light mode for daytime
- dark mode for nighttime

---

### 2. Accessibility
Dark mode improves readability in low-light environments and reduces eye strain.

---

### 3. Battery Optimization
Dark themes consume less battery on OLED and AMOLED screens.

---

### 4. Brand Consistency
Themes help maintain a consistent brand color palette across the app.

---

### 5. Production-Ready Feel
Applications with proper theming feel polished and professional.

---

## 2. Setting Up Basic Theming in Flutter
Themes are usually applied inside `MaterialApp`.

Example:

```dart id="m3v8q1"
MaterialApp(
  theme: ThemeData.light(),
  darkTheme: ThemeData.dark(),
  themeMode: ThemeMode.system,
  home: const HomeScreen(),
);

Explanation
theme

Defines the light theme.

theme: ThemeData.light()
darkTheme

Defines the dark theme.

darkTheme: ThemeData.dark()
themeMode

Controls which theme should be active.

themeMode: ThemeMode.system
ThemeMode Options
ThemeMode.system

Follows the device’s system settings.

ThemeMode.system

If the device is in dark mode, app uses dark theme.

ThemeMode.light

Forces light mode.

ThemeMode.light
ThemeMode.dark

Forces dark mode.

ThemeMode.dark
3. Creating Custom Light and Dark Themes

Instead of default themes, custom themes can be created.

Light Theme Example
final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
);
Explanation
brightness

Defines theme type.

Brightness.light
primaryColor

Main color of the app.

Colors.blue
scaffoldBackgroundColor

Sets page background.

Colors.white
Dark Theme Example
final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.teal,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.tealAccent,
  ),
);
Explanation

Dark theme uses darker colors for better night viewing.

4. Dynamic Theme Switching Using Provider

Theme switching is usually handled using state management.

Create Theme State Class
import 'package:flutter/material.dart';

class ThemeState with ChangeNotifier {
  ThemeMode mode = ThemeMode.system;

  void toggleTheme(bool isDark) {
    mode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
Explanation
mode

Stores current theme mode.

ThemeMode mode = ThemeMode.system;
toggleTheme()

Changes theme dynamically.

void toggleTheme(bool isDark)
notifyListeners()

Rebuilds UI immediately.

notifyListeners();

This is required for instant updates.

5. Applying Theme in MaterialApp
MaterialApp(
  theme: lightTheme,
  darkTheme: darkTheme,
  themeMode: context.watch<ThemeState>().mode,
)
Explanation

watch() listens for theme changes.

Whenever theme state updates, UI rebuilds automatically.

6. Theme Toggle UI

A Switch widget is commonly used.

Switch(
  value: context.watch<ThemeState>().mode == ThemeMode.dark,
  onChanged: (value) {
    context.read<ThemeState>().toggleTheme(value);
  },
)
Explanation
value

Checks whether dark mode is active.

mode == ThemeMode.dark
onChanged

Runs when user toggles switch.

toggleTheme(value)

This changes the theme instantly.

7. Persisting Theme Selection

It is recommended to save user preference.

This ensures theme remains the same after app restart.

Using SharedPreferences

Add dependency:

dependencies:
  shared_preferences: ^latest
Save Theme
final prefs = await SharedPreferences.getInstance();
await prefs.setBool("isDark", value);
Load Saved Theme
final isDark = prefs.getBool("isDark") ?? false;
themeState.toggleTheme(isDark);