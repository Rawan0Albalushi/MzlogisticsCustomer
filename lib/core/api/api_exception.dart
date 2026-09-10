import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.errors = const {},
  });

  final String message;
  final int? statusCode;
  final Map<String, List<String>> errors;

  bool get isUnauthorized => statusCode == 401;
  bool get isValidation => statusCode == 422;

  String? fieldError(String key) {
    final values = errors[key];
    if (values == null || values.isEmpty) return null;
    return values.first;
  }

  factory ApiException.fromDio(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiException(message: 'network', statusCode: status);
    }

    if (data is Map) {
      final errors = <String, List<String>>{};
      final rawErrors = data['errors'];
      if (rawErrors is Map) {
        rawErrors.forEach((key, value) {
          if (value is List) {
            errors['$key'] = value.map((item) => item.toString()).toList();
          } else if (value != null) {
            errors['$key'] = [value.toString()];
          }
        });
      }
      final message = data['message']?.toString();
      return ApiException(
        message: message == null || message.isEmpty ? 'error' : message,
        statusCode: status,
        errors: errors,
      );
    }

    return ApiException(
      message: error.message ?? 'error',
      statusCode: status,
    );
  }

  @override
  String toString() => message;
}
