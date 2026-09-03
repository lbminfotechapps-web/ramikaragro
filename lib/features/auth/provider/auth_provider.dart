

import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final SecureStorage _secureStorage = SecureStorage.instance;

  bool _isLoggedIn = false;
  bool _isChecking = true;

  bool get isLoggedIn => _isLoggedIn;
  bool get isChecking => _isChecking;

  Future<void> checkLoginStatus() async {
    _isChecking = true;
    notifyListeners();

    try {
      final userData = await _secureStorage.getUserData();

      final userId = userData?['user_id']?.toString();

      if (userId != null && userId.isNotEmpty) {
        _isLoggedIn = true;
      } else {
        _isLoggedIn = false;
      }
    } catch (e) {
      debugPrint('Check login status error: $e');
      _isLoggedIn = false;
    }

    _isChecking = false;
    notifyListeners();
  }

  Future<void> login(Map<String, dynamic> userData) async {
    await _secureStorage.saveUserData(userData);

    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _secureStorage.deleteUserData();

    _isLoggedIn = false;
    notifyListeners();
  }
}