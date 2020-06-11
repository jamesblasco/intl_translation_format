import 'dart:io';

import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'package:intl_translation_format/intl_translation_format.dart';

import 'package:intl_translation_format/src/models/translation_catalog.dart';

import 'package:path/path.dart' as path;

class UnsupportedFormatException implements Exception {
  String translationFormat;
  UnsupportedFormatException(this.translationFormat);

  @override
  String toString() {
    return 'This translation format is not supported:  $translationFormat';
  }
}

typedef TranslationFormatBuilder = TranslationFormat Function();

abstract class TranslationFormat {
  List<String> get supportedFileExtensions;

  bool isFileSupported(String filename) {
    for (final extension in supportedFileExtensions) {
      if (filename.endsWith('.$extension')) return true;
    }
    return false;
  }

  const TranslationFormat();

  TranslationCatalog parse(
    Map<String, MainMessage> messages,
    List<String> files, {
    String defaultLocale,
    MessageGeneration messageGeneration,
  });

  String build(
    Map<String, MainMessage> messages,
    Map<String, String> metadata,
  );

  static TranslationFormat fromFormat({
    String format,
    Map<String, TranslationFormatBuilder> supportedFormats,
  }) {
    final translationFormat = supportedFormats[format]?.call();
    if (translationFormat == null) throw UnsupportedFormatException(format);
    return translationFormat;
  }
}

abstract class SingleLanguageFormat extends TranslationFormat {
  Map<String, TranslatedMessage> parseFile(String content);

  String buildTemplate(
    Map<String, MainMessage> messages,
    Map<String, String> metadata,
  );

  TranslationCatalog parse(
    Map<String, MainMessage> messages,
    List<String> files, {
    String defaultLocale,
    MessageGeneration messageGeneration,
  }) {
    final generation = messageGeneration ?? MessageGeneration();

    var catalog =
        TranslationCatalog(); //Todo: We could save the state of this class to detect in the future what translations have been changed
    catalog.mainMessages = messages;
    catalog.defaultLocal = defaultLocale;

    var messagesByLocale = <String, Map<String, TranslatedMessage>>{};

    // In order to group these by locale, to support multiple input files,
    // we're reading all the data eagerly, which could be a memory
    // issue for very large projects.
    for (final name in files) {
      _loadData(name, messagesByLocale, generation);
    }

    catalog.translatedMessages = {};
    messagesByLocale.forEach((locale, messages) {
      catalog.translatedMessages[locale] = messages.values.toList();
    });

    return catalog;
  }

  @override
  String build(
    Map<String, MainMessage> messages,
    Map<String, String> metadata,
  ) {
    return buildTemplate(messages, metadata);
  }

  void _loadData(
    String filename,
    Map<String, Map<String, TranslatedMessage>> messagesByLocale,
    MessageGeneration generation,
  ) {
    final file = File(filename);
    final content = File(filename).readAsStringSync();
    final locale = localeFromFile(file);
    final messages = parseFile(content);
    messagesByLocale.putIfAbsent(locale, () => {}).addAll(messages);
    generation.allLocales.add(locale);
  }

  String localeFromFile(
    File file, {
    String baseName = kBaseName,
  }) {
    final name = path.basenameWithoutExtension(file.path);
    print(name);
    final locale = name.replaceAll('${baseName}messages_', '');
    print(locale);
    return locale;
  }
}

const kBaseName = 'intl_';

abstract class MultipleLanguageFormat extends TranslationFormat {
  Map<String, Map<String, TranslatedMessage>> parseFile(String content);

  String buildTemplate(
      Map<String, Map<String, Message>> messages, Map<String, String> metadata);

  TranslationCatalog parse(
      Map<String, MainMessage> messages, List<String> files,
      {String defaultLocale, MessageGeneration messageGeneration}) {
    final generation = messageGeneration ?? MessageGeneration();

    var catalog =
        TranslationCatalog(); //Todo: We could save the state of this class to detect in the future what translations have been changed
    catalog.mainMessages = messages;
    catalog.defaultLocal = defaultLocale;

    var messagesByLocale = <String, Map<String, TranslatedMessage>>{};

    // In order to group these by locale, to support multiple input files,
    // we're reading all the data eagerly, which could be a memory
    // issue for very large projects.
    for (final name in files) {
      _loadData(name, messagesByLocale, generation);
    }

    catalog.translatedMessages = {};
    messagesByLocale.forEach((locale, messages) {
      catalog.translatedMessages[locale] = messages.values.toList();
    });

    return catalog;
  }

  @override
  String build(
      Map<String, MainMessage> messages, Map<String, String> metadata) {
    return buildTemplate({"en": messages}, metadata);
  }

  void _loadData(
      String filename,
      Map<String, Map<String, TranslatedMessage>> messagesByLocale,
      MessageGeneration generation) {
    final content = File(filename).readAsStringSync();
    final messages = parseFile(content);
    messagesByLocale.addEntries(messages.entries);
    generation.allLocales.addAll(messagesByLocale.keys);
  }

  String localeFromFile(File file, {String baseName = kBaseName}) {
    final name = path.basenameWithoutExtension(file.path);
    print(file.path);
    final locale = name.replaceAll('${baseName}messages', '');

    return locale;
  }
}
