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

          // Endpoints that are public for GET requests only
          final publicGetEndpoints = [
            'categories/',
            'units/',
            'weather/current/',
            'products/',
            'knowledge/articles/',
            'news/',
          ];

          // Endpoints that are public for all methods (including POST)
          final alwaysPublicEndpoints = [
            'auth/google/mobile/', // Google auth is public (sends id_token in body)
          ];

          // HTTP methods that require authentication (write operations)
          final writeMethods = ['POST', 'PATCH', 'PUT', 'DELETE'];
          final isWriteOperation = writeMethods.contains(options.method);

          // Check if it's a public GET endpoint
          final isPublicGetEndpoint = publicGetEndpoints.any(
            (endpoint) =>
                options.path.startsWith(endpoint) ||
                options.path.startsWith('/$endpoint'),
          );

          // Check if it's always public (any method)
          final isAlwaysPublic = alwaysPublicEndpoints.any(
            (endpoint) =>
                options.path.startsWith(endpoint) ||
                options.path.startsWith('/$endpoint'),
          );

          // Require auth if:
          // 1. It's a write operation (POST, PATCH, PUT, DELETE), OR
          // 2. It's a GET/read operation to a non-public endpoint
          // Exception: Always public endpoints never require auth
          final requiresAuth =
              !isAlwaysPublic && (isWriteOperation || !isPublicGetEndpoint);

          if (requiresAuth) {
            final accessToken = await tokenStorage.getAccessToken();

            if (kDebugMode) {
              print('🔐 Auth required for: ${options.method} ${options.path}');
              print(
                '🔑 Token retrieved: ${accessToken != null ? "YES (length: ${accessToken.length})" : "NO"}',
              );
              if (accessToken != null) {
                print(
                  '🔑 Token preview: ${accessToken.substring(0, accessToken.length > 30 ? 30 : accessToken.length)}...',
                );
              }
            }

            if (accessToken != null && accessToken.isNotEmpty) {
              // Krishi API uses "Token" format for stored tokens
              options.headers['Authorization'] = 'Token $accessToken';
              if (kDebugMode) {
                print(
                  '✅ Authorization header set: Token ${accessToken.substring(0, accessToken.length > 20 ? 20 : accessToken.length)}...',
                );
              }
            } else {
              if (kDebugMode) {
                print('❌ Auth required but no token found or token is empty');
                print('❌ This request will likely fail with 401 Unauthorized');
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
