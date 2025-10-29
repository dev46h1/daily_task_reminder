# Helper App - Quick Start Guide

Get the Helper App running in **15 minutes**!

## Prerequisites Checklist

- [ ] Flutter SDK installed (`flutter --version`)
- [ ] Android Studio or VS Code installed
- [ ] Android device or emulator ready
- [ ] Firebase account created
- [ ] Git installed (optional)

## Step-by-Step Setup

### 1. Firebase Setup (5 minutes)

1. **Create Project**:
   - Go to https://console.firebase.google.com/
   - Click "Add project" → Name it "helper-app" → Create

2. **Add Android App**:
   - Click Android icon
   - Package name: `com.example.helper_app`
   - Download `google-services.json`

3. **Enable Phone Auth**:
   - Go to Authentication → Sign-in method
   - Enable "Phone"
   - Add test number: `+91 9999999999` with code `123456`

4. **Create Firestore**:
   - Go to Firestore Database
   - Click "Create database"
   - Select "Test mode"
   - Choose location (e.g., asia-south1)

5. **Create Storage**:
   - Go to Storage
   - Click "Get started"
   - Select "Test mode"

### 2. Project Setup (5 minutes)

1. **Get the code**:
   ```bash
   # If you have the code
   cd helper_app
   
   # Or clone from repository
   git clone <repo-url>
   cd helper_app
   ```

2. **Add Firebase config**:
   ```bash
   # Copy google-services.json to android/app/
   cp ~/Downloads/google-services.json android/app/
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Verify setup**:
   ```bash
   flutter doctor
   ```

### 3. Run the App (5 minutes)

1. **Start emulator** (or connect device):
   ```bash
   # List available devices
   flutter devices
   
   # Start emulator from Android Studio
   # Or connect physical device via USB
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

3. **Test the app**:
   - Enter phone: `+91 9999999999`
   - Enter OTP: `123456`
   - Complete registration
   - Explore the app!

## Quick Test Scenarios

### Test 1: User Registration
1. Launch app
2. Enter test phone number
3. Enter test OTP
4. Fill registration form
5. ✅ Should see home screen

### Test 2: Create Help Request
1. Tap "Create Help Request"
2. Fill in details
3. Submit request
4. ✅ Should see request in list

### Test 3: Helper Mode
1. Go to Profile
2. Toggle helper mode
3. Go to home
4. ✅ Should see available requests

## Common Issues & Quick Fixes

### Issue: "Firebase not initialized"
**Fix**: Ensure `google-services.json` is in `android/app/`

### Issue: "Phone auth not working"
**Fix**: Check test phone number is added in Firebase Console

### Issue: "Build failed"
**Fix**: Run `flutter clean && flutter pub get`

### Issue: "No devices found"
**Fix**: Start emulator or enable USB debugging on device

## Next Steps

After successful setup:

1. **Explore the code**:
   - Check `lib/models/` for data structures
   - Review `lib/services/` for business logic
   - Look at `lib/screens/` for UI

2. **Customize**:
   - Update app name in `pubspec.yaml`
   - Change colors in `main.dart` theme
   - Add your own categories

3. **Implement features**:
   - Complete request creation screen
   - Add chat functionality
   - Implement payment flow

## Resources

- 📖 [Full Setup Guide](SETUP_GUIDE.md)
- 🔥 [Firebase Configuration](FIREBASE_CONFIG.md)
- 📋 [Project Summary](PROJECT_SUMMARY.md)
- 📚 [README](README.md)

## Need Help?

- Check [Troubleshooting](SETUP_GUIDE.md#troubleshooting)
- Review [Firebase Console](https://console.firebase.google.com/)
- Run `flutter doctor -v` for diagnostics

---

**Happy Coding! 🚀**

Time to complete: ~15 minutes
