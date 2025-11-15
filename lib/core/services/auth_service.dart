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

  // Configure Google Sign-In with your OAuth credentials
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Web Client ID from Google Cloud Console
    serverClientId:
        '22500384416-5choujjs47148lfal8k3g2ugs0nic29j.apps.googleusercontent.com',
  );

  AuthService(this.box, this.tokenStorage, this.apiService);

  bool get isAuthenticated => _isAuthenticated;

  Future<AuthService> init() async {
    _isAuthenticated = await box.get(StorageKeys.isLoggedIn) ?? false;
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

        // Extract the Django auth token
        final String? authToken = data['token'] as String?;

        if (authToken != null) {
          if (kDebugMode) {
            print('[AuthService] Backend authentication successful');
          }
          // Store the Django auth token
          await tokenStorage.saveTokens(authToken, '');
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
    await box.set(StorageKeys.isLoggedIn, false);
    notifyListeners();
  }
}
