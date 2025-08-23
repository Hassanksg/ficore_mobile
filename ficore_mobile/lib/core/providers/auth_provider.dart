import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../models/api_response.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService) {
    _checkAuthStatus();
  }

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  bool get isAdmin => _user?.isAdminUser ?? false;
  bool get isPersonalUser => _user?.isPersonalUser ?? false;
  double get ficoreCredits => _user?.ficoreCreditBalance ?? 0.0;

  // Check authentication status on app start
  Future<void> _checkAuthStatus() async {
    _setLoading(true);
    
    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        final response = await _authService.getCurrentUser();
        if (response.isSuccess && response.data != null) {
          _user = response.data;
          _setState(AuthState.authenticated);
        } else {
          _setState(AuthState.unauthenticated);
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Failed to check authentication status');
      _setState(AuthState.unauthenticated);
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login({
    required String identifier,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(
        identifier: identifier,
        password: password,
        rememberMe: rememberMe,
      );

      if (response.isSuccess && response.data != null) {
        _user = response.data;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.errorMessage);
        _setState(AuthState.error);
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      _setState(AuthState.error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.register(
        username: username,
        email: email,
        password: password,
      );

      if (response.isSuccess && response.data != null) {
        _user = response.data;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.errorMessage);
        _setState(AuthState.error);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      _setState(AuthState.error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _user = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      // Even if logout fails on server, clear local data
      _user = null;
      _setState(AuthState.unauthenticated);
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    String? language,
    bool? darkMode,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        address: address,
        language: language,
        darkMode: darkMode,
      );

      if (response.isSuccess && response.data != null) {
        _user = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response.isSuccess) {
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Password change failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Forgot password
  Future<bool> forgotPassword({required String email}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.forgotPassword(email: email);

      if (response.isSuccess) {
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Failed to send reset email: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      if (response.isSuccess) {
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify 2FA
  Future<bool> verify2FA({required String otp}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.verify2FA(otp: otp);

      if (response.isSuccess && response.data != null) {
        _user = response.data;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('2FA verification failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Complete setup for new users
  Future<bool> completeSetup({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
    required String language,
    required bool acceptTerms,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.completeSetup(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        address: address,
        language: language,
        acceptTerms: acceptTerms,
      );

      if (response.isSuccess && response.data != null) {
        _user = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Setup failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (!isAuthenticated) return;

    try {
      final response = await _authService.getCurrentUser();
      if (response.isSuccess && response.data != null) {
        _user = response.data;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail for refresh operations
      debugPrint('Failed to refresh user data: $e');
    }
  }

  // Update credits locally (for immediate UI feedback)
  void updateCredits(double newBalance) {
    if (_user != null) {
      _user = _user!.copyWith(ficoreCreditBalance: newBalance);
      StorageService.saveCredits(newBalance);
      notifyListeners();
    }
  }

  // Private helper methods
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    super.dispose();
  }
}