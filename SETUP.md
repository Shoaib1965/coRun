# coRun Setup Guide

Since this repo was initialized without the Flutter SDK, the platform folders (`android/`, `ios/`, etc.) are missing. Follow these steps to get the app running.

## 1. Initialize Flutter Project

Run this command in the project root to generate the missing folders:

```bash
flutter create .
```

This will create `android/`, `ios/`, `web/`, etc.

## 2. Android Configuration

### Add Permissions
Open `android/app/src/main/AndroidManifest.xml` and add these permissions inside the `<manifest>` tag (above `<application>`):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### Add Google Maps Key
In the same file, inside the `<application>` tag, add:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

### Firebase Setup
1. Download `google-services.json` from Firebase Console.
2. Place it in `android/app/`.
3. Open `android/build.gradle` and add the Google Services classpath if needed (FlutterFire usually handles this via CLI, but manual check: `classpath 'com.google.gms:google-services:4.3.15'`).
4. Open `android/app/build.gradle` and add `apply plugin: 'com.google.gms.google-services'` at the bottom.
5. Set `minSdkVersion 21` (or higher) in `android/app/build.gradle`.

## 3. iOS Configuration

### Add Permissions
Open `ios/Runner/Info.plist` and add:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track your runs and claim territory.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to track your runs even when the app is in background.</string>
```

### Firebase Setup
1. Download `GoogleService-Info.plist` from Firebase Console.
2. Place it in `ios/Runner/` (drag and drop via Xcode is safest to ensure it's added to the target).

## 4. Run the App

```bash
flutter run
```
