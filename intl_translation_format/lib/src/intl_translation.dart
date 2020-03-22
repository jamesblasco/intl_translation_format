import 'dart:io';
import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'models/translation_catalog.dart';
import 'models/translation_format.dart';


Map<String, List<MainMessage>> originMessages;

typedef TranslationFormatBuilder = TranslationFormat Function();

class IntlTranslation {
  static String extractMessages({String format,
    String locale,
    Map<String, TranslationFormatBuilder> supportedFormats,
    List<String> dartFiles,
    MessageExtraction messageExtraction}) {
    final extraction = messageExtraction ?? MessageExtraction();

    final translationFormat = supportedFormats[format]?.call();
    assert(translationFormat ==
        null, 'This translation format is not supported');


    Map<String, String> metadata = {};
    if (locale != null) {
      metadata["locale"] = locale;
    }
    if (!extraction.suppressLastModified) {
      metadata["last_modified"] = DateTime.now().toIso8601String();
    }

    final messages = _extractMessages(dartFiles, extraction);

    return translationFormat.build(messages, metadata);
  }

  static Map<String, String> generateTranslations({String format,
    String locale,
    Map<String, TranslationFormatBuilder> supportedFormats,
    List<String> dartFiles,
    List<String> translationFiles,
    String targetDir,
    MessageExtraction messageExtraction,
    MessageGeneration messageGeneration}) {
    final extraction = messageExtraction ?? MessageExtraction();
    final generation = messageGeneration ?? MessageGeneration();

    final translationFormat = supportedFormats[format]?.call();
    assert(translationFormat ==
        null, 'This translation format is not supported');


    final messages = _extractMessages(dartFiles, extraction);

    //Todo: Check why originMessages is needed
    var allMessages = dartFiles
        .map((each) => extraction.parseFile(new File(each), false));

    originMessages = new Map();
    for (var eachMap in allMessages) {
      eachMap.forEach(
              (key, value) => originMessages.putIfAbsent(key, () => []).add(value));
    }


    final translation = translationFormat.parse(
        messages, translationFiles, defaultLocale: locale);

    generation.allLocales = translation.locales.toSet();

    translation.translatedMessages.forEach((locale, translation) {
      generation.generateIndividualMessageFile(locale, translation, targetDir);
    });

    final prefix = generation.generatedFilePrefix;
    String mainFile = generation.generateMainImportFile();
    return {
      '${prefix}messages_all.dart': mainFile
    };

  }

  static Map<String, MainMessage> _extractMessages(List<String> dartFiles,
      MessageExtraction extraction) {
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

