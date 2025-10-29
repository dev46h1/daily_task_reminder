import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/help_request_model.dart';
import '../models/session_model.dart';
import '../models/review_model.dart';
import '../models/message_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== HELP REQUESTS ====================

  // Create help request
  Future<String?> createHelpRequest(HelpRequestModel request) async {
    try {
      final docRef = await _firestore.collection('help_requests').add(request.toMap());
      await docRef.update({'id': docRef.id});
      debugPrint('✅ Help request created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating help request: $e');
      return null;
    }
  }

  // Get help request by ID
  Future<HelpRequestModel?> getHelpRequest(String requestId) async {
    try {
      final doc = await _firestore.collection('help_requests').doc(requestId).get();
      if (doc.exists) {
        return HelpRequestModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting help request: $e');
      return null;
    }
  }

  // Get help requests by seeker
  Stream<List<HelpRequestModel>> getHelpRequestsBySeeker(String seekerId) {
    return _firestore
        .collection('help_requests')
        .where('seekerId', isEqualTo: seekerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HelpRequestModel.fromMap(doc.data()))
            .toList());
  }

  // Get available help requests (for helpers)
  Stream<List<HelpRequestModel>> getAvailableHelpRequests({
    List<String>? categories,
    double? maxDistance,
    double? userLat,
    double? userLng,
  }) {
    Query query = _firestore
        .collection('help_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(50);

    return query.snapshots().map((snapshot) {
      var requests = snapshot.docs
          .map((doc) => HelpRequestModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter by categories if provided
      if (categories != null && categories.isNotEmpty) {
        requests = requests.where((r) => 
          categories.contains(r.category.toString().split('.').last)
        ).toList();
      }

      // Filter by distance if provided
      if (maxDistance != null && userLat != null && userLng != null) {
        requests = requests.where((r) {
          final distance = _calculateDistance(
            userLat, userLng, r.latitude, r.longitude
          );
          return distance <= maxDistance;
        }).toList();
      }

      return requests;
    });
  }

  // Update help request
  Future<bool> updateHelpRequest(HelpRequestModel request) async {
    try {
      await _firestore
          .collection('help_requests')
          .doc(request.id)
          .update(request.toMap());
      debugPrint('✅ Help request updated: ${request.id}');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating help request: $e');
      return false;
    }
  }

  // Add interested helper
  Future<bool> addInterestedHelper(String requestId, String helperId) async {
    try {
      await _firestore.collection('help_requests').doc(requestId).update({
        'interestedHelpers': FieldValue.arrayUnion([helperId]),
        'status': 'interested',
      });
      debugPrint('✅ Helper added to interested list');
      return true;
    } catch (e) {
      debugPrint('❌ Error adding interested helper: $e');
      return false;
    }
  }

  // Assign helper to request
  Future<bool> assignHelper(String requestId, String helperId, String helperName) async {
    try {
      await _firestore.collection('help_requests').doc(requestId).update({
        'assignedHelperId': helperId,
        'assignedHelperName': helperName,
        'status': 'assigned',
        'assignedAt': Timestamp.now(),
      });
      debugPrint('✅ Helper assigned to request');
      return true;
    } catch (e) {
      debugPrint('❌ Error assigning helper: $e');
      return false;
    }
  }

  // ==================== SESSIONS ====================

  // Create session
  Future<String?> createSession(SessionModel session) async {
    try {
      final docRef = await _firestore.collection('sessions').add(session.toMap());
      await docRef.update({'id': docRef.id});
      debugPrint('✅ Session created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating session: $e');
      return null;
    }
  }

  // Get session by ID
  Future<SessionModel?> getSession(String sessionId) async {
    try {
      final doc = await _firestore.collection('sessions').doc(sessionId).get();
      if (doc.exists) {
        return SessionModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting session: $e');
      return null;
    }
  }

  // Get sessions by user
  Stream<List<SessionModel>> getSessionsByUser(String userId) {
    return _firestore
        .collection('sessions')
        .where('seekerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromMap(doc.data()))
            .toList());
  }

  // Get sessions by helper
  Stream<List<SessionModel>> getSessionsByHelper(String helperId) {
    return _firestore
        .collection('sessions')
        .where('helperId', isEqualTo: helperId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromMap(doc.data()))
            .toList());
  }

  // Update session
  Future<bool> updateSession(SessionModel session) async {
    try {
      await _firestore
          .collection('sessions')
          .doc(session.id)
          .update(session.toMap());
      debugPrint('✅ Session updated: ${session.id}');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating session: $e');
      return false;
    }
  }

  // ==================== REVIEWS ====================

  // Create review
  Future<String?> createReview(ReviewModel review) async {
    try {
      final docRef = await _firestore.collection('reviews').add(review.toMap());
      await docRef.update({'id': docRef.id});
      
      // Update user ratings
      await _updateUserRating(review.revieweeId);
      
      debugPrint('✅ Review created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating review: $e');
      return null;
    }
  }

  // Get reviews for user
  Stream<List<ReviewModel>> getReviewsForUser(String userId) {
    return _firestore
        .collection('reviews')
        .where('revieweeId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data()))
            .toList());
  }

  // Update user rating
  Future<void> _updateUserRating(String userId) async {
    try {
      final reviews = await _firestore
          .collection('reviews')
          .where('revieweeId', isEqualTo: userId)
          .get();

      if (reviews.docs.isNotEmpty) {
        double totalRating = 0;
        for (var doc in reviews.docs) {
          totalRating += (doc.data()['overallRating'] ?? 0.0);
        }
        double avgRating = totalRating / reviews.docs.length;

        await _firestore.collection('users').doc(userId).update({
          'rating': avgRating,
          'totalReviews': reviews.docs.length,
        });
      }
    } catch (e) {
      debugPrint('❌ Error updating user rating: $e');
    }
  }

  // ==================== MESSAGES ====================

  // Send message
  Future<String?> sendMessage(MessageModel message) async {
    try {
      final docRef = await _firestore
          .collection('chats')
          .doc(message.chatId)
          .collection('messages')
          .add(message.toMap());
      
      await docRef.update({'id': docRef.id});
      
      // Update chat metadata
      await _firestore.collection('chats').doc(message.chatId).set({
        'participants': [message.senderId, message.receiverId],
        'lastMessage': message.content,
        'lastMessageTime': message.timestamp,
        'lastMessageSender': message.senderId,
      }, SetOptions(merge: true));
      
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      return null;
    }
  }

  // Get messages stream
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  // Mark message as read
  Future<void> markMessageAsRead(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'isRead': true,
        'readAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('❌ Error marking message as read: $e');
    }
  }

  // ==================== UTILITY FUNCTIONS ====================

  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = (dLat / 2).sin() * (dLat / 2).sin() +
        _degreesToRadians(lat1).cos() *
            _degreesToRadians(lat2).cos() *
            (dLon / 2).sin() *
            (dLon / 2).sin();
    
    double c = 2 * (a.sqrt()).asin();
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}
