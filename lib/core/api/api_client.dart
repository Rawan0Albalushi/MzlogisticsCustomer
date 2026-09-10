import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../storage/token_storage.dart';
import 'api_envelope.dart';
import 'api_exception.dart';

typedef UnauthorizedHandler = void Function();
typedef LocaleReader = String Function();

class ApiClient {
  ApiClient({
    required this._tokenStorage,
    required this._localeReader,
    this._onUnauthorized,
    String? baseUrl,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    debugPrint('MZ customer API: ${_dio.options.baseUrl}');

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept-Language'] = _localeReader();
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _tokenStorage.clear();
            _onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  final LocaleReader _localeReader;
  final UnauthorizedHandler? _onUnauthorized;
  late final Dio _dio;

  Future<ApiEnvelope> get(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return _send(() => _dio.get<dynamic>(path, queryParameters: query));
  }

  Future<ApiEnvelope> post(String path, {Object? data}) {
    return _send(() => _dio.post<dynamic>(path, data: data));
  }

  Future<ApiEnvelope> put(String path, {Object? data}) {
    return _send(() => _dio.put<dynamic>(path, data: data));
  }

  Future<ApiEnvelope> patch(String path, {Object? data}) {
    return _send(() => _dio.patch<dynamic>(path, data: data));
  }

  Future<ApiEnvelope> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return ApiEnvelope.fromJson(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
