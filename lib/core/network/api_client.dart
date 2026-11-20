import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.json,
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint('API: $o'),
      ));
    }
  }

  Dio get dio => _dio;

  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) =>
      _dio.post(endpoint, data: data);

  Future<Response> get(String endpoint, {Map<String, dynamic>? params}) =>
      _dio.get(endpoint, queryParameters: params);
}

/// Turns any thrown error into a sentence a client can read.
String friendlyError(Object e) {
  if (e is DioException) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'The server is taking too long. Check your connection and try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Connect and try again.';
      case DioExceptionType.badResponse:
        return 'The server returned an error (${e.response?.statusCode ?? '–'}). Please try again shortly.';
      default:
        return 'Something went wrong while loading. Please try again.';
    }
  }
  return 'Something went wrong while loading. Please try again.';
}
