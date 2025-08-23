import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';
import '../models/api_response.dart';
import 'storage_service.dart';

class ApiService {
  late final Dio _dio;
  final Logger _logger = Logger();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authentication token if available
          final token = await StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add session ID if available
          final sessionId = await StorageService.getSessionId();
          if (sessionId != null) {
            options.headers['X-Session-ID'] = sessionId;
          }

          // Add CSRF token for POST, PUT, DELETE requests
          if (['POST', 'PUT', 'DELETE'].contains(options.method)) {
            // In a real app, you'd get this from a previous request or login
            // For now, we'll handle CSRF in the Flask backend
          }

          if (AppConfig.enableLogging) {
            _logger.d('Request: ${options.method} ${options.path}');
            _logger.d('Headers: ${options.headers}');
            if (options.data != null) {
              _logger.d('Data: ${options.data}');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (AppConfig.enableLogging) {
            _logger.d('Response: ${response.statusCode} ${response.requestOptions.path}');
            _logger.d('Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (AppConfig.enableLogging) {
            _logger.e('Error: ${error.message}');
            _logger.e('Response: ${error.response?.data}');
          }

          // Handle token expiration
          if (error.response?.statusCode == 401) {
            _handleUnauthorized();
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<void> _handleUnauthorized() async {
    // Clear stored authentication data
    await StorageService.clearAuthData();
    // In a real app, you might want to redirect to login screen
    // This would be handled by the AuthProvider
  }

  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Handle successful response
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    final statusCode = response.statusCode ?? 0;
    
    if (statusCode >= 200 && statusCode < 300) {
      final responseData = response.data;
      
      // Handle different response formats from Flask backend
      if (responseData is Map<String, dynamic>) {
        // Check if it's already in ApiResponse format
        if (responseData.containsKey('success')) {
          final success = responseData['success'] as bool? ?? true;
          final message = responseData['message'] as String?;
          final data = responseData['data'];
          final errors = responseData['errors'] as Map<String, dynamic>?;

          T? parsedData;
          if (data != null && fromJson != null) {
            try {
              parsedData = fromJson(data);
            } catch (e) {
              _logger.e('Error parsing response data: $e');
            }
          } else if (data is T) {
            parsedData = data;
          }

          return ApiResponse<T>(
            success: success,
            message: message,
            data: parsedData,
            errors: errors,
            statusCode: statusCode,
          );
        } else {
          // Direct data response
          T? parsedData;
          if (fromJson != null) {
            try {
              parsedData = fromJson(responseData);
            } catch (e) {
              _logger.e('Error parsing response data: $e');
            }
          } else if (responseData is T) {
            parsedData = responseData;
          }

          return ApiResponse.success<T>(
            data: parsedData,
            statusCode: statusCode,
          );
        }
      } else {
        // Handle non-JSON responses
        T? parsedData;
        if (fromJson != null) {
          try {
            parsedData = fromJson(responseData);
          } catch (e) {
            _logger.e('Error parsing response data: $e');
          }
        } else if (responseData is T) {
          parsedData = responseData;
        }

        return ApiResponse.success<T>(
          data: parsedData,
          statusCode: statusCode,
        );
      }
    } else {
      return ApiResponse.error<T>(
        message: 'Request failed with status code: $statusCode',
        statusCode: statusCode,
      );
    }
  }

  // Handle errors
  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiResponse.timeoutError<T>();

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 0;
          final responseData = error.response?.data;

          String message = 'Request failed';
          Map<String, dynamic>? errors;

          if (responseData is Map<String, dynamic>) {
            message = responseData['message'] as String? ?? message;
            errors = responseData['errors'] as Map<String, dynamic>?;
          } else if (responseData is String) {
            message = responseData;
          }

          switch (statusCode) {
            case 401:
              return ApiResponse.unauthorized<T>(message: message);
            case 403:
              return ApiResponse.forbidden<T>(message: message);
            case 404:
              return ApiResponse.notFound<T>(message: message);
            case 500:
              return ApiResponse.serverError<T>(message: message);
            default:
              return ApiResponse.error<T>(
                message: message,
                errors: errors,
                statusCode: statusCode,
              );
          }

        case DioExceptionType.cancel:
          return ApiResponse.error<T>(
            message: 'Request was cancelled',
            statusCode: 0,
          );

        case DioExceptionType.connectionError:
          return ApiResponse.networkError<T>();

        default:
          return ApiResponse.error<T>(
            message: error.message ?? 'Unknown error occurred',
            statusCode: 0,
          );
      }
    } else if (error is SocketException) {
      return ApiResponse.networkError<T>(
        message: 'No internet connection',
      );
    } else {
      return ApiResponse.error<T>(
        message: error.toString(),
        statusCode: 0,
      );
    }
  }

  // Multipart file upload
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    T Function(dynamic)? fromJson,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData();
      
      // Add file
      formData.files.add(MapEntry(
        fieldName,
        await MultipartFile.fromFile(filePath),
      ));

      // Add additional data
      if (additionalData != null) {
        additionalData.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Download file
  Future<ApiResponse<String>> downloadFile(
    String endpoint,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        endpoint,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );

      return ApiResponse.success<String>(
        data: savePath,
        message: 'File downloaded successfully',
      );
    } catch (e) {
      return _handleError<String>(e);
    }
  }

  // Cancel all requests
  void cancelRequests() {
    _dio.clear();
  }

  // Update base URL (useful for switching environments)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // Get current base URL
  String get baseUrl => _dio.options.baseUrl;
}