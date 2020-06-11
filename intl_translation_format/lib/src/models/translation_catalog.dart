import 'dart:io';

import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';

import 'package:intl_translation_format/src/intl_translation.dart';

import '../../intl_translation_format.dart';



class FormatFile {
  final String basename;
  final String locale;
  final String content;
  final String extension;

  FormatFile(this.basename, this.locale, this.content, this.extension);
}


class TranslationCatalog {
  String defaultLocal;

  Map<String, MainMessage> mainMessages;
  Map<String, List<TranslatedMessage>> translatedMessages;
  Map<String, String> metadata;

  List<String> get locales => translatedMessages?.keys?.toList() ?? [];
}

class TranslationCatalogTemplate {
  String defaultLocal;

  Map<String, MainMessage> mainMessages;
  Map<String, String> metadata = {};

  TranslationCatalogTemplate.fromDartFiles({
    String locale,
    Map<String, String> dartFiles,
    ExtractConfig config,
  }) {
    final extraction = MessageExtraction();
    config?.setToMessageExtraction(extraction);

   
    if (locale != null) {
      metadata["locale"] = locale;
      defaultLocal = locale;
    }
    if (!extraction.suppressLastModified) {
      metadata["last_modified"] = DateTime.now().toIso8601String();
    }

    mainMessages = _extractMessages(dartFiles, extraction);
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

  String generateTemplateFile(TranslationFormat format) {
    
    return format.build(mainMessages, metadata);
  }
}
