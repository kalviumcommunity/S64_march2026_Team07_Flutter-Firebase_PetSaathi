import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  StreamSubscription? _profileSubscription;

  AuthProvider() {
    _authService.authStateChanges.listen((firebaseUser) {
      _profileSubscription?.cancel();
      if (firebaseUser != null) {
        _profileSubscription = _authService.watchCurrentUserProfile().listen((profile) {
          _user = profile;
          notifyListeners();
        });
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _user = await _authService.getUserProfile(user.uid);
      }
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'An error occurred during login.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _authService.signUp(email, password, role);
      if (user != null) {
        _user = await _authService.getUserProfile(user.uid);
      }
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'An error occurred during signup.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String? location,
    required bool isAvailable,
  }) async {
    await _authService.updateProfile(
      name: name,
      location: location,
      isAvailable: isAvailable,
    );
  }
}
