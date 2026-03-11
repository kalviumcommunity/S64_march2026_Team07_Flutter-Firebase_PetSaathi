# Pet Saathi 🐕

Pet Saathi is a mobile application built with **Flutter and Firebase** that connects pet owners with trusted dog walkers and caregivers. The platform helps pet owners easily find, book, and monitor walkers while ensuring transparency and trust through verification, real-time updates, and reviews.

---

# Problem Statement

Pet owners in cities often struggle to find **reliable dog walkers or pet caregivers**. Most existing options rely on informal networks or local contacts, which lack:

- Identity verification
- Real-time updates
- Secure booking systems
- Trust indicators

This creates anxiety for pet owners and limits access to dependable pet care.

---

# Solution

Pet Saathi provides a **mobile-first platform** that enables:

- Discovery of nearby verified dog walkers
- Secure booking of pet walking services
- Real-time monitoring of walks
- Photo updates during pet walks
- Ratings and reviews for caregivers

The goal is to create a **trusted ecosystem for pet care services**.

---

# Tech Stack

Frontend:
- Flutter

Backend:
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Realtime Database (for live tracking)

Tools:
- GitHub (Version Control)
- GitHub Actions (CI/CD)
- Android Studio / VS Code

---

# App Architecture

The app follows a **widget-based architecture** using Flutter’s reactive UI model.

Core concepts used:

- StatelessWidget for static UI
- StatefulWidget for dynamic UI
- Efficient widget tree updates using setState()
- Firestore for real-time database operations

---

# Core Features

## Authentication
- User Sign Up
- User Login
- Role Selection (Pet Owner / Walker)
- Secure Firebase Authentication

## Pet Owner Features
- Create and manage pet profiles
- Discover nearby walkers
- View walker profiles
- Send booking requests
- Track walk progress
- View walk history

## Walker Features
- View booking requests
- Accept or reject requests
- Start and end walks
- Upload pet photo updates
- View earnings and completed walks

## Monitoring & Trust
- Real-time walk tracking
- Photo updates during walks
- Ratings and reviews
- Verified walker profiles

---

# App Screens

### General Screens
- Splash Screen
- Login / Signup
- Profile Page
- Settings Page

### Pet Owner Screens
- Home Dashboard
- Walker Discovery Page
- Walker Profile
- Booking Screen
- Walk Tracking Screen
- Pet Profile

### Walker Screens
- Walker Dashboard
- Booking Requests
- Active Walk Screen
- Earnings Page

---

# Firebase Database Structure

Example collections:

```
users
pets
walkers
bookings
reviews
walk_sessions
```

Example booking document:

```
booking_id
owner_id
walker_id
pet_id
status
start_time
end_time
price
```

---

# MVP Scope

The MVP focuses on delivering the **core functionality required for a working pet walking platform**.

Included in MVP:

- Firebase Authentication
- Pet profile creation
- Walker discovery
- Booking system
- Walk start/end tracking
- Photo updates
- Firestore database integration
- Functional Flutter UI
- APK build for demo

Not included in MVP:

- Payment gateway
- Push notifications
- AI pet analytics
- Vet appointment booking

---

# Installation

Clone the repository:

```
git clone https://github.com/your-repo/pet-saathi.git
```

Navigate to the project:

```
cd pet-saathi
```

Install dependencies:

```
flutter pub get
```

Run the application:

```
flutter run
```

---

# Testing

Testing strategies include:

- Flutter widget testing
- Manual testing for authentication flows
- CRUD operation testing with Firestore
- UI responsiveness testing on multiple devices

---

# Deployment

- Code hosted on GitHub
- CI/CD managed through GitHub Actions
- APK builds generated for demo and testing
- APK shared via Google Drive

---

# Success Criteria

The project will be considered successful if:

- All MVP features are functional
- Firebase Auth and Firestore are integrated
- The app builds successfully
- Core user flows work (signup → booking → walk tracking)
- The application is demo-ready

---

# Future Enhancements

Possible improvements:

- Payment integration
- Push notifications
- AI-based pet activity reports
- Vet consultation booking
- Subscription plans
- Smart collar integration

---

# Contributors

Team Pet Saathi

- Flutter Development
- Firebase Backend
- UI/UX Design
- Testing & Deployment

---

# License

This project is developed for educational purposes as part of a **mobile engineering sprint project using Flutter and Firebase**.