import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/app_user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  User? _user;
  AppUser? _appUser;
  bool _isLoading = false;

  User? get user => _user;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  bool get isEmailVerified => _authService.isEmailVerified;

  AuthProvider() {
    _authService.user.listen((User? user) async {
      _user = user;
      if (user != null) {
        _appUser = await _firestoreService.getUserProfile(user.uid);
      } else {
        _appUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> reloadUser() async {
    await _authService.reloadUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authService.registerWithEmailAndPassword(email, password, name);
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}
