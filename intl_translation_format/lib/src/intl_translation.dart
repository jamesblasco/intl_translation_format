import 'dart:io';
import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'models/translation_catalog.dart';
import 'models/translation_format.dart';

Map<String, List<MainMessage>> originMessages;

class IntlTranslation {
  @deprecated
  static String extractMessages(
      {TranslationFormat format,
      String locale,
      List<String> dartFiles,
      MessageExtraction messageExtraction}) {
    final extraction = messageExtraction ?? MessageExtraction();

    Map<String, String> metadata = {};
    if (locale != null) {
      metadata["locale"] = locale;
    }
    if (!extraction.suppressLastModified) {
      metadata["last_modified"] = DateTime.now().toIso8601String();
    }

    final messages = _extractMessages(dartFiles, extraction);

    return format.build(messages, metadata);
  }

  static Map<String, String> generateTranslations(
      {TranslationFormat format,
      String locale,
      List<String> dartFiles,
      List<String> translationFiles,
      String targetDir,
      MessageExtraction messageExtraction,
      MessageGeneration messageGeneration}) {
    final extraction = messageExtraction ?? MessageExtraction();
    final generation = messageGeneration ?? MessageGeneration();

    final messages = _extractMessages(dartFiles, extraction);

    //Todo: Check why originMessages is needed
    var allMessages =
        dartFiles.map((each) => extraction.parseFile(new File(each), false));

    originMessages = new Map();
    for (var eachMap in allMessages) {
      eachMap.forEach(
          (key, value) => originMessages.putIfAbsent(key, () => []).add(value));
    }

    final translation =
        format.parse(messages, translationFiles, defaultLocale: locale);

    generation.allLocales = translation.locales.toSet();

    final files = <String, String>{};
    final prefix = generation.generatedFilePrefix;

    translation.translatedMessages.forEach((locale, translation) {
      final content = generation.generateIndividualMessageFileContent(
          locale, translation, targetDir);
      files['${prefix}messages_$locale.dart'] = content;
    });

    final mainFile = generation.generateMainImportFile();
    files['${prefix}messages_all.dart'] = mainFile;
    return files;
  }

  static Map<String, MainMessage> _extractMessages(
    List<String> dartFiles,
    MessageExtraction extraction,
  ) {
    Map<String, MainMessage> allMessages = {};
    for (var arg in dartFiles) {
      var messages = extraction.parseFile(File(arg), false);
      allMessages.addAll(messages);
    }

    return allMessages;
  }
}

/// A TranslatedMessage that just uses the name as the id and knows how to look
/// up its original messages in our [messages].
class BasicTranslatedMessage extends TranslatedMessage {
  BasicTranslatedMessage(String name, translated) : super(name, translated);

  List<MainMessage> get originalMessages => (super.originalMessages == null)
      ? _findOriginals()
      : super.originalMessages;

  // We know that our [id] is the name of the message, which is used as the
  //key in [messages].
  List<MainMessage> _findOriginals() => originalMessages = originMessages[id];
}
