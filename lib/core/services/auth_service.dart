import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '../../abstractservices/storage_services.dart';
import 'storage_services/hive_keys.dart';
import 'storage_services/token_storage_service.dart';
import 'api_services/krishi_api_service.dart';

class AuthService extends ChangeNotifier {
  final StorageServices box;
  final TokenStorage tokenStorage;
  final KrishiApiService apiService;
  bool _isAuthenticated = false;
  bool _isInitialized = false;

  // Configure Google Sign-In with your OAuth credentials
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Web Client ID from Google Cloud Console
    // This MUST be the web client ID for backend validation to work on both Android and iOS
    serverClientId: '22500384416-5choujjs47148lfal8k3g2ugs0nic29j.apps.googleusercontent.com',
  );

  AuthService(this.box, this.tokenStorage, this.apiService) {
    // Defer initialization so the provider can finish building first.
    Future.microtask(() => init());
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;

  Future<AuthService> init() async {
    if (_isInitialized) return this;
    final stored = await box.get(StorageKeys.isLoggedIn) ?? false;
    _isAuthenticated = stored;
    _isInitialized = true;
    notifyListeners();
    return this;
  }

  Future<bool> signInWithGoogle() async {
    try {
      // Step 1: Sign in with Google
      if (kDebugMode) {
        print('[AuthService] Starting Google Sign In...');
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        if (kDebugMode) {
          print('[AuthService] User cancelled Google Sign In');
        }
        return false;
      }

      if (kDebugMode) {
        print(
          '[AuthService] Google Sign In successful for: ${googleUser.email}',
        );
      }

      // Step 2: Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        if (kDebugMode) {
          print('[AuthService] ERROR: ID Token is null');
        }
        return false;
      }

      if (kDebugMode) {
        print('[AuthService] Got ID Token, sending to backend...');
      }

      // Step 3: Send ID token to Django backend using KrishiApiService
      try {
        final data = await apiService.authenticateWithGoogleMobile(idToken);

        if (kDebugMode) {
          print('[AuthService] Backend response received');
          print('[AuthService] Response keys: ${data.keys.toList()}');
          print('[AuthService] Full response: $data');
        }

        // Extract the Django auth token
        // Try different possible field names
        final String? authToken =
            data['token'] as String? ??
            data['access_token'] as String? ??
            data['id_token'] as String?;

        if (kDebugMode) {
          print(
            '[AuthService] Extracted token: ${authToken != null ? "YES (length: ${authToken.length})" : "NO"}',
          );
          if (authToken != null) {
            print(
              '[AuthService] Token preview: ${authToken.substring(0, authToken.length > 20 ? 20 : authToken.length)}...',
            );
          }
        }

        if (authToken != null && authToken.isNotEmpty) {
          if (kDebugMode) {
            print('[AuthService] Backend authentication successful');
          }
          // Store the Django auth token
          await tokenStorage.saveTokens(authToken, '');

          // Verify token was saved correctly - try multiple times to ensure it's written
          String? savedToken;
          for (int i = 0; i < 3; i++) {
            savedToken = await tokenStorage.getAccessToken();
            if (savedToken != null && savedToken.isNotEmpty) {
              break;
            }
            if (kDebugMode && i < 2) {
              print(
                '[AuthService] Token not found, retrying... (attempt ${i + 1}/3)',
              );
            }
            await Future.delayed(const Duration(milliseconds: 100));
          }

          if (kDebugMode) {
            print('[AuthService] Token verification result:');
            print('[AuthService] Token length: ${savedToken?.length ?? 0}');
            if (savedToken != null) {
              print(
                '[AuthService] Token preview: ${savedToken.substring(0, savedToken.length > 20 ? 20 : savedToken.length)}...',
              );
            } else {
              print('[AuthService] ❌ Token is null!');
            }
          }

          if (savedToken == null || savedToken.isEmpty) {
            if (kDebugMode) {
              print(
                '[AuthService] ERROR: Token was not saved correctly after multiple attempts',
              );
            }
            return false;
          }

          await login();
          return true;
        } else {
          if (kDebugMode) {
            print('[AuthService] ERROR: No token in backend response');
          }
          return false;
        }
      } on DioException catch (e) {
        if (kDebugMode) {
          print('[AuthService] Backend API Error: ${e.message}');
          print('[AuthService] Response: ${e.response?.data}');
        }
        return false;
      } catch (e) {
        if (kDebugMode) {
          print('[AuthService] Backend Error: $e');
        }
        return false;
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('[AuthService] Platform Exception: ${e.code} - ${e.message}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('[AuthService] Unexpected Error: $e');
      }
      return false;
    }
  }

  Future<void> login() async {
    _isAuthenticated = true;
    _isInitialized = true;
    await box.set(StorageKeys.isLoggedIn, true);
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore sign out errors
    }

    // Clear tokens
    await tokenStorage.clearTokens();

    // Clear auth state
    _isAuthenticated = false;
    _isInitialized = true;
    await box.set(StorageKeys.isLoggedIn, false);
    notifyListeners();
  }
}
