import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  TokenStorage(Ref ref);

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      if (kDebugMode) {
        print('[TokenStorage] Saving tokens...');
        print('[TokenStorage] Access token length: ${accessToken.length}');
      }

      await _secureStorage.write(key: 'access_token', value: accessToken);
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);

      // Immediately verify the write
      final verifyToken = await _secureStorage.read(key: 'access_token');
      if (kDebugMode) {
        if (verifyToken == accessToken) {
          print('[TokenStorage] ✅ Token saved and verified successfully');
        } else {
          print('[TokenStorage] ❌ Token verification failed!');
          print(
            '[TokenStorage] Expected length: ${accessToken.length}, Got: ${verifyToken?.length ?? 0}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[TokenStorage] ❌ Error saving tokens: $e');
      }
      rethrow;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (kDebugMode) {
        if (token != null) {
          print('[TokenStorage] ✅ Token retrieved: length=${token.length}');
        } else {
          print('[TokenStorage] ⚠️ No token found in storage');
          // Try to list all keys for debugging
          final allKeys = await _secureStorage.readAll();
          print('[TokenStorage] All stored keys: ${allKeys.keys.toList()}');
        }
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('[TokenStorage] ❌ Error reading token: $e');
      }
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  Future<void> clearTokens() async {
    if (kDebugMode) {
      print('[TokenStorage] Clearing tokens...');
    }
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    if (kDebugMode) {
      print('[TokenStorage] ✅ Tokens cleared');
    }
  }
}
