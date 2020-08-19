import 'dart:convert';


import 'package:intl_translation_format/intl_translation_format.dart';

class MultiJsonFormat extends MultiLingualFormat {
  static const key = 'multi_json';

  @override
  String get fileExtension => 'json';

  @override
  String generateTemplateFile(
    TranslationTemplate catalog,
  ) {
    final messagesByKey = <String, Map<String, String>>{};
  
    catalog.messages.forEach((key, message) {
        messagesByKey.putIfAbsent(key, () => {});
        messagesByKey[key][catalog.defaultLocale] = messageToIcuString(message);
    });
    
    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(messagesByKey);
  }

  @override
  List<MessagesForLocale> parseFile(String content) {
    final values = MultipleLanguageJsonParser().parser.parse(content);

    if (values.isFailure) throw BadFormatException(values.message);

    final messagesByLocale = <String, Map<String, BasicTranslatedMessage>>{};
  
    values.value.forEach((key, messages) {
      messages.forEach((locale, messageString) {
        messagesByLocale.putIfAbsent(locale, () => {});
        final message =
            BasicTranslatedMessage(key, IcuMessage.fromIcu(messageString));
        messagesByLocale[locale][key] = message;
      });
    });

    return messagesByLocale.entries.map(
      (e) => MessagesForLocale(e.value, locale: e.key),
    ).toList();
  }
}
