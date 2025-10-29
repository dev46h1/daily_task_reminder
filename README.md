# Helper App - Peer-to-Peer Assistance Platform

A Flutter-based mobile application that connects individuals who need help with those willing to provide assistance across a wide spectrum of needs - from physical tasks to emotional support. Built as a zero-cost MVP using Firebase (free tier) for backend services.

## 🌟 Features

### Core Functionality
- **Dual Role System**: Users can seamlessly switch between seeking help and providing help
- **Phone Authentication**: Secure OTP-based login using Firebase Auth
- **Help Request Management**: Create, browse, and manage help requests
- **Real-time Matching**: Helpers discover relevant requests based on categories and location
- **Tip-Based Payment**: Flexible, satisfaction-based compensation model
- **"I Owe You One" Requests**: Non-monetary help requests for community building
- **Rating & Review System**: Dual review system for accountability
- **In-App Messaging**: Secure communication between users
- **Session Tracking**: Monitor help sessions from start to completion
- **Safety Features**: Emergency SOS, location sharing, and check-ins

### Help Categories
1. **Physical Assistance**: Moving, repairs, cleaning, gardening
2. **Decision Support**: Shopping assistance, styling, product selection
3. **Emotional Support**: Companionship, listening, grief support
4. **Skill-Based Help**: Minor repairs, tech help, cooking, tutoring
5. **Errands & Tasks**: Grocery shopping, transportation, appointments

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter 3.0+
- **Backend**: Firebase (Firestore, Auth, Storage)
- **State Management**: Provider
- **Authentication**: Firebase Phone Auth
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **Maps**: Google Maps Flutter

### Project Structure
```
lib/
├── models/              # Data models
│   ├── user_model.dart
│   ├── help_request_model.dart
│   ├── session_model.dart
│   ├── review_model.dart
│   └── message_model.dart
├── providers/           # State management
│   ├── auth_provider.dart
│   └── user_provider.dart
├── services/            # Business logic
│   ├── auth_service.dart
│   └── firestore_service.dart
├── screens/             # UI screens
│   ├── auth/           # Authentication screens
│   ├── home/           # Home screens
│   ├── requests/       # Request management
│   └── profile/        # User profile
└── main.dart           # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Android Studio / VS Code
- Firebase account (free tier)
- Android device or emulator

### Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add Project"
   - Enter project name: "helper-app"
   - Disable Google Analytics (optional for MVP)

2. **Add Android App**
   - Click "Add app" → Android icon
   - Package name: `com.example.helper_app` (or your custom package)
   - Download `google-services.json`
   - Place it in `android/app/` directory

3. **Enable Authentication**
   - Go to Authentication → Sign-in method
   - Enable "Phone" authentication
   - Add test phone numbers if needed (for development)

4. **Setup Firestore Database**
   - Go to Firestore Database
   - Click "Create database"
   - Start in **test mode** (for development)
   - Choose a location close to your users

5. **Setup Firebase Storage**
   - Go to Storage
   - Click "Get started"
   - Start in **test mode** (for development)

6. **Configure Security Rules**

   **Firestore Rules** (`firestore.rules`):
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users collection
       match /users/{userId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Help requests collection
       match /help_requests/{requestId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
         allow update: if request.auth != null && 
           (resource.data.seekerId == request.auth.uid || 
            resource.data.assignedHelperId == request.auth.uid);
         allow delete: if request.auth != null && 
           resource.data.seekerId == request.auth.uid;
       }
       
       // Sessions collection
       match /sessions/{sessionId} {
         allow read: if request.auth != null && 
           (resource.data.seekerId == request.auth.uid || 
            resource.data.helperId == request.auth.uid);
         allow write: if request.auth != null && 
           (resource.data.seekerId == request.auth.uid || 
            resource.data.helperId == request.auth.uid);
       }
       
       // Reviews collection
       match /reviews/{reviewId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
       }
       
       // Chats collection
       match /chats/{chatId} {
         allow read, write: if request.auth != null && 
           request.auth.uid in resource.data.participants;
         
         match /messages/{messageId} {
           allow read, write: if request.auth != null;
         }
       }
     }
   }
   ```

   **Storage Rules** (`storage.rules`):
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /users/{userId}/{allPaths=**} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && request.auth.uid == userId;
       }
       
       match /help_requests/{requestId}/{allPaths=**} {
         allow read: if request.auth != null;
         allow write: if request.auth != null;
       }
     }
   }
   ```

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd helper_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Ensure `google-services.json` is in `android/app/`
   - Update `android/app/build.gradle` if needed

4. **Run the app**
   ```bash
   flutter run
   ```

### Android Configuration

Update `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.example.helper_app"
        minSdkVersion 21
        targetSdkVersion 34
        multiDexEnabled true
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}
```

Add to `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Add to `android/app/build.gradle` (at the bottom):
```gradle
apply plugin: 'com.google.gms.google-services'
```

### Permissions

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

## 📱 Usage

### For Help Seekers
1. **Sign Up**: Register with phone number and complete profile
2. **Create Request**: Tap "Create Help Request" and fill in details
3. **Review Helpers**: View interested helpers and select one
4. **Track Session**: Monitor help session in real-time
5. **Pay & Review**: Tip the helper and leave a review

### For Helpers
1. **Register as Helper**: Complete enhanced verification
2. **Set Availability**: Toggle availability status
3. **Browse Requests**: View available help requests
4. **Express Interest**: Tap "I Can Help" on relevant requests
5. **Complete Help**: Provide assistance and receive tips

## 🔐 Security Features

- **Phone Authentication**: Secure OTP-based login
- **User Verification**: Multi-level verification system
- **Data Encryption**: Firebase handles encryption at rest and in transit
- **Privacy Controls**: Users control profile visibility
- **Emergency SOS**: Quick access to emergency services
- **Session Monitoring**: Real-time tracking and check-ins

## 💰 Zero-Cost MVP Strategy

### Firebase Free Tier Limits
- **Authentication**: 10K verifications/month
- **Firestore**: 50K reads, 20K writes, 20K deletes per day
- **Storage**: 5GB total, 1GB/day downloads
- **Hosting**: 10GB/month bandwidth

### Cost Optimization
- Use Firestore queries efficiently
- Implement pagination for large lists
- Cache data locally when possible
- Compress images before upload
- Use Firebase Storage only for essential media

## 🚧 Roadmap

### Phase 1: MVP (Current)
- [x] User authentication
- [x] Basic profile management
- [x] Help request creation
- [x] Helper discovery
- [x] Basic messaging
- [ ] Complete request workflow
- [ ] Payment integration (mock)
- [ ] Review system

### Phase 2: Enhancement
- [ ] Advanced search and filters
- [ ] Voice/video calling
- [ ] Group help requests
- [ ] Recurring help scheduling
- [ ] Push notifications
- [ ] Analytics dashboard

### Phase 3: Scale
- [ ] Payment gateway integration
- [ ] Background checks
- [ ] Insurance partnerships
- [ ] Corporate programs
- [ ] Multi-language support
- [ ] iOS version

## 🤝 Contributing

This is an MVP project. Contributions are welcome!

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 📞 Support

For issues and questions:
- Create an issue in the repository
- Email: support@helperapp.com (placeholder)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for free backend services
- Open source community for packages used

---

**Built with ❤️ using Flutter and Firebase**

**Note**: This is an MVP implementation. For production use, implement proper error handling, testing, monitoring, and security measures.
