import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  FirebaseAuth? _auth;
  bool _isOffline = false;
  
  // Mock User State
  String? _mockUserId;
  String? _mockEmail;

  AuthService() {
    try {
      _auth = FirebaseAuth.instance;
    } catch (e) {
      print('AuthService running in Offline Mode');
      _isOffline = true;
    }
  }

  Stream<String?> get userIdStream {
    if (_isOffline) {
      // Mock stream (just emits current value once)
      return Stream.value(_mockUserId);
    }
    return _auth!.authStateChanges().map((user) => user?.uid);
  }

  String? get currentUserId {
    if (_isOffline) return _mockUserId;
    return _auth?.currentUser?.uid;
  }
  
  String? get currentUserEmail {
    if (_isOffline) return _mockEmail;
    return _auth?.currentUser?.email;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    if (_isOffline) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1000));
      _mockUserId = 'mock_user_123';
      _mockEmail = email;
      notifyListeners();
      return true;
    }

    try {
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> registerWithEmail(String email, String password) async {
    if (_isOffline) {
      await Future.delayed(const Duration(milliseconds: 1000));
      _mockUserId = 'mock_user_123';
      _mockEmail = email;
      notifyListeners();
      return true;
    }

    try {
      await _auth!.createUserWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    if (_isOffline) {
      _mockUserId = null;
      _mockEmail = null;
      notifyListeners();
      return;
    }

    try {
      await _auth!.signOut();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }
}
