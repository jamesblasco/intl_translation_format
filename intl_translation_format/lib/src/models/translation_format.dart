import 'dart:typed_data';

import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_format/src/file/file_provider.dart';

import 'package:intl_translation_format/src/models/translation_catalog.dart';
import 'package:intl_translation_format/src/models/translation_template.dart';

import 'formats.dart';

typedef TranslationFormatBuilder = TranslationFormat Function();

//
//
abstract class TranslationFormat<T extends FileData> {
  const TranslationFormat();


  void parseMessagesFromFileIntoCatalog(
    List<RedeableFile> files, {
    TranslationCatalog catalog,
  });

  // From a catalog of intl template messages it creates an
  // list of abstracted files in the desired format
  List<T> buildTemplate(TranslationTemplate template);

  List<String> get supportedFileExtensions;

  bool isFileSupported(String filename) {
    for (final extension in supportedFileExtensions) {
      if (filename.endsWith('.$extension')) return true;
    }
    return false;
  }

  static TranslationFormat fromKey(
    String key, {
    Map<String, TranslationFormatBuilder> supportedFormats,
  }) {
    final formats = supportedFormats ?? defaultFormats;
    final translationFormat = formats[key]?.call();

    if (translationFormat == null) {
      throw UnsupportedFormatException(key);
    }
    return translationFormat;
  }
}

abstract class SingleLanguageFormat extends TranslationFormat<StringFileData> {
  List<String> get supportedFileExtensions => [fileExtension];
  String get fileExtension;

  Map<String, TranslatedMessage> parseFile(
    String content, {
    MessageGeneration generation,
  });

  String buildTemplateFileContent(
    TranslationTemplate catalog,
  );

  @override
  Future parseMessagesFromFileIntoCatalog(
    List<RedeableFile> files, {
    TranslationCatalog catalog,
  }) async {
    var messagesByLocale = <String, Map<String, TranslatedMessage>>{};

    // In order to group these by locale, to support multiple input files,
    // we're reading all the data eagerly, which could be a memory
    // issue for very large projects.
    for (final file in files) {
      final data = await file.readDataOfExactType<StringFileData>();;
      final locale =
          localeFromName(data.nameWithoutExtension, catalog.projectName);
      final messages = parseFile(data.contents);
      messagesByLocale.putIfAbsent(locale, () => {}).addAll(messages);
    }

    messagesByLocale.forEach((locale, messages) {
      catalog.translatedMessages
          .putIfAbsent(locale, () => [])
          .addAll(messages.values);
    });
  }

  @override
  List<StringFileData> buildTemplate(
    TranslationTemplate catalog,
  ) {
    final file = StringFileData(
      buildTemplateFileContent(catalog),
      '${catalog.projectName}_${catalog.defaultLocale}.$fileExtension',
    );
    return [file];
  }
}

abstract class SingleBinaryLanguageFormat
    extends TranslationFormat<BinaryFileData> {
  Map<String, TranslatedMessage> parseFile(Uint8List content);

  List<String> get supportedFileExtensions => [supportedFileExtension];
  String get supportedFileExtension;

  Uint8List buildTemplateFileContent(
    TranslationTemplate catalog,
  );

  @override
  Future parseMessagesFromFileIntoCatalog(
    List<RedeableFile> files, {
    TranslationCatalog catalog,
  }) async {
    var messagesByLocale = <String, Map<String, TranslatedMessage>>{};

    // In order to group these by locale, to support multiple input files,
    // we're reading all the data eagerly, which could be a memory
    // issue for very large projects.
    for (final file in files) {
      final data = await file.readDataOfExactType<BinaryFileData>();
      final locale =
          localeFromName(data.nameWithoutExtension, catalog.projectName);
      final messages = parseFile(data.bytes);
      messagesByLocale.putIfAbsent(locale, () => {}).addAll(messages);
    }

    messagesByLocale.forEach((locale, messages) {
      catalog.translatedMessages
          .putIfAbsent(locale, () => [])
          .addAll(messages.values);
    });
  }

  @override
  List<BinaryFileData> buildTemplate(
    TranslationTemplate catalog,
  ) {
    final file = BinaryFileData(
      buildTemplateFileContent(catalog),
      '${catalog.projectName}_${catalog.defaultLocale}.$supportedFileExtension',
    );
    return [file];
  }
}

String localeFromName(
  String fileName,
  String baseName,
) {
  final locale = fileName.replaceAll('${baseName}_', '');
  return locale;
}

abstract class MultipleLanguageFormat
    extends TranslationFormat<StringFileData> {
  List<String> get supportedFileExtensions => [supportedFileExtension];
  String get supportedFileExtension;

  Map<String, Map<String, TranslatedMessage>> parseFile(String content);

  String buildTemplateFileContent(
      Map<String, Map<String, Message>> messages, TranslationTemplate metadata);

  @override
  Future parseMessagesFromFileIntoCatalog(
    List<RedeableFile> files, {
    TranslationCatalog catalog,
  }) async {
    var messagesByLocale = <String, Map<String, TranslatedMessage>>{};

    // In order to group these by locale, to support multiple input files,
    // we're reading all the data eagerly, which could be a memory
    // issue for very large projects.
    for (final file in files) {
      final data = await file.readDataOfExactType<StringFileData>();
      final content = data.contents;
      final messages = parseFile(content);
      messagesByLocale.addEntries(messages.entries);
    }

    catalog.translatedMessages = {};
    messagesByLocale.forEach((locale, messages) {
      catalog.translatedMessages[locale] = messages.values.toList();
    });
  }

  @override
  List<StringFileData> buildTemplate(TranslationTemplate catalog) {
    final file = StringFileData(
      buildTemplateFileContent(
        {catalog.defaultLocale: catalog.messages},
        catalog,
      ),
      catalog.projectName + '.' + supportedFileExtension,
    );
    return [file];
  }
}

class UnsupportedFormatException implements Exception {
  String translationFormat;
  UnsupportedFormatException(this.translationFormat);

  @override
  String toString() {
    return 'This translation format is not supported:  $translationFormat';
  }
}

class BadFormatException implements Exception {
  String message;
  BadFormatException(this.message);
  @override
  String toString() {
    return message;
  }
}
