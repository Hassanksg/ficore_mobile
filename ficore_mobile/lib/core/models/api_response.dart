import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  // Success response factory
  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode ?? 200,
    );
  }

  // Error response factory
  factory ApiResponse.error({
    String? message,
    Map<String, dynamic>? errors,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode ?? 400,
    );
  }

  // Network error factory
  factory ApiResponse.networkError({String? message}) {
    return ApiResponse<T>(
      success: false,
      message: message ?? 'Network error occurred',
      statusCode: 0,
    );
  }

  // Timeout error factory
  factory ApiResponse.timeoutError({String? message}) {
    return ApiResponse<T>(
      success: false,
      message: message ?? 'Request timeout',
      statusCode: 408,
    );
  }

  // Server error factory
  factory ApiResponse.serverError({String? message}) {
    return ApiResponse<T>(
      success: false,
      message: message ?? 'Internal server error',
      statusCode: 500,
    );
  }

  // Unauthorized error factory
  factory ApiResponse.unauthorized({String? message}) {
    return ApiResponse<T>(
      success: false,
      message: message ?? 'Unauthorized access',
      statusCode: 401,
    );
  }

  // Forbidden error factory
  factory ApiResponse.forbidden({String? message}) {
    return ApiResponse<T>(
      success: false,
      message: message ?? 'Access forbidden',
      statusCode: 403,
    );
  }

  // Not found error factory
  factory ApiResponse.notFound({String? message}) {
    return ApiResponse<T>(
      success: false,
      message: message ?? 'Resource not found',
      statusCode: 404,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
  bool get hasData => data != null;
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  String get errorMessage {
    if (message != null) return message!;
    if (hasErrors) {
      return errors!.values.first.toString();
    }
    return 'An unknown error occurred';
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}

// Specialized response types for common use cases
@JsonSerializable()
class LoginResponse {
  final String token;
  final Map<String, dynamic> user;
  @JsonKey(name: 'session_id')
  final String? sessionId;

  const LoginResponse({
    required this.token,
    required this.user,
    this.sessionId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  @JsonKey(name: 'per_page')
  final int perPage;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'has_next')
  final bool hasNext;
  @JsonKey(name: 'has_prev')
  final bool hasPrev;

  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}