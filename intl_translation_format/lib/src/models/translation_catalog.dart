import 'dart:io';

import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'package:path/path.dart' as path;

import '../../intl_translation_format.dart';

class TranslationFile {
  final String name;
  final String content;
  final String fileExtension;
  final List<int> bytes;

  TranslationFile({
    this.name,
    this.fileExtension,
    this.content,
  }) : bytes = null;

  TranslationFile.binary({
    this.name,
    this.fileExtension,
    this.bytes,
  }) : content = null;

  String get fileName => '${name}.${fileExtension}';

  void writeSyncIn(String dir) {
    final file = File(path.join(dir, fileName));
    if (content != null)
      file.writeAsStringSync(content);
    else if (bytes != null) file.writeAsBytesSync(bytes);
  }

  factory TranslationFile.readSync(
    File file, {
    FileType type = FileType.text,
  }) {
    final name = path.basenameWithoutExtension(file.path);
    final fileExtension = path.extension(file.path).replaceAll('.', '');
    if (type == FileType.text) {
      final content = file.readAsStringSync();
      return TranslationFile(
          name: name, fileExtension: fileExtension, content: content);
    } else {
      final bytes = file.readAsBytesSync();
      return TranslationFile.binary(
        name: name,
        fileExtension: fileExtension,
        bytes: bytes,
      );
    }
  }

  
}

class TranslationCatalog {
  String projectName;
  String defaultLocal;
  DateTime lastModified;

  Map<String, MainMessage> mainMessages = {};
  Map<String, List<TranslatedMessage>> translatedMessages = {};
  Map<String, String> metadata;

  List<String> get locales => translatedMessages?.keys?.toList() ?? [];

  TranslationCatalog();

  TranslationCatalog.fromTemplate(TranslationTemplate template) {
    defaultLocal = template.defaultLocal;
    lastModified = template.lastModified;
    mainMessages = template.messages;
    projectName = projectName;
  }

  //Todo: This doesn't add, it creates a new TransationCatalog
   addTranslationsFromFiles(
      List<TranslationFile> translationFiles,{ TranslationFormat format}) {
   return format.parse(mainMessages, translationFiles,
        defaultLocale: defaultLocal);
        
  }

  Map<String, String> generateDartMessages(
      {MessageGeneration messageGeneration}) {
    final generation = messageGeneration ?? MessageGeneration();
    generation.allLocales = locales.toSet();

    final files = <String, String>{};
    final prefix = generation.generatedFilePrefix;

    translatedMessages.forEach((locale, translation) {
      final content =
          generation.generateIndividualMessageFileContent(locale, translation);
      files['${prefix}messages_$locale.dart'] = content;
    });

    final mainFile = generation.generateMainImportFile();
    files['${prefix}messages_all.dart'] = mainFile;
    return files;
  }
}

class TranslationTemplate {
  final projectName;

  String defaultLocal;
  DateTime lastModified;

  Map<String, MainMessage> messages = {};

  TranslationTemplate.fromDartFiles(
    this.projectName, {
    String locale,
    Map<String, String> dartFiles,
    ExtractConfig config,
  }) {
    final extraction = MessageExtraction();
    config?.setToMessageExtraction(extraction);

    if (locale != null) {
      defaultLocal = locale;
    }
    if (!extraction.suppressLastModified) {
      lastModified = DateTime.now();
    }

    messages = _extractMessages(dartFiles, extraction);
  }

  static Map<String, MainMessage> _extractMessages(
      Map<String, String> dartFiles, MessageExtraction extraction) {
    Map<String, MainMessage> allMessages = {};
    for (final entry in dartFiles.entries) {
      var messages = extraction.parseFileContent(entry.value, entry.key, false);
      allMessages.addAll(messages);
    }

    return allMessages;
  }

  List<TranslationFile> extractTemplate(TranslationFormat format) {
    return format.buildTemplate(this);
  }
}
