import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_json/intl_translation_json.dart';

class JsonFormat extends MonoLingualFormat {
  static const key = 'json';

  @override
  String get fileExtension => 'json';

  @override
  String generateTemplateFile(
    TranslationTemplate catalog,
  ) {
    final messages = catalog.messages;
    var json = '{\n';
    messages.forEach((key, value) {
      final message = messageToIcuString(value);
      json += '  "$key": "$message",\n';
    });
    if (messages.isNotEmpty) json = json.substring(0, json.length - 2) + '\n';
    json += '}';
    return json;
  }

  @override
  MessagesForLocale parseFile(
    String content, {
    MessageGeneration generation,
  }) {
    final json = jsonEncoder.decode(content) as Map<String, Object>;
    final messages = <String, BasicTranslatedMessage>{};
    foldMap<String>(json).forEach(
      (keys, value) {
        final unformattedKey =
            keys.reduce((string1, string2) => '$string1 $string2');

        final key = CaseFormat(Case.camelCase).format(unformattedKey);

        final message = BasicTranslatedMessage(key, IcuMessage.fromIcu(value));
        messages[key] = message;
      },
    );
    return MessagesForLocale(messages);
  }
}
