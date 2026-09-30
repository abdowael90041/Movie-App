import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService authService;

  AuthViewModel(this.authService) {
    _subscription = authService.authStateChanges.listen((user) {
      _user = user;
      _initialized = true;
      notifyListeners();
    });
  }

  User? _user;
  bool _isLoading = false;
  bool _initialized = false;
  String? _error;
  late final StreamSubscription<User?> _subscription;

  User? get user => _user ?? authService.currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => user != null;
  bool get initialized => _initialized;

  Future<bool> login(String email, String password) async {
    return _run(() => authService.login(email, password));
  }

  Future<bool> register(String email, String password) async {
    return _run(() => authService.register(email, password));
  }

  Future<void> logout() async {
    _error = null;
    await authService.logout();
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on AuthException catch (error) {
      _error = error.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
