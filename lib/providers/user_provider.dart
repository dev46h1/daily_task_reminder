import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isHelper => _currentUser?.isHelper ?? false;

  Future<void> loadCurrentUser() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getUserProfile(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUser(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.updateUserProfile(user);
      if (success) {
        _currentUser = user;
        _error = null;
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

  Future<bool> toggleHelperStatus() async {
    if (_currentUser == null) return false;

    final updatedUser = _currentUser!.copyWith(
      isHelper: !_currentUser!.isHelper,
    );

    return await updateUser(updatedUser);
  }

  Future<bool> updateAvailability(bool isAvailable) async {
    if (_currentUser == null) return false;

    final updatedUser = _currentUser!.copyWith(
      isAvailable: isAvailable,
    );

    return await updateUser(updatedUser);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
