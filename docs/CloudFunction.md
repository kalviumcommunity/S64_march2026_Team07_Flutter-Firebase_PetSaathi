Firebase Cloud Functions with Flutter – Documentation
Overview

This document explains how to set up and use Firebase Cloud Functions in a Flutter application. It covers the creation of callable functions, event-driven functions using Firestore triggers, deployment, and integration with the Flutter frontend.

Prerequisites

Ensure the following tools are installed:

Node.js (version 16 or later)
Firebase CLI
Flutter SDK
A configured Firebase project
1. Installing Firebase Tools

Install the Firebase CLI globally:

npm install -g firebase-tools

Authenticate with Firebase:

firebase login

Initialize Firebase Functions in your project directory:

firebase init functions

During initialization:

Select your Firebase project
Choose JavaScript or TypeScript
Allow installation of dependencies
2. Creating a Callable Cloud Function

Callable functions allow direct communication between the client (Flutter) and the backend.

Example (functions/index.js or index.ts):
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sayHello = functions.https.onCall((data, context) => {
  const name = data.name || "User";
  return { message: `Hello, ${name}!` };
});
Deployment

Deploy the function using:

firebase deploy --only functions
3. Calling the Function from Flutter
Add Dependency
dependencies:
  cloud_functions: ^5.0.0
Example Code
final callable = FirebaseFunctions.instance.httpsCallable('sayHello');
final result = await callable.call({'name': 'Alex'});

print(result.data['message']);
Expected Output
Hello, Alex!

The returned data can be displayed in the UI or used in application logic.

4. Creating an Event-Based Function (Firestore Trigger)

Event-based functions run automatically when changes occur in Firestore.

Example: Trigger on Document Creation
exports.newUserCreated = functions.firestore
  .document("users/{userId}")
  .onCreate((snap, context) => {
    const data = snap.data();
    console.log("New user created:", data);
    return null;
  });
Use Cases
Automatically generating user profile data
Sending notifications
Updating analytics
Validating or transforming input data
Testing Steps

Deploy the function:

firebase deploy --only functions
Create a new document in the users collection
Verify execution using logs
5. Viewing Logs

To monitor function execution:

Open Firebase Console
Navigate to Functions → Logs
Trigger the function (from Flutter or Firestore)
Check logs for:
Successful execution messages
Input data
Errors, if any

Logs are essential for debugging and verifying behavior.

6. Integrating Function Output into the Application

The output from Cloud Functions can be used in several ways:

In Flutter UI
Display response messages
Show confirmation dialogs
Trigger visual feedback such as animations
With Firestore
Store processed or computed data
Update collections dynamically
Example Use Cases
Displaying a greeting message after user input
Automatically updating UI based on backend processing
Synchronizing client-side actions with server-side logic