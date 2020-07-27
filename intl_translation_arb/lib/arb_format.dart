import 'dart:convert';
import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'package:intl_translation/src/icu_parser.dart';
import 'package:intl_translation_format/intl_translation_format.dart';

class ArbFormat extends SingleLanguageFormat {
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
        _toARB(v,
            suppressMetaData: suppressMetaData,
            includeSourceText: includeSourceText),
      );
    });

    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(allMessages);
  }

  @override
  Map<String, BasicTranslatedMessage> parseFile(
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

    final data = jsonDecoder.decode(content);
    return messagesFromJson(data);
  }
}

// TODO: Move from bin to lib in intl_translation and remove here

Map<String, dynamic> _toARB(
  MainMessage message, {
  bool suppressMetaData = false,
  bool includeSourceText = true,
}) {
  if (message.messagePieces.isEmpty) return null;
  final out = <String, dynamic>{};

  out[message.name] = icuMessageToString(message);

  if (!suppressMetaData) {
    out["@${message.name}"] = _arbMetadata(message);

    if (includeSourceText) {
      out["@${message.name}"]["source_text"] = out[message.name];
    }
  }

  return out;
}

Map _arbMetadata(MainMessage message) {
  var out = {};
  var desc = message.description;
  if (desc != null) {
    out["description"] = desc;
  }
  out["type"] = "text";
  var placeholders = {};
  for (var arg in message.arguments) {
    addArgumentFor(message, arg, placeholders);
  }
  out["placeholders"] = placeholders;
  return out;
}

void addArgumentFor(MainMessage message, String arg, Map result) {
  var extraInfo = {};
  if (message.examples != null && message.examples[arg] != null) {
    extraInfo["example"] = message.examples[arg];
  }
  result[arg] = extraInfo;
}

const jsonDecoder = const JsonCodec();

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
  return new BasicTranslatedMessage(id, parsed);
}

final _pluralAndGenderParser = new IcuParser().message;
final _plainParser = new IcuParser().nonIcuMessage;
