import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:krishi/core/services/storage_services/token_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../get.dart';

typedef QueryType = Map<String, dynamic>?;

class ApiManager {
  final _connectTimeout = const Duration(seconds: 20);
  final _receiveTimeout = const Duration(seconds: 20);
  final _sendTimeout = const Duration(seconds: 20);

  /// Dio instance used for API requests.
  late Dio dio;
  final TokenStorage tokenStorage;
  ApiManager(Ref ref, this.tokenStorage) {
    Map<String, dynamic> headers = {};

    BaseOptions options = BaseOptions(
      baseUrl: Get.baseUrl,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      sendTimeout: _sendTimeout,
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,
      headers: headers,
    );

    dio = Dio(options);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (kDebugMode) {
            print('🌐 API Request: ${options.method} ${options.uri}');
            print('📤 Request data: ${options.data}');
            print('📋 Request headers: ${options.headers}');
          }

          // List of public endpoints that don't require authentication
          final publicEndpoints = [
            'categories/',
            'units/',
            'weather/current/',
            'products/',
            'knowledge/articles/',
            'news/',
            'auth/google/mobile/',
          ];

          // Check if the path starts with any public endpoint
          final isPublic = publicEndpoints.any(
            (endpoint) =>
                options.path.startsWith(endpoint) ||
                options.path.startsWith('/$endpoint'),
          );

          // Only add auth token for non-public endpoints
          if (!isPublic) {
            final accessToken = await tokenStorage.getAccessToken();
            if (accessToken != null) {
              // Krishi API uses "Token" auth scheme instead of "Bearer"
              options.headers['Authorization'] = 'Token $accessToken';
              if (kDebugMode) {
                print('🔑 Added auth token to request');
              }
            }
          } else {
            if (kDebugMode) {
              print('🔓 Public endpoint - no auth token needed');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
              '✅ API Response: ${response.statusCode} ${response.requestOptions.uri}',
            );
            print('📥 Response data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print('❌ API Error: ${error.type}');
            print('🔗 URL: ${error.requestOptions.uri}');
            print('📤 Request data: ${error.requestOptions.data}');
            if (error.response != null) {
              print('📥 Error response: ${error.response?.statusCode}');
              print('📥 Error data: ${error.response?.data}');
            } else {
              print('⚠️ No response received - ${error.message}');
              print('⚠️ Error: ${error.error}');
            }
          }
          if (error.response?.statusCode == 401) {
            // Token expired - clear tokens and redirect to login
            await tokenStorage.clearTokens();
          }
          return handler.next(error);
        },
      ),
    );

    // dio.interceptors.add(ref.read(cacheResolverProvider));
  }

  Future<Response> get(
    String path, {
    Options? options,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(String path, {Options? options, dynamic data}) async {
    try {
      // Set contentType based on data type
      final requestOptions = options ?? Options();

      final finalOptions = requestOptions.copyWith(
        contentType: data is FormData ? null : Headers.jsonContentType,
      );

      if (kDebugMode) {
        print('📝 POST Request to: $path');
        print('📦 Data type: ${data.runtimeType}');
        print('📋 Final headers: ${finalOptions.headers}');
        print('🔗 Full URL will be: ${Get.baseUrl}$path');
        print('🚀 About to send POST request...');
      }

      final response = await dio.post(path, data: data, options: finalOptions);

      if (kDebugMode) {
        print('✅ POST request completed successfully');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ POST request failed with error: $e');
        print('❌ Error type: ${e.runtimeType}');
      }
      rethrow;
    }
  }

  Future<Response> patch(String path, {Options? options, dynamic data}) async {
    return await dio.patch(path, data: data, options: options);
  }

  Future<Response> delete(String path, {Options? options}) async {
    return await dio.delete(path, options: options);
  }

  Future<Response> put(String path, {Options? options, dynamic data}) async {
    return await dio.put(path, data: data, options: options);
  }
}
