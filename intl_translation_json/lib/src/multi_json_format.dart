import 'dart:convert';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_json/intl_translation_json.dart';

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
      messagesByKey[key] ??= {};
      messagesByKey[key][catalog.defaultLocale] = messageToIcuString(message);
    });

    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(messagesByKey);
  }

  @override
  List<MessagesForLocale> parseFile(String content, String defaultLocale) {
    final json = jsonEncoder.decode(content) as Map<String, Object>;
    final messagesByLocale = <String, MessagesForLocale>{};

    foldMap<String>(json).forEach(
      (keys, value) {
        final locale = keys.last;

        final unformattedKey = keys
            .take(keys.length - 1) // Remove locale
            .reduce((string1, string2) => '$string1 $string2');
        final key = CaseFormat(Case.camelCase).format(unformattedKey);

        final message = BasicTranslatedMessage(key, IcuMessage.fromIcu(value));
        messagesByLocale[locale] ??= MessagesForLocale({}, locale: locale);
        messagesByLocale[locale].messages[key] = message;
      },
    );
    return messagesByLocale.values.toList();
  }
}
