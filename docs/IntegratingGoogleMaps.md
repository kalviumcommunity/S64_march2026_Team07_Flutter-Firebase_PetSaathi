3. Getting Google Maps API Key

To use Google Maps, an API key is required.

Steps to Generate API Key
Go to Google Cloud Console
Navigate to APIs & Services
Open Credentials
Click Create Credentials
Select API Key
Enable Required APIs

Make sure the following APIs are enabled:

Maps SDK for Android
Maps SDK for iOS
Geocoding API (optional)
Places API (optional)

Copy the generated API key for later use.

Example:

AIzaSyXXXXXX-XXXXXX-XXXXXX
4. Platform Configuration
Android Configuration

Open the following file:

android/app/src/main/AndroidManifest.xml

Add the API key inside the <application> tag:

<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
Add Location Permission

If user location is needed, add:

<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>

This permission allows access to GPS location.

iOS Configuration

For iOS, open:

ios/Runner/AppDelegate.swift

Add:

GMSServices.provideAPIKey("YOUR_API_KEY_HERE")

Next, open:

ios/Runner/Info.plist

Add location permission description:

<key>NSLocationWhenInUseUsageDescription</key>
<string>This app requires location access to display maps.</string>

This is mandatory for iOS.

5. Displaying Google Map in Flutter

Below is the minimal code required to display a map.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map"),
      ),
      body: const GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194),
          zoom: 12,
        ),
      ),
    );
  }
}
Explanation of Code
GoogleMap Widget

This widget is used to display the map.

GoogleMap()
initialCameraPosition

This sets the starting view of the map.

initialCameraPosition: CameraPosition(
target

This defines the latitude and longitude.

target: LatLng(37.7749, -122.4194)

This points to San Francisco.

zoom

Controls how close the map appears.

zoom: 12

Higher value = closer zoom.

6. Enabling User Location

To show current user location:

GoogleMap(
  initialCameraPosition: const CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  ),
  myLocationEnabled: true,
  myLocationButtonEnabled: true,
)
Explanation
myLocationEnabled

Displays the blue dot for current location.

myLocationEnabled: true
myLocationButtonEnabled

Shows the location button on the map.

myLocationButtonEnabled: true

When clicked, it moves the camera to the user’s location.

7. Adding a Marker

Markers help point to specific locations.

Example:

GoogleMap(
  initialCameraPosition: const CameraPosition(
    target: LatLng(28.6139, 77.2090),
    zoom: 12,
  ),
  markers: {
    const Marker(
      markerId: MarkerId("delhi"),
      position: LatLng(28.6139, 77.2090),
      infoWindow: InfoWindow(
        title: "Marker in Delhi",
      ),
    ),
  },
)
Explanation of Marker
markerId

Unique ID for each marker.

markerId: MarkerId("delhi")
position

Location where marker appears.

position: LatLng(28.6139, 77.2090)

This represents New Delhi.

infoWindow

Popup text shown when user taps the marker.

infoWindow: InfoWindow(title: "Marker in Delhi")
8. Features Supported by Google Maps

Google Maps Flutter package supports:

Markers
Circles
Polygons
Polylines
Heatmaps
Camera movement
Custom map styles

These are useful in advanced projects.