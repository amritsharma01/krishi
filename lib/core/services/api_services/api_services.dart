import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:krishi/core/services/storage_services/token_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../get.dart';
import '../storage_services/hive_keys.dart';
import '../../core_service_providers.dart';
import '../../../features/cart/providers/cart_providers.dart';
import '../../../features/cart/providers/checkout_providers.dart';

typedef QueryType = Map<String, dynamic>?;

class ApiManager {
  final _connectTimeout = const Duration(seconds: 30);
  final _receiveTimeout = const Duration(seconds: 30);
  final _sendTimeout = const Duration(seconds: 30);

  /// Dio instance used for API requests.
  late Dio dio;
  final TokenStorage tokenStorage;
  final Ref ref;

  // Flag to prevent multiple 401 handling in quick succession
  DateTime? _last401Handled;
  static const _401HandlingCooldown = Duration(seconds: 2);

  ApiManager(this.ref, this.tokenStorage) {
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
            // Prevent multiple 401 handling in quick succession (avoid loops)
            final now = DateTime.now();
            if (_last401Handled == null ||
                now.difference(_last401Handled!) > _401HandlingCooldown) {
              _last401Handled = now;

              if (kDebugMode) {
                print(
                  '🔒 Handling 401 Unauthorized - clearing tokens and auth state',
                );
              }

              // Clear tokens
              await tokenStorage.clearTokens();

              // Update auth state in storage and authServiceProvider
              try {
                final box = Get.box;
                final isLoggedIn =
                    await box.get(StorageKeys.isLoggedIn) ?? false;
                if (isLoggedIn) {
                  await box.set(StorageKeys.isLoggedIn, false);
                  
                  // Update authServiceProvider state to trigger UI update
                  // This ensures main.dart reacts to the auth state change
                  try {
                    final authService = ref.read(authServiceProvider);
                    // Update internal state without signing out from Google
                    // (token is already expired, no need to sign out from Google)
                    authService.handleTokenExpiration();
                    
                    // Invalidate persistent providers that cache account-specific data
                    // These won't automatically clear when tokens expire
                    ref.invalidate(cartProvider); // Persistent StateNotifierProvider
                    ref.invalidate(checkoutStateProvider); // Persistent StateNotifierProvider
                    // Auto-dispose providers will reload naturally, but invalidating ensures immediate cleanup
                    ref.invalidate(checkoutUserProfileProvider);
                    
                    if (kDebugMode) {
                      print(
                        '✅ Auth state updated - user will be redirected to login',
                      );
                    }
                  } catch (authError) {
                    if (kDebugMode) {
                      print('⚠️ Error updating authService state: $authError');
                    }
                    // Fallback: invalidate providers to force rebuild
                    ref.invalidate(authServiceProvider);
                    ref.invalidate(cartProvider); // Persistent StateNotifierProvider
                    ref.invalidate(checkoutStateProvider); // Persistent StateNotifierProvider
                    ref.invalidate(checkoutUserProfileProvider); // Auto-dispose, but ensures cleanup
                  }
                }
              } catch (e) {
                if (kDebugMode) {
                  print('⚠️ Error updating auth state: $e');
                }
              }
            } else {
              if (kDebugMode) {
                print('⏭️ Skipping 401 handling (cooldown active)');
              }
            }
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
