import 'dart:convert';
import 'dart:io';
import 'package:intl_translation_arb/intl_translation_arb.dart';
import 'package:path/path.dart' as path;

import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'package:intl_translation/src/icu_parser.dart';
import 'package:intl_translation_format/intl_translation_format.dart';

class ArbFormat extends TranslationFormat {
  static const String key = 'arb';

  @override
  List<String> get supportedFileExtensions => ['arb'];


  String build(
    Map<String, MainMessage> messages,
    Map<String, String> metadata, {
    bool suppressMetaData = false,
    bool includeSourceText = true,
  }) {
    Map<String, dynamic> allMessages = {};
    if (metadata['locale'] != null) {
      allMessages["@@locale"] = metadata['locale'];
    }
    if (metadata['last_modified'] != null) {
      allMessages["@@last_modified"] = metadata['last_modified'];
    }

    messages.forEach((k, v) => allMessages.addAll(_toARB(v,
        suppressMetaData: suppressMetaData,
        includeSourceText: includeSourceText)));

    var encoder = new JsonEncoder.withIndent("  ");
    return encoder.convert(allMessages);
  }

  Map<String, dynamic> _toARB(
    MainMessage message, {
    bool suppressMetaData = false,
    bool includeSourceText = true,
  }) {
    if (message.messagePieces.isEmpty) return null;
    Map<String, dynamic> out = {};
    out[message.name] = ICUParser().icuMessageToString(message);

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

  
  // Parse method
  @override
  TranslationCatalog parse(
      Map<String, MainMessage> messages, List<String> files,
      {String defaultLocale, MessageGeneration messageGeneration}) {
    final generation = messageGeneration ?? MessageGeneration();

    var catalog =
        TranslationCatalog(); //Todo: We could save the state of this class to detect in the future what translations have been changed
    catalog.mainMessages = messages;
    catalog.defaultLocal = defaultLocale;

    var messagesByLocale = <String, List<Map>>{};

    // In order to group these by locale, to support multiple input files,
    // we're reading all the data eagerly, which could be a memory
    // issue for very large projects.
    for (var arg in files) {
      _loadData(arg, messagesByLocale, generation);
    }

    catalog.translatedMessages = {};
    messagesByLocale.forEach((locale, messages) {
      catalog.translatedMessages[locale] =
          _generateLocaleTranslation(messages, generation);

      print(catalog.translatedMessages[locale]);
    });

    return catalog;
  }
}

List<TranslatedMessage> _generateLocaleTranslation(
    List<Map> localeData, MessageGeneration generation) {
  List<TranslatedMessage> translations = [];
  for (var jsonTranslations in localeData) {
    jsonTranslations.forEach((id, messageData) {
      TranslatedMessage message = recreateIntlObjects(id, messageData);
      if (message != null) {
        translations.add(message);
      }
    });
  }
  return translations;
}

const jsonDecoder = const JsonCodec();

_loadData(String filename, Map<String, List<Map>> messagesByLocale,
    MessageGeneration generation) {
  var file = File(filename);
  var src = file.readAsStringSync();
  var data = jsonDecoder.decode(src);
  var locale = data["@@locale"] ?? data["_locale"];
  if (locale == null) {
    // Get the locale from the end of the file name. This assumes that the file
    // name doesn't contain any underscores except to begin the language tag
    // and to separate language from country. Otherwise we can't tell if
    // my_file_fr.arb is locale "fr" or "file_fr".
    var name = path.basenameWithoutExtension(file.path);
    locale = name.split("_").skip(1).join("_");
    print("No @@locale or _locale field found in $name, "
        "assuming '$locale' based on the file name.");
  }
  messagesByLocale.putIfAbsent(locale, () => []).add(data);
  generation.allLocales.add(locale);
}

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
