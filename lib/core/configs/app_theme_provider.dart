import 'package:flutter/material.dart';

import '../../abstractservices/storage_services.dart';

import '../services/storage_services/hive_keys.dart';

class ThemeProvider extends ChangeNotifier {
  final _themes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
  ThemeMode themeMode = ThemeMode.light;
  int index = 0;
  bool _isLoading = false;
  final StorageServices box;
  ThemeProvider(this.box);

  bool get isLoading => _isLoading;

  Future<ThemeProvider> init() async {
    index = await box.get(StorageKeys.appearence) ?? 0;
    themeMode = _themes[index];
    return this;
  }

  Future<void> toggleTheme(int ind) async {
    if (_isLoading || index == ind) return;
    
    _isLoading = true;
    notifyListeners();
    
    // Add a small delay for transition effect
    await Future.delayed(const Duration(milliseconds: 200));
    
    index = ind;
    themeMode = _themes[index];
    await box.set(StorageKeys.appearence, index);
    
    _isLoading = false;
    notifyListeners();
  }
}
