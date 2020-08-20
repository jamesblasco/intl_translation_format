library intl_translation_arb;

import 'dart:convert';
import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'package:intl_translation/src/icu_parser.dart';
import 'package:intl_translation/src/arb_generation.dart';
import 'package:intl_translation_format/intl_translation_format.dart';

class ArbFormat extends MonoLingualFormat {
  static const String key = 'arb';

  @override
  String get fileExtension => 'arb';

  @override
  String generateTemplateFile(
    TranslationTemplate catalog, {
    bool suppressMetaData = false,
    bool includeSourceText = true,
  }) {
    final allMessages = <String, dynamic>{
      if (catalog.defaultLocale != null) "@@locale": catalog.defaultLocale,
      if (catalog.lastModified != null)
        "@@last_modified": catalog.lastModified.toIso8601String(),
    };

    catalog.messages.forEach((k, v) {
      allMessages.addAll(
        toARB(v,
            supressMetadata: suppressMetaData,
            includeSourceText: includeSourceText),
      );
    });

    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(allMessages);
  }

  @override
  MessagesForLocale parseFile(
    String content, {
    MessageGeneration generation,
  }) {
    Map<String, BasicTranslatedMessage> messagesFromJson(
      Map<String, dynamic> data,
    ) {
      final translations = <String, BasicTranslatedMessage>{};

      data.forEach((id, messageData) {
        final message = recreateIntlObjects(id, messageData);
        if (message != null) {
          translations[id] = message;
        }
      });

      return translations;
    }

    final data = _jsonDecoder.decode(content);
    final messages = messagesFromJson(data);
    return MessagesForLocale(messages, locale: data['@@locale']);
  }
}

const _jsonDecoder = const JsonCodec();

/// Regenerate the original IntlMessage objects from the given [data]. For
/// things that are messages, we expect [id] not to start with "@" and
/// [data] to be a String. For metadata we expect [id] to start with "@"
/// and [data] to be a Map or null. For metadata we return null.
BasicTranslatedMessage recreateIntlObjects(String id, data) {
  if (id.startsWith("@")) return null;
  if (data == null) return null;
  var parsed = _pluralAndGenderParser.parse(data).value;
  if (parsed is LiteralString && parsed.string.isEmpty) {
    parsed = _plainParser.parse(data).value;
  }
  return BasicTranslatedMessage(id, parsed);
}

final _pluralAndGenderParser = IcuParser().message;
final _plainParser = IcuParser().nonIcuMessage;
