import 'package:intl_translation/generate_localized.dart';

import 'package:intl_translation_format/intl_translation_format.dart';

import 'json_parser.dart';

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
    final values = SimpleJsonParser().parser.parse(content);
    if (values.isFailure) throw BadFormatException(values.message);
    final messages = values.value.map((key, value) {
      final message = BasicTranslatedMessage(key, IcuMessage.fromIcu(value));
      return MapEntry(key, message);
    });
    return MessagesForLocale(messages);
  }
}
