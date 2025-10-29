import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with phone number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
    required Function(PhoneAuthCredential credential) verificationCompleted,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: (FirebaseAuthException e) {
          verificationFailed(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('Auto retrieval timeout');
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      verificationFailed(e.toString());
    }
  }

  // Verify OTP and sign in
  Future<UserCredential?> signInWithOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error signing in with OTP: $e');
      rethrow;
    }
  }

  // Create user profile in Firestore
  Future<bool> createUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
      debugPrint('✅ User profile created: ${user.id}');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating user profile: $e');
      return false;
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
      debugPrint('✅ User profile updated: ${user.id}');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating user profile: $e');
      return false;
    }
  }

  // Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('❌ Error checking user existence: $e');
      return false;
    }
  }

  // Update last active timestamp
  Future<void> updateLastActive() async {
    if (currentUserId != null) {
      try {
        await _firestore.collection('users').doc(currentUserId).update({
          'lastActive': Timestamp.now(),
        });
      } catch (e) {
        debugPrint('❌ Error updating last active: $e');
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('✅ User signed out');
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
      rethrow;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      if (currentUserId != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(currentUserId).delete();
        
        // Delete Firebase Auth account
        await currentUser?.delete();
        
        debugPrint('✅ Account deleted');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting account: $e');
      return false;
    }
  }
}
