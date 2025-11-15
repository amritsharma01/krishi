import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../configs/app_translations.dart';
import '../core_service_providers.dart';

extension TranslationExtension on String {
  String tr(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    final langProvider = container.read(languageProvider);
    final languageCode = langProvider.isEnglish ? 'en' : 'ne';
    return AppTranslations.translate(this, languageCode);
  }
}

