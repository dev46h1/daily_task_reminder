# Firebase Configuration Reference

This document contains all Firebase configuration files and rules needed for the Helper App.

## Table of Contents
1. [Firestore Security Rules](#firestore-security-rules)
2. [Storage Security Rules](#storage-security-rules)
3. [Firestore Indexes](#firestore-indexes)
4. [Firebase Configuration Files](#firebase-configuration-files)

## Firestore Security Rules

Save this as `firestore.rules` in your project root:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ==================== HELPER FUNCTIONS ====================
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isParticipant(participants) {
      return isAuthenticated() && request.auth.uid in participants;
    }
    
    // ==================== USERS COLLECTION ====================
    
    match /users/{userId} {
      // Anyone authenticated can read user profiles
      allow read: if isAuthenticated();
      
      // Users can only create/update/delete their own profile
      allow create: if isOwner(userId);
      allow update: if isOwner(userId);
      allow delete: if isOwner(userId);
    }
    
    // ==================== HELP REQUESTS COLLECTION ====================
    
    match /help_requests/{requestId} {
      // Anyone authenticated can read help requests
      allow read: if isAuthenticated();
      
      // Any authenticated user can create a help request
      allow create: if isAuthenticated() 
        && request.resource.data.seekerId == request.auth.uid;
      
      // Only seeker or assigned helper can update
      allow update: if isAuthenticated() && (
        resource.data.seekerId == request.auth.uid || 
        resource.data.assignedHelperId == request.auth.uid ||
        request.auth.uid in resource.data.interestedHelpers
      );
      
      // Only seeker can delete their request
      allow delete: if isAuthenticated() 
        && resource.data.seekerId == request.auth.uid;
    }
    
    // ==================== SESSIONS COLLECTION ====================
    
    match /sessions/{sessionId} {
      // Only participants can read session
      allow read: if isAuthenticated() && (
        resource.data.seekerId == request.auth.uid || 
        resource.data.helperId == request.auth.uid
      );
      
      // Any authenticated user can create a session
      allow create: if isAuthenticated() && (
        request.resource.data.seekerId == request.auth.uid ||
        request.resource.data.helperId == request.auth.uid
      );
      
      // Only participants can update session
      allow update: if isAuthenticated() && (
        resource.data.seekerId == request.auth.uid || 
        resource.data.helperId == request.auth.uid
      );
      
      // No one can delete sessions (for record keeping)
      allow delete: if false;
    }
    
    // ==================== REVIEWS COLLECTION ====================
    
    match /reviews/{reviewId} {
      // Anyone authenticated can read reviews
      allow read: if isAuthenticated();
      
      // Only authenticated users can create reviews
      allow create: if isAuthenticated() 
        && request.resource.data.reviewerId == request.auth.uid;
      
      // Only reviewer can update their review (for response)
      allow update: if isAuthenticated() && (
        resource.data.reviewerId == request.auth.uid ||
        resource.data.revieweeId == request.auth.uid
      );
      
      // No one can delete reviews (for integrity)
      allow delete: if false;
    }
    
    // ==================== CHATS COLLECTION ====================
    
    match /chats/{chatId} {
      // Only participants can read chat metadata
      allow read: if isAuthenticated() 
        && request.auth.uid in resource.data.participants;
      
      // Participants can create/update chat
      allow write: if isAuthenticated();
      
      // Messages subcollection
      match /messages/{messageId} {
        // Only chat participants can read messages
        allow read: if isAuthenticated();
        
        // Only authenticated users can create messages
        allow create: if isAuthenticated() 
          && request.resource.data.senderId == request.auth.uid;
        
        // Only sender or receiver can update (for read receipts)
        allow update: if isAuthenticated() && (
          resource.data.senderId == request.auth.uid ||
          resource.data.receiverId == request.auth.uid
        );
        
        // No one can delete messages
        allow delete: if false;
      }
    }
    
    // ==================== NOTIFICATIONS COLLECTION ====================
    
    match /notifications/{notificationId} {
      // Users can only read their own notifications
      allow read: if isAuthenticated() 
        && resource.data.userId == request.auth.uid;
      
      // System can create notifications
      allow create: if isAuthenticated();
      
      // Users can update their own notifications (mark as read)
      allow update: if isAuthenticated() 
        && resource.data.userId == request.auth.uid;
      
      // Users can delete their own notifications
      allow delete: if isAuthenticated() 
        && resource.data.userId == request.auth.uid;
    }
  }
}
```

## Storage Security Rules

Save this as `storage.rules` in your project root:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // ==================== HELPER FUNCTIONS ====================
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isValidImageSize() {
      return request.resource.size < 5 * 1024 * 1024; // 5MB
    }
    
    function isValidMediaSize() {
      return request.resource.size < 10 * 1024 * 1024; // 10MB
    }
    
    function isImage() {
      return request.resource.contentType.matches('image/.*');
    }
    
    // ==================== USER PROFILE IMAGES ====================
    
    match /users/{userId}/profile/{fileName} {
      // Anyone can read profile images
      allow read: if isAuthenticated();
      
      // Only owner can upload/update their profile image
      allow write: if isOwner(userId) 
        && isValidImageSize() 
        && isImage();
      
      // Only owner can delete their profile image
      allow delete: if isOwner(userId);
    }
    
    // ==================== HELP REQUEST IMAGES ====================
    
    match /help_requests/{requestId}/{fileName} {
      // Anyone authenticated can read request images
      allow read: if isAuthenticated();
      
      // Any authenticated user can upload request images
      allow write: if isAuthenticated() 
        && isValidImageSize() 
        && isImage();
      
      // Only request creator can delete images
      allow delete: if isAuthenticated();
    }
    
    // ==================== CHAT MEDIA ====================
    
    match /chats/{chatId}/{fileName} {
      // Only chat participants can read media
      allow read: if isAuthenticated();
      
      // Chat participants can upload media
      allow write: if isAuthenticated() 
        && isValidMediaSize();
      
      // Sender can delete their media
      allow delete: if isAuthenticated();
    }
    
    // ==================== VERIFICATION DOCUMENTS ====================
    
    match /verification/{userId}/{fileName} {
      // Only admin and owner can read verification documents
      allow read: if isOwner(userId);
      
      // Only owner can upload verification documents
      allow write: if isOwner(userId) 
        && isValidImageSize();
      
      // No one can delete verification documents
      allow delete: if false;
    }
  }
}
```

## Firestore Indexes

These indexes improve query performance. Add them in Firebase Console → Firestore → Indexes:

### Composite Indexes

1. **Help Requests by Status and Date**
   ```
   Collection: help_requests
   Fields:
   - status (Ascending)
   - createdAt (Descending)
   ```

2. **Help Requests by Category and Date**
   ```
   Collection: help_requests
   Fields:
   - category (Ascending)
   - status (Ascending)
   - createdAt (Descending)
   ```

3. **Sessions by User and Date**
   ```
   Collection: sessions
   Fields:
   - seekerId (Ascending)
   - createdAt (Descending)
   ```

4. **Sessions by Helper and Date**
   ```
   Collection: sessions
   Fields:
   - helperId (Ascending)
   - createdAt (Descending)
   ```

5. **Reviews by User**
   ```
   Collection: reviews
   Fields:
   - revieweeId (Ascending)
   - createdAt (Descending)
   ```

6. **Messages by Chat and Time**
   ```
   Collection: chats/{chatId}/messages
   Fields:
   - timestamp (Descending)
   ```

### Single Field Indexes

These are usually created automatically, but you can create them manually if needed:

- `help_requests.seekerId`
- `help_requests.assignedHelperId`
- `sessions.seekerId`
- `sessions.helperId`
- `reviews.revieweeId`
- `reviews.reviewerId`

## Firebase Configuration Files

### firebase.json

Create this file in your project root:

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "storage": {
    "rules": "storage.rules"
  }
}
```

### firestore.indexes.json

Create this file in your project root:

```json
{
  "indexes": [
    {
      "collectionGroup": "help_requests",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "help_requests",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "category",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "sessions",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "seekerId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "sessions",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "helperId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "reviews",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "revieweeId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
```

## Deploying Rules

### Using Firebase CLI

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase in your project**:
   ```bash
   firebase init
   ```
   - Select Firestore and Storage
   - Use existing project
   - Accept default file names

4. **Deploy rules**:
   ```bash
   # Deploy all rules
   firebase deploy
   
   # Deploy only Firestore rules
   firebase deploy --only firestore:rules
   
   # Deploy only Storage rules
   firebase deploy --only storage:rules
   
   # Deploy only indexes
   firebase deploy --only firestore:indexes
   ```

### Using Firebase Console

1. **Firestore Rules**:
   - Go to Firestore Database → Rules
   - Copy and paste the rules
   - Click "Publish"

2. **Storage Rules**:
   - Go to Storage → Rules
   - Copy and paste the rules
   - Click "Publish"

3. **Indexes**:
   - Go to Firestore Database → Indexes
   - Click "Add Index"
   - Add each index manually

## Testing Rules

### Firestore Rules Testing

Use the Firebase Console Rules Playground:

1. Go to Firestore → Rules
2. Click "Rules Playground"
3. Test different scenarios:

```javascript
// Test reading user profile
Location: /users/user123
Operation: get
Authenticated: Yes
Auth UID: user123
// Should: Allow

// Test reading another user's profile
Location: /users/user456
Operation: get
Authenticated: Yes
Auth UID: user123
// Should: Allow (profiles are public)

// Test updating another user's profile
Location: /users/user456
Operation: update
Authenticated: Yes
Auth UID: user123
// Should: Deny
```

### Storage Rules Testing

Use the Firebase Console Rules Playground:

1. Go to Storage → Rules
2. Click "Rules Playground"
3. Test different scenarios

## Production Considerations

### Before Going to Production

1. **Review Rules**:
   - Ensure no test mode rules remain
   - Verify all security checks are in place
   - Test edge cases

2. **Add Rate Limiting**:
   ```javascript
   // Example: Limit writes per user
   match /help_requests/{requestId} {
     allow create: if isAuthenticated() 
       && request.resource.data.seekerId == request.auth.uid
       && request.time < resource.data.lastRequest + duration.value(1, 'm');
   }
   ```

3. **Add Data Validation**:
   ```javascript
   // Example: Validate required fields
   allow create: if isAuthenticated() 
     && request.resource.data.keys().hasAll(['title', 'description', 'category'])
     && request.resource.data.title.size() > 0
     && request.resource.data.title.size() <= 100;
   ```

4. **Monitor Usage**:
   - Set up Firebase alerts
   - Monitor Firestore usage
   - Track Storage usage
   - Review security logs

## Troubleshooting

### Common Issues

1. **Permission Denied**:
   - Check if user is authenticated
   - Verify user ID matches
   - Review rule conditions

2. **Index Required**:
   - Create the suggested index
   - Wait for index to build (can take minutes)
   - Retry the query

3. **Rules Not Updating**:
   - Clear browser cache
   - Wait a few minutes for propagation
   - Verify rules were published

## Resources

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Storage Security Rules Documentation](https://firebase.google.com/docs/storage/security)
- [Firestore Indexes Documentation](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Firebase CLI Documentation](https://firebase.google.com/docs/cli)

---

**Last Updated**: October 29, 2025
