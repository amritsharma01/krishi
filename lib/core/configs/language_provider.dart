import 'package:flutter/material.dart';
import '../../abstractservices/storage_services.dart';
import '../services/storage_services/hive_keys.dart';

class LanguageProvider extends ChangeNotifier {
  final _languages = ['English', 'नेपाली'];
  String language = 'English';
  int index = 0;
  bool _isLoading = false;
  final StorageServices box;
  
  LanguageProvider(this.box);

  bool get isLoading => _isLoading;

  Future<LanguageProvider> init() async {
    index = await box.get(StorageKeys.language) ?? 0;
    language = _languages[index];
    return this;
  }

  Future<void> toggleLanguage(int ind) async {
    if (_isLoading || index == ind) return;
    
    _isLoading = true;
    notifyListeners();
    
    // Add a small delay for transition effect
    await Future.delayed(const Duration(milliseconds: 200));
    
    index = ind;
    language = _languages[index];
    await box.set(StorageKeys.language, index);
    
    _isLoading = false;
    notifyListeners();
  }

  bool get isEnglish => index == 0;
  bool get isNepali => index == 1;
}

