// ============================================================
// VibeLab — auth_provider.dart
// Manages authentication state across the entire app.
// Listens to Firebase Auth stream — auto-updates on login/logout.
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum AuthState {
  initial,      // App just launched — checking auth status
  authenticated, // User is logged in
  unauthenticated, // User is not logged in
  loading,      // Auth operation in progress
  error,        // Auth operation failed
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  User? _user;
  String _errorMessage = '';
  Map<String, dynamic> _userStats = {};
  bool _isLoadingStats = false;

  // ----------------------------------------------------------
  // GETTERS
  // ----------------------------------------------------------
  AuthState get state => _state;
  User? get user => _user;
  String get errorMessage => _errorMessage;
  Map<String, dynamic> get userStats => _userStats;
  bool get isLoadingStats => _isLoadingStats;
  bool get isAuthenticated => _state == AuthState.authenticated;
  String get displayName =>
      _user?.displayName ?? _userStats['display_name'] ?? 'Vibe Creator';
  String get email => _user?.email ?? '';
  String get photoUrl =>
      _user?.photoURL ?? _userStats['photo_url'] ?? '';

  // ----------------------------------------------------------
  // CONSTRUCTOR — listen to auth state changes immediately
  // ----------------------------------------------------------
  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _state = AuthState.authenticated;
        loadUserStats(); // Load stats when user logs in
      } else {
        _state = AuthState.unauthenticated;
        _userStats = {};
      }
      notifyListeners();
    });
  }

  // ----------------------------------------------------------
  // GOOGLE SIGN IN
  // ----------------------------------------------------------
  Future<void> signInWithGoogle() async {
    _setLoading();
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        // User cancelled — go back to unauthenticated quietly
        _state = AuthState.unauthenticated;
        notifyListeners();
      }
      // Success handled by authStateChanges stream
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ----------------------------------------------------------
  // EMAIL REGISTER
  // ----------------------------------------------------------
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading();
    try {
      await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      // Success handled by authStateChanges stream
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ----------------------------------------------------------
  // EMAIL SIGN IN
  // ----------------------------------------------------------
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      // Success handled by authStateChanges stream
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ----------------------------------------------------------
  // SIGN OUT
  // ----------------------------------------------------------
  Future<void> signOut() async {
    _setLoading();
    try {
      await _authService.signOut();
      // Success handled by authStateChanges stream
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ----------------------------------------------------------
  // UPDATE DISPLAY NAME
  // ----------------------------------------------------------
  Future<void> updateDisplayName(String newName) async {
    try {
      await _authService.updateDisplayName(newName);
      await _user?.reload();
      _user = _authService.currentUser;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ----------------------------------------------------------
  // SEND PASSWORD RESET
  // ----------------------------------------------------------
  Future<void> sendPasswordReset(String email) async {
    _setLoading();
    try {
      await _authService.sendPasswordResetEmail(email);
      _state = AuthState.unauthenticated;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ----------------------------------------------------------
  // DELETE ACCOUNT
  // ----------------------------------------------------------
  Future<void> deleteAccount() async {
    _setLoading();
    try {
      await _authService.deleteAccount();
      // authStateChanges stream handles state update
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ----------------------------------------------------------
  // LOAD USER STATS
  // ----------------------------------------------------------
  Future<void> loadUserStats() async {
    if (_user == null) return;
    _isLoadingStats = true;
    notifyListeners();

    try {
      _userStats = await _authService.getUserStats(_user!.uid);
    } catch (e) {
      _userStats = {'total_vibes': 0};
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  // ----------------------------------------------------------
  // CLEAR ERROR
  // ----------------------------------------------------------
  void clearError() {
    _errorMessage = '';
    _state = isAuthenticated
        ? AuthState.authenticated
        : AuthState.unauthenticated;
    notifyListeners();
  }

  // ----------------------------------------------------------
  // PRIVATE HELPERS
  // ----------------------------------------------------------
  void _setLoading() {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message.replaceAll('Exception: ', '');
    _state = AuthState.error;
    notifyListeners();
  }
}