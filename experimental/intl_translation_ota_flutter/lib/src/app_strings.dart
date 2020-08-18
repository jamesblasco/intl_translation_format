import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_ota/intl_translation_ota.dart';

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  final Map<String, RedableFile> translations;
  final TranslationFormat format;

  _AppStringsDelegate(this.translations, this.format);

  @override
  Future<AppStrings> load(Locale locale) {
    final file = translations[locale.languageCode];
    return AppStrings.load(locale, file, locale.languageCode, format);
  }

  @override
  bool isSupported(Locale locale) =>
      translations.keys.contains(locale.languageCode);

  @override
  bool shouldReload(_AppStringsDelegate old) {
    // Improve this
    return translations.length != old.translations.length;
  }
}

class AppStrings {
  TranslationCatalog _catalog;

  static _AppStringsDelegate delegate(
    Map<String, RedableFile> translations,
    TranslationFormat format,
  ) =>
      _AppStringsDelegate(translations, format);

  AppStrings(Locale locale, this._catalog, this._locale)
      : _localeName = Intl.canonicalizedLocale(locale.toString());

  final String _localeName;
  final String _locale;

  static Future<AppStrings> load(
      Locale locale, RedableFile file, String _locale, TranslationFormat format,
      [String projectName = 'intl_messages']) async {
    final catalog = TranslationCatalog(projectName);
    await catalog.addTranslations([file], format: format);
    await TranslationLoader(catalog).initializeMessages(locale.toString());
    return AppStrings(locale, catalog, _locale);
  }

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ??
        AppStrings(null, null, null);
  }

  String string(String key) {
    print(_catalog.translatedMessages);
    final message = _catalog.translatedMessages[_locale]
        ?.firstWhere((message) => message.id == key);
    if (message == null) return 'String $key not found';
    return Intl.message(message.id, locale: _localeName, name: message.id);
  }
}
