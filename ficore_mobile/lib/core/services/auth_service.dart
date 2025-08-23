import 'dart:convert';

import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService({required ApiService apiService}) : _apiService = apiService;

  // Login with username/email and password
  Future<ApiResponse<User>> login({
    required String identifier,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConfig.loginEndpoint,
        data: {
          'username': identifier,
          'password': password,
          'remember': rememberMe,
        },
      );

      if (response.isSuccess && response.data != null) {
        // Handle different response formats from Flask backend
        final responseData = response.data!;
        
        // Check if we have user data directly or need to extract it
        Map<String, dynamic> userData;
        String? token;
        String? sessionId;

        if (responseData.containsKey('user')) {
          userData = responseData['user'] as Map<String, dynamic>;
          token = responseData['token'] as String?;
          sessionId = responseData['session_id'] as String?;
        } else {
          // Assume the entire response is user data
          userData = responseData;
        }

        final user = User.fromJson(userData);

        // Store authentication data
        if (token != null) {
          await StorageService.saveToken(token);
        }
        if (sessionId != null) {
          await StorageService.saveSessionId(sessionId);
        }
        await StorageService.saveUser(user);

        // Save user's language preference
        if (user.language != null) {
          await StorageService.saveLanguage(user.language!);
        }

        // Save theme preference
        if (user.darkMode != null) {
          await StorageService.saveThemeMode(user.darkMode! ? 'dark' : 'light');
        }

        // Cache credits
        await StorageService.saveCredits(user.ficoreCreditBalance);

        return ApiResponse.success<User>(
          data: user,
          message: response.message ?? 'Login successful',
        );
      } else {
        return ApiResponse.error<User>(
          message: response.message ?? 'Login failed',
          errors: response.errors,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error<User>(
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  // Register new user
  Future<ApiResponse<User>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConfig.signupEndpoint,
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      if (response.isSuccess && response.data != null) {
        final responseData = response.data!;
        
        // Handle different response formats
        Map<String, dynamic> userData;
        String? token;
        String? sessionId;

        if (responseData.containsKey('user')) {
          userData = responseData['user'] as Map<String, dynamic>;
          token = responseData['token'] as String?;
          sessionId = responseData['session_id'] as String?;
        } else {
          userData = responseData;
        }

        final user = User.fromJson(userData);

        // Store authentication data
        if (token != null) {
          await StorageService.saveToken(token);
        }
        if (sessionId != null) {
          await StorageService.saveSessionId(sessionId);
        }
        await StorageService.saveUser(user);

        // Set default preferences for new user
        await StorageService.saveLanguage(AppConfig.defaultLanguage);
        await StorageService.saveCredits(user.ficoreCreditBalance);

        return ApiResponse.success<User>(
          data: user,
          message: response.message ?? 'Registration successful',
        );
      } else {
        return ApiResponse.error<User>(
          message: response.message ?? 'Registration failed',
          errors: response.errors,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error<User>(
        message: 'Registration failed: ${e.toString()}',
      );
    }
  }

  // Logout user
  Future<ApiResponse<void>> logout() async {
    try {
      // Call logout endpoint if available
      await _apiService.post<void>(AppConfig.logoutEndpoint);
      
      // Clear all stored authentication data
      await StorageService.clearAuthData();

      return ApiResponse.success<void>(
        message: 'Logout successful',
      );
    } catch (e) {
      // Even if the API call fails, clear local data
      await StorageService.clearAuthData();
      
      return ApiResponse.success<void>(
        message: 'Logout successful',
      );
    }
  }

  // Get current user profile
  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      // First try to get user from local storage
      final cachedUser = await StorageService.getUser();
      if (cachedUser != null) {
        // Optionally refresh from server
        final response = await _apiService.get<Map<String, dynamic>>(
          AppConfig.profileEndpoint,
        );

        if (response.isSuccess && response.data != null) {
          final user = User.fromJson(response.data!);
          await StorageService.saveUser(user);
          await StorageService.saveCredits(user.ficoreCreditBalance);
          
          return ApiResponse.success<User>(data: user);
        } else {
          // Return cached user if API call fails
          return ApiResponse.success<User>(data: cachedUser);
        }
      } else {
        // No cached user, must fetch from server
        final response = await _apiService.get<Map<String, dynamic>>(
          AppConfig.profileEndpoint,
        );

        if (response.isSuccess && response.data != null) {
          final user = User.fromJson(response.data!);
          await StorageService.saveUser(user);
          await StorageService.saveCredits(user.ficoreCreditBalance);
          
          return ApiResponse.success<User>(data: user);
        } else {
          return ApiResponse.error<User>(
            message: response.message ?? 'Failed to get user profile',
            statusCode: response.statusCode,
          );
        }
      }
    } catch (e) {
      return ApiResponse.error<User>(
        message: 'Failed to get user profile: ${e.toString()}',
      );
    }
  }

  // Update user profile
  Future<ApiResponse<User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    String? language,
    bool? darkMode,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (address != null) data['address'] = address;
      if (language != null) data['language'] = language;
      if (darkMode != null) data['dark_mode'] = darkMode;

      final response = await _apiService.put<Map<String, dynamic>>(
        AppConfig.profileEndpoint,
        data: data,
      );

      if (response.isSuccess && response.data != null) {
        final user = User.fromJson(response.data!);
        await StorageService.saveUser(user);

        // Update local preferences
        if (language != null) {
          await StorageService.saveLanguage(language);
        }
        if (darkMode != null) {
          await StorageService.saveThemeMode(darkMode ? 'dark' : 'light');
        }

        return ApiResponse.success<User>(
          data: user,
          message: response.message ?? 'Profile updated successfully',
        );
      } else {
        return ApiResponse.error<User>(
          message: response.message ?? 'Failed to update profile',
          errors: response.errors,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error<User>(
        message: 'Failed to update profile: ${e.toString()}',
      );
    }
  }

  // Change password
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.put<void>(
        '${AppConfig.profileEndpoint}/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      return response;
    } catch (e) {
      return ApiResponse.error<void>(
        message: 'Failed to change password: ${e.toString()}',
      );
    }
  }

  // Forgot password
  Future<ApiResponse<void>> forgotPassword({required String email}) async {
    try {
      final response = await _apiService.post<void>(
        '/users/forgot-password',
        data: {'email': email},
      );

      return response;
    } catch (e) {
      return ApiResponse.error<void>(
        message: 'Failed to send reset email: ${e.toString()}',
      );
    }
  }

  // Reset password with token
  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post<void>(
        '/users/reset-password',
        data: {
          'token': token,
          'password': newPassword,
        },
      );

      return response;
    } catch (e) {
      return ApiResponse.error<void>(
        message: 'Failed to reset password: ${e.toString()}',
      );
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await StorageService.getToken();
    final user = await StorageService.getUser();
    return token != null && user != null;
  }

  // Refresh authentication token
  Future<ApiResponse<void>> refreshToken() async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/users/refresh-token',
      );

      if (response.isSuccess && response.data != null) {
        final token = response.data!['token'] as String?;
        if (token != null) {
          await StorageService.saveToken(token);
        }
        
        return ApiResponse.success<void>(
          message: 'Token refreshed successfully',
        );
      } else {
        return ApiResponse.error<void>(
          message: response.message ?? 'Failed to refresh token',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error<void>(
        message: 'Failed to refresh token: ${e.toString()}',
      );
    }
  }

  // Verify 2FA code
  Future<ApiResponse<User>> verify2FA({required String otp}) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/users/verify_2fa',
        data: {'otp': otp},
      );

      if (response.isSuccess && response.data != null) {
        final user = User.fromJson(response.data!);
        await StorageService.saveUser(user);
        
        return ApiResponse.success<User>(
          data: user,
          message: response.message ?? '2FA verification successful',
        );
      } else {
        return ApiResponse.error<User>(
          message: response.message ?? '2FA verification failed',
          errors: response.errors,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error<User>(
        message: '2FA verification failed: ${e.toString()}',
      );
    }
  }

  // Complete user setup (for new users)
  Future<ApiResponse<User>> completeSetup({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
    required String language,
    required bool acceptTerms,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/users/complete-setup',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'address': address,
          'language': language,
          'terms': acceptTerms,
        },
      );

      if (response.isSuccess && response.data != null) {
        final user = User.fromJson(response.data!);
        await StorageService.saveUser(user);
        await StorageService.saveLanguage(language);
        
        return ApiResponse.success<User>(
          data: user,
          message: response.message ?? 'Setup completed successfully',
        );
      } else {
        return ApiResponse.error<User>(
          message: response.message ?? 'Setup failed',
          errors: response.errors,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error<User>(
        message: 'Setup failed: ${e.toString()}',
      );
    }
  }
}