import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constants/api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  ApiClient._internal() {
    // On web (Chrome debug), route through a local CORS proxy to avoid
    // browser preflight blocks. On mobile this is unused.
    final baseUrl = kIsWeb
        ? 'https://corsproxy.io/?url=${Uri.encodeComponent(ApiConstants.baseUrl)}'
        : ApiConstants.baseUrl;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => print('API: $o'),
    ));
  }

  Dio get dio => _dio;

  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    return _dio.post(endpoint, data: data);
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? params}) async {
    return _dio.get(endpoint, queryParameters: params);
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
}
