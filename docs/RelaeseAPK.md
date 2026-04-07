# Assignment: Preparing and Building a Release APK or App Bundle for Production in Flutter

## Overview
Once a Flutter application is fully developed and tested, the next important step is preparing it for production deployment.

For Android applications, production builds are generally generated in two formats:

- **APK (Android Package Kit)**  
- **AAB (Android App Bundle)**  

An **APK** is mainly used for manual installation, internal testing, or direct sharing.

An **AAB** is the modern standard format required by the **Google Play Store** for publishing applications.

A production build must be:

- signed
- optimized
- secure
- free from debug configurations

This assignment explains the complete process of generating a release build in Flutter.

---

## Objective
The objective of this assignment is to learn how to:

- generate a keystore
- securely store signing credentials
- configure Gradle signing
- build a release APK
- build an app bundle
- verify production builds
- handle common release issues

By the end of this assignment, the Flutter app will be ready for production deployment.

---

## 1. Why Release Builds Matter
Release builds are necessary for production use.

### Importance of Release Builds

### 1. Required for Play Store
Applications must be uploaded as signed release builds.

Google Play requires **AAB** format.

---

### 2. Better Performance
Release builds are optimized and run faster than debug builds.

They remove unnecessary debugging overhead.

---

### 3. Security
Signed builds verify ownership and prevent app tampering.

This ensures trust and authenticity.

---

### 4. Removes Debug Features
Release builds remove:

- debug banners
- logs
- development flags
- testing configurations

---

### 5. Better User Experience
Production builds are smoother, faster, and safer.

---

## 2. Generating a Keystore (Signing Key)
A keystore is required for signing the app.

It acts as the app’s digital identity.

---

## Command to Generate Keystore
Open terminal inside project folder and run:

```bash id="keystorecmd"
keytool -genkey -v -keystore app-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

Explanation of Command
keytool

Java utility used for generating keys.

-keystore

Defines the file name.

app-release-key.jks
-keyalg RSA

Uses RSA encryption algorithm.

-keysize 2048

Defines key strength.

-validity 10000

Specifies validity period in days.

-alias upload

Sets the key alias name.

Information Required

While generating the keystore, terminal will ask for:

full name
organizational unit
city
state
country code
password
Store the Keystore

Move the generated file inside:

android/app/app-release-key.jks
3. Storing Keystore Credentials Securely

Credentials should never be hardcoded inside the code.

Instead create:

android/key.properties
Add the Following
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload
storeFile=app-release-key.jks
Explanation
storePassword

Password for keystore file.

keyPassword

Password for key alias.