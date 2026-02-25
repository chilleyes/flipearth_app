import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({required AuthService authService})
      : _authService = authService;

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      _user = result.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(email, password);
      _user = result.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadProfile() async {
    try {
      _user = await _authService.getProfile();
      notifyListeners();
    } on DioException catch (_) {
      // Token may be invalid
      _user = null;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      await loadProfile();
      return _user != null;
    }
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
