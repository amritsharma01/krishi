import 'dart:convert';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/abstractservices/storage_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cache service for storing API responses locally
class CacheService {
  final Ref _ref;
  
  CacheService(this._ref);
  
  StorageServices get _storage => _ref.read(storageServiceProvider);
  
  // Cache keys
  static const String _cachePrefix = 'cache_';
  static const String _cacheTimestampPrefix = 'cache_ts_';
  static const Duration _cacheExpiry = Duration(hours: 1); // Cache expires after 1 hour
  
  // Cache keys for different data types
  static const String _keyMySales = '${_cachePrefix}my_sales';
  static const String _keyMyPurchases = '${_cachePrefix}my_purchases';
  static const String _keyBuyProducts = '${_cachePrefix}buy_products';
  static const String _keySellProducts = '${_cachePrefix}sell_products';
  static const String _keyUserProfile = '${_cachePrefix}user_profile';
  
  /// Check if cache is valid (not expired)
  Future<bool> _isCacheValid(String key) async {
    final timestampKey = '$_cacheTimestampPrefix$key';
    final timestamp = await _storage.get(timestampKey);
    if (timestamp == null) return false;
    
    try {
      final cacheTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      return now.difference(cacheTime) < _cacheExpiry;
    } catch (e) {
      return false;
    }
  }
  
  /// Save data to cache with timestamp
  Future<void> _saveCache(String key, String jsonData) async {
    final timestampKey = '$_cacheTimestampPrefix$key';
    await Future.wait([
      _storage.set(key, jsonData),
      _storage.set(timestampKey, DateTime.now().toIso8601String()),
    ]);
  }
  
  /// Get cached JSON string if valid
  Future<String?> _getCachedJson(String key) async {
    if (!await _isCacheValid(key)) {
      return null;
    }
    return await _storage.get(key);
  }
  
  /// Clear specific cache
  Future<void> clearCache(String key) async {
    final timestampKey = '$_cacheTimestampPrefix$key';
    await Future.wait([
      _storage.remove(key),
      _storage.remove(timestampKey),
    ]);
  }
  
  /// Clear all caches
  Future<void> clearAllCaches() async {
    await Future.wait([
      clearCache(_keyMySales),
      clearCache(_keyMyPurchases),
      clearCache(_keyBuyProducts),
      clearCache(_keySellProducts),
      clearCache(_keyUserProfile),
    ]);
  }
  
  /// Clear my sales cache
  Future<void> clearMySalesCache() async {
    await clearCache(_keyMySales);
  }
  
  /// Clear my purchases cache
  Future<void> clearMyPurchasesCache() async {
    await clearCache(_keyMyPurchases);
  }
  
  // Specific cache methods for orders
  
  Future<List<Map<String, dynamic>>?> getMySalesCache() async {
    final json = await _getCachedJson(_keyMySales);
    if (json == null) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> saveMySalesCache(List<Map<String, dynamic>> data) async {
    await _saveCache(_keyMySales, jsonEncode(data));
  }
  
  Future<List<Map<String, dynamic>>?> getMyPurchasesCache() async {
    final json = await _getCachedJson(_keyMyPurchases);
    if (json == null) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> saveMyPurchasesCache(List<Map<String, dynamic>> data) async {
    await _saveCache(_keyMyPurchases, jsonEncode(data));
  }
  
  // Specific cache methods for products
  
  Future<List<Map<String, dynamic>>?> getBuyProductsCache() async {
    final json = await _getCachedJson(_keyBuyProducts);
    if (json == null) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> saveBuyProductsCache(List<Map<String, dynamic>> data) async {
    await _saveCache(_keyBuyProducts, jsonEncode(data));
  }
  
  Future<List<Map<String, dynamic>>?> getSellProductsCache() async {
    final json = await _getCachedJson(_keySellProducts);
    if (json == null) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> saveSellProductsCache(List<Map<String, dynamic>> data) async {
    await _saveCache(_keySellProducts, jsonEncode(data));
  }
  
  // Specific cache methods for user profile
  
  Future<Map<String, dynamic>?> getUserProfileCache() async {
    final json = await _getCachedJson(_keyUserProfile);
    if (json == null) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> saveUserProfileCache(Map<String, dynamic> data) async {
    await _saveCache(_keyUserProfile, jsonEncode(data));
  }
}

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService(ref);
});

