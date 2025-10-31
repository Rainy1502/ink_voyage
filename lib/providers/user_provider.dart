import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  static const String _userKey = 'user';
  static const String _isLoggedInKey = 'isLoggedIn';

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  // Initialize and load user from storage
  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool? loggedIn = prefs.getBool(_isLoggedInKey);
      final String? userJson = prefs.getString(_userKey);

      if (loggedIn == true && userJson != null) {
        final Map<String, dynamic> userMap = json.decode(userJson);
        _user = User.fromMap(userMap);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  // Save user to storage
  Future<void> _saveUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_user != null) {
        final String userJson = json.encode(_user!.toMap());
        await prefs.setString(_userKey, userJson);
        await prefs.setBool(_isLoggedInKey, true);
      }
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  // Register new user
  Future<bool> register(String name, String email, String password) async {
    try {
      // In a real app, you would validate with a backend
      // For now, we'll just create a local user
      _user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        joinedDate: DateTime.now(),
      );
      notifyListeners();
      await _saveUser();
      return true;
    } catch (e) {
      debugPrint('Error registering user: $e');
      return false;
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    try {
      // In a real app, you would validate with a backend
      // For now, we'll check if a user exists in storage
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final Map<String, dynamic> userMap = json.decode(userJson);
        final storedEmail = userMap['email'] as String;

        if (storedEmail == email) {
          _user = User.fromMap(userMap);
          await prefs.setBool(_isLoggedInKey, true);
          notifyListeners();
          return true;
        }
      }

      // If no user found, return false
      return false;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, false);
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? profileImageUrl,
  }) async {
    if (_user != null) {
      _user = _user!.copyWith(
        name: name ?? _user!.name,
        email: email ?? _user!.email,
        profileImageUrl: profileImageUrl ?? _user!.profileImageUrl,
      );
      notifyListeners();
      await _saveUser();
    }
  }

  // Check if email exists (for registration validation)
  Future<bool> emailExists(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final Map<String, dynamic> userMap = json.decode(userJson);
        return userMap['email'] == email;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking email: $e');
      return false;
    }
  }
}
