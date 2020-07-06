import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_ota/intl_translation_ota.dart';

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  final Map<String, FileProvider> translations;
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
    //Improve this
    return translations.length != translations.length;
  }
}

class AppStrings {
  TranslationCatalog _catalog;

  static _AppStringsDelegate delegate(
    Map<String, RedeableFile> translations,
    TranslationFormat format,
  ) =>
      _AppStringsDelegate(translations, format);

  AppStrings(Locale locale, this._catalog, this._locale)
      : _localeName = Intl.canonicalizedLocale(locale.toString());

  final String _localeName;
  final String _locale;
  static Future<AppStrings> load(Locale locale, FileProvider file,
      String _locale, TranslationFormat format) async {
    final catalog = TranslationCatalog('intl');
    await catalog.addTranslations([file], format: format);
    await TranslationLoader(catalog).initializeMessages(locale.toString());
    return AppStrings(locale, catalog, _locale);
  }

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ?? AppStrings(null, null, null);
  }

  String string(String key) {
    if(_catalog == null) return 'String $key not found';
    final message = _catalog.translatedMessages[_locale]
        ?.firstWhere((message) => message.id == key);
    if (message == null) return 'String $key not found';
    return Intl.message(message.id, locale: _localeName, name: message.id);
  }
}
