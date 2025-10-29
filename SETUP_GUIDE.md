# Helper App - Complete Setup Guide

This guide will walk you through setting up the Helper App from scratch, including Firebase configuration and running the app.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Firebase Setup](#firebase-setup)
3. [Project Setup](#project-setup)
4. [Running the App](#running-the-app)
5. [Testing](#testing)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software
- **Flutter SDK**: Version 3.0 or higher
  - Download from: https://flutter.dev/docs/get-started/install
  - Verify installation: `flutter doctor`
  
- **Android Studio** or **VS Code**
  - Android Studio: https://developer.android.com/studio
  - VS Code with Flutter extension
  
- **Git**: For version control
  - Download from: https://git-scm.com/downloads

### Required Accounts
- **Firebase Account**: Free tier is sufficient
  - Sign up at: https://firebase.google.com/

## Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `helper-app` (or your preferred name)
4. **Disable Google Analytics** (optional for MVP)
5. Click **"Create project"**
6. Wait for project creation to complete

### Step 2: Add Android App to Firebase

1. In Firebase Console, click the **Android icon** to add an Android app
2. Enter the following details:
   - **Android package name**: `com.example.helper_app`
   - **App nickname**: Helper App (optional)
   - **Debug signing certificate SHA-1**: Leave blank for now
3. Click **"Register app"**
4. **Download `google-services.json`**
5. Click **"Next"** through the remaining steps

### Step 3: Configure Firebase Authentication

1. In Firebase Console, go to **Authentication**
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Enable **"Phone"** authentication:
   - Click on "Phone"
   - Toggle to **Enable**
   - Click **"Save"**

#### Add Test Phone Numbers (for Development)

1. In Authentication → Sign-in method → Phone
2. Scroll to **"Phone numbers for testing"**
3. Add test numbers:
   - Phone: `+91 9999999999`
   - Code: `123456`
4. Click **"Add"**

### Step 4: Setup Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **"Create database"**
3. Select **"Start in test mode"** (for development)
4. Choose a location (select closest to your target users):
   - For India: `asia-south1` (Mumbai)
5. Click **"Enable"**

#### Configure Firestore Security Rules

1. Go to **Firestore Database** → **Rules** tab
2. Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId);
      allow delete: if isOwner(userId);
    }
    
    // Help requests collection
    match /help_requests/{requestId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && 
        (resource.data.seekerId == request.auth.uid || 
         resource.data.assignedHelperId == request.auth.uid);
      allow delete: if isAuthenticated() && 
        resource.data.seekerId == request.auth.uid;
    }
    
    // Sessions collection
    match /sessions/{sessionId} {
      allow read: if isAuthenticated() && 
        (resource.data.seekerId == request.auth.uid || 
         resource.data.helperId == request.auth.uid);
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && 
        (resource.data.seekerId == request.auth.uid || 
         resource.data.helperId == request.auth.uid);
    }
    
    // Reviews collection
    match /reviews/{reviewId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && 
        resource.data.reviewerId == request.auth.uid;
    }
    
    // Chats collection
    match /chats/{chatId} {
      allow read: if isAuthenticated() && 
        request.auth.uid in resource.data.participants;
      allow write: if isAuthenticated();
      
      match /messages/{messageId} {
        allow read: if isAuthenticated();
        allow create: if isAuthenticated();
      }
    }
  }
}
```

3. Click **"Publish"**

### Step 5: Setup Firebase Storage

1. In Firebase Console, go to **Storage**
2. Click **"Get started"**
3. Select **"Start in test mode"** (for development)
4. Click **"Next"** and **"Done"**

#### Configure Storage Security Rules

1. Go to **Storage** → **Rules** tab
2. Replace the default rules with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // User profile images
    match /users/{userId}/profile/{fileName} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024; // Max 5MB
    }
    
    // Help request images
    match /help_requests/{requestId}/{fileName} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated()
        && request.resource.size < 5 * 1024 * 1024; // Max 5MB
    }
    
    // Chat media
    match /chats/{chatId}/{fileName} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated()
        && request.resource.size < 10 * 1024 * 1024; // Max 10MB
    }
  }
}
```

3. Click **"Publish"**

## Project Setup

### Step 1: Clone/Download Project

