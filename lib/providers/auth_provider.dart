import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  UserModel? _userProfile;
  bool _isLoading = true;
  String? _error;
  String? _verificationId;

  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  String? get userId => _user?.uid;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        await loadUserProfile();
      } else {
        _userProfile = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> loadUserProfile() async {
    if (_user != null) {
      _userProfile = await _authService.getUserProfile(_user!.uid);
      notifyListeners();
    }
  }

  Future<bool> verifyPhoneNumber(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    bool success = false;

    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      codeSent: (String verificationId) {
        _verificationId = verificationId;
        _isLoading = false;
        success = true;
        notifyListeners();
      },
      verificationFailed: (String error) {
        _error = error;
        _isLoading = false;
        notifyListeners();
      },
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _isLoading = false;
          success = true;
          notifyListeners();
        } catch (e) {
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
        }
      },
    );

    return success;
  }

  Future<bool> verifyOTP(String otp) async {
    if (_verificationId == null) {
      _error = 'Verification ID not found';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithOTP(
        verificationId: _verificationId!,
        otp: otp,
      );

      if (credential != null) {
        _user = credential.user;
        
        // Check if user profile exists
        final exists = await _authService.userExists(_user!.uid);
        
        _isLoading = false;
        notifyListeners();
        return !exists; // Return true if new user (needs to complete profile)
      }

      _isLoading = false;
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createUserProfile(UserModel userModel) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.createUserProfile(userModel);
      if (success) {
        _userProfile = userModel;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserProfile(UserModel userModel) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.updateUserProfile(userModel);
      if (success) {
        _userProfile = userModel;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _userProfile = null;
      _verificationId = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
