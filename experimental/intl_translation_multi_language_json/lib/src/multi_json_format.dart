import 'dart:convert';

import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';

import 'package:intl_translation_format/intl_translation_format.dart';

import '../intl_translation_multi_language_json.dart';


class MultiJsonFormat extends MultipleLanguageFormat {
  static const key = 'multi_language_json';

  @override
  String get supportedFileExtension => 'json';

  @override
  String buildTemplateFileContent(
    Map<String, Map<String, Message>> messages,
    TranslationTemplate catalog,
  ) {
    final messagesByKey = <String, Map<String, String>>{};

    messages.forEach((locale, messages) {
      messages.forEach((key, message) {
        messagesByKey.putIfAbsent(key, () => {});
        messagesByKey[key][locale] = ICUParser().icuMessageToString(message);
      });
    });

    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(messagesByKey);
  }

  @override
  Map<String, Map<String, BasicTranslatedMessage>> parseFile(String content) {
    final values = MultipleLanguageJsonParser().parser.parse(content);

    if (values.isFailure) throw BadFormatException(values.message);

    var messagesByLocale = <String, Map<String, BasicTranslatedMessage>>{};

    values.value.forEach((key, messages) {
      messages.forEach((locale, messageString) {
        messagesByLocale.putIfAbsent(locale, () => {});
        final message =
            BasicTranslatedMessage(key, Message.from(messageString, null));
        messagesByLocale[locale][key] = message;
      });
    });
    return messagesByLocale;
  }
}