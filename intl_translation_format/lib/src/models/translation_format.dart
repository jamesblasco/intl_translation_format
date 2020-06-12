import 'dart:io';
import 'dart:typed_data';

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

enum FileType { text, binary }

abstract class TranslationFormat {
  const TranslationFormat();

  TranslationCatalog parse(
    Map<String, MainMessage> messages,
    List<TranslationFile> files, {
    String defaultLocale,
    MessageGeneration messageGeneration,
  });

  // From a catalog of intl template messages it creates an
  // list of abstracted files in the desired format
  List<TranslationFile> buildTemplate(TranslationTemplate catalog);

  List<String> get supportedFileExtensions;

  FileType get fileType => FileType.text;

  bool isFileSupported(String filename) {
    for (final extension in supportedFileExtensions) {
      if (filename.endsWith('.$extension')) return true;
    }
    return false;
  }

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
  Map<String, TranslatedMessage> parseFile(String content, {MessageGeneration generation,});

  List<String> get supportedFileExtensions => [supportedFileExtension];
  String get supportedFileExtension;

  String buildTemplateFileContent(
    TranslationTemplate catalog,
  );

  TranslationCatalog parse(
    Map<String, MainMessage> messages,
    List<TranslationFile> files, {
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
    for (final file in files) {
      _loadData(file, messagesByLocale, generation);
    }

    catalog.translatedMessages = {};
    messagesByLocale.forEach((locale, messages) {
      catalog.translatedMessages[locale] = messages.values.toList();
    });

    return catalog;
  }

  @override
  List<TranslationFile> buildTemplate(
    TranslationTemplate catalog,
  ) {
    final file = TranslationFile(
      content: buildTemplateFileContent(catalog),
      name: '${catalog.projectName}_${catalog.defaultLocal}',
      fileExtension: supportedFileExtension,
    );
    return [file];
  }

  void _loadData(
    TranslationFile file,
    Map<String, Map<String, TranslatedMessage>> messagesByLocale,
    MessageGeneration generation,
  ) {
    final locale = localeFromName(file.name);
    final messages = parseFile(file.content);
    messagesByLocale.putIfAbsent(locale, () => {}).addAll(messages);
    generation.allLocales.add(locale);
  }
}

abstract class SingleBinaryLanguageFormat extends TranslationFormat {
  Map<String, TranslatedMessage> parseFile(List<int> content);

  List<String> get supportedFileExtensions => [supportedFileExtension];
  String get supportedFileExtension;

  FileType get fileType => FileType.binary;

  Uint8List buildTemplateFileContent(
    TranslationTemplate catalog,
  );

  TranslationCatalog parse(
    Map<String, MainMessage> messages,
    List<TranslationFile> files, {
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
    for (final file in files) {
      _loadData(file, messagesByLocale, generation);
    }

    catalog.translatedMessages = {};
    messagesByLocale.forEach((locale, messages) {
      catalog.translatedMessages[locale] = messages.values.toList();
    });

    return catalog;
  }

  @override
  List<TranslationFile> buildTemplate(
    TranslationTemplate catalog,
  ) {
    final file = TranslationFile.binary(
      bytes: buildTemplateFileContent(catalog),
      name: '${catalog.projectName}_${catalog.defaultLocal}',
      fileExtension: supportedFileExtension,
    );
    return [file];
  }

  void _loadData(
    TranslationFile file,
    Map<String, Map<String, TranslatedMessage>> messagesByLocale,
    MessageGeneration generation,
  ) {
    final bytes = file.bytes;
    final locale = localeFromName(file.name);
    final messages = parseFile(bytes);
    messagesByLocale.putIfAbsent(locale, () => {}).addAll(messages);
    generation.allLocales.add(locale);
  }
}

String localeFromName(
  String fileName, {
  String baseName = kBaseName,
}) {
  final locale = fileName.replaceAll('${baseName}messages_', '');
  print(locale);
  return locale;
}

const kBaseName = 'intl_';

abstract class MultipleLanguageFormat extends TranslationFormat {
  List<String> get supportedFileExtensions => [supportedFileExtension];
  String get supportedFileExtension;

  Map<String, Map<String, TranslatedMessage>> parseFile(String content);

  String buildTemplateFileContent(
      Map<String, Map<String, Message>> messages, TranslationTemplate metadata);

  TranslationCatalog parse(
      Map<String, MainMessage> messages, List<TranslationFile> files,
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
    for (final file in files) {
      _loadData(file, messagesByLocale, generation);
    }

    catalog.translatedMessages = {};
    messagesByLocale.forEach((locale, messages) {
      catalog.translatedMessages[locale] = messages.values.toList();
    });

    return catalog;
  }

  @override
  List<TranslationFile> buildTemplate(TranslationTemplate catalog) {
    final file = TranslationFile(
      content: buildTemplateFileContent(
        {catalog.defaultLocal: catalog.messages},
        catalog,
      ),
      name: catalog.projectName,
      fileExtension: supportedFileExtension,
    );
    return [file];
  }

  void _loadData(
      TranslationFile file,
      Map<String, Map<String, TranslatedMessage>> messagesByLocale,
      MessageGeneration generation) {
    final content = file.content;
    final messages = parseFile(content);
    messagesByLocale.addEntries(messages.entries);
    generation.allLocales.addAll(messagesByLocale.keys);
  }
}