```bash
# If using Git
git clone <repository-url>
cd helper_app

# Or download and extract the ZIP file
```

### Step 2: Add Firebase Configuration

1. Copy the `google-services.json` file you downloaded earlier
2. Place it in: `android/app/google-services.json`

### Step 3: Update Android Configuration

#### Update `android/app/build.gradle`:

```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"  // Add this line
}

android {
    namespace "com.example.helper_app"
    compileSdkVersion 34
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    defaultConfig {
        applicationId "com.example.helper_app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
        multiDexEnabled true  // Add this line
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'androidx.multidex:multidex:2.0.1'  // Add this line
}
```

#### Update `android/build.gradle`:

```gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.0'  // Add this line
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

#### Update `android/app/src/main/AndroidManifest.xml`:

Add these permissions inside the `<manifest>` tag:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### Step 4: Install Dependencies

```bash
flutter pub get
```

### Step 5: Verify Setup

```bash
flutter doctor
```

Ensure all checks pass. If there are issues, follow the suggested fixes.

## Running the App

### Option 1: Using Android Emulator

1. **Start Android Emulator**:
   - Open Android Studio
   - Go to Tools → Device Manager
   - Create a new virtual device (if not exists)
   - Start the emulator

2. **Run the app**:
   ```bash
   flutter run
   ```

### Option 2: Using Physical Device

1. **Enable Developer Options** on your Android device:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"

2. **Connect device** via USB

3. **Verify device connection**:
   ```bash
   flutter devices
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

### Build APK (for distribution)

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

## Testing

### Test User Flow

1. **Registration**:
   - Use test phone number: `+91 9999999999`
   - Enter OTP: `123456`
   - Complete profile registration

2. **Create Help Request**:
   - Navigate to home screen
   - Tap "Create Help Request"
   - Fill in details and submit

3. **Helper Mode**:
   - Toggle to helper mode in profile
   - Browse available requests
   - Express interest in requests

### Test with Real Phone Number

1. Remove test phone number from Firebase
2. Use your real phone number
3. You'll receive actual OTP via SMS

## Troubleshooting

### Common Issues

#### 1. Firebase not initialized

**Error**: `[core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solution**:
- Ensure `google-services.json` is in `android/app/`
- Verify Firebase initialization in `main.dart`
- Clean and rebuild: `flutter clean && flutter pub get`

#### 2. Phone Authentication not working

**Error**: `Invalid phone number format`

**Solution**:
- Ensure phone number includes country code: `+91XXXXXXXXXX`
- Check Firebase Console → Authentication → Phone is enabled
- Verify test phone numbers are added correctly

#### 3. Gradle build fails

**Error**: `Could not resolve com.google.gms:google-services`

**Solution**:
- Update `android/build.gradle` with correct classpath
- Sync Gradle files in Android Studio
- Run: `cd android && ./gradlew clean`

#### 4. Permission denied errors

**Error**: `Permission denied: CAMERA`

**Solution**:
- Add permissions to `AndroidManifest.xml`
- Request runtime permissions in app
- Check device settings → App permissions

#### 5. Firestore permission denied

**Error**: `PERMISSION_DENIED: Missing or insufficient permissions`

**Solution**:
- Check Firestore security rules
- Ensure user is authenticated
- Verify rules allow the operation

### Debug Mode

Enable debug logging:

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable Firebase debug logging
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(const HelperApp());
}
```

### Check Logs

```bash
# View Flutter logs
flutter logs

# View Android logs
adb logcat

# Filter Firebase logs
adb logcat | grep -i firebase
```

## Next Steps

After successful setup:

1. **Customize the app**:
   - Update app name in `pubspec.yaml`
   - Change package name if needed
   - Add app icon and splash screen

2. **Implement remaining features**:
   - Complete request workflow
   - Add payment integration
   - Implement messaging system
   - Add push notifications

3. **Prepare for production**:
   - Update Firebase rules for production
   - Enable Firebase Analytics
   - Setup Crashlytics
   - Configure app signing

## Support

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review Firebase Console for errors
3. Check Flutter and Firebase documentation
4. Create an issue in the repository

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Android Developer Guide](https://developer.android.com/)

---

**Happy Coding! 🚀**
