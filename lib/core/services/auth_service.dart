import 'package:flutter/foundation.dart';
import '../../abstractservices/storage_services.dart';
import 'storage_services/hive_keys.dart';

class AuthService extends ChangeNotifier {
  final StorageServices box;
  bool _isAuthenticated = false;

  AuthService(this.box);

  bool get isAuthenticated => _isAuthenticated;

  Future<AuthService> init() async {
    _isAuthenticated = await box.get(StorageKeys.isLoggedIn) ?? false;
    return this;
  }

  Future<void> login() async {
    _isAuthenticated = true;
    await box.set(StorageKeys.isLoggedIn, true);
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    await box.set(StorageKeys.isLoggedIn, false);
    notifyListeners();
  }
}

