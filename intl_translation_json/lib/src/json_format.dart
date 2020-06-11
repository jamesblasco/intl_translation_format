import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';

import 'package:intl_translation_format/intl_translation_format.dart';

import 'json_parser.dart';

class JsonFormat extends SingleLanguageFormat {
  static const key = 'json';

  @override
  List<String> get supportedFileExtensions => ['json'];

  @override
  String buildTemplate(
    Map<String, MainMessage> messages,
    Map<String, String> metadata,
  ) {
    var json = '{\n';
    messages.forEach((key, value) {
      final message = ICUParser().icuMessageToString(value);
      json += '  "$key": "$message",\n';
    });
    if (messages.isNotEmpty) json = json.substring(0, json.length - 2) + '\n';
    json += '}';
    return json;
  }

  @override
  Map<String, TranslatedMessage> parseFile(String content) {
    final values = SimpleJsonParser().parser.parse(content);

    if (values.isFailure) throw BadFormatException(values.message);
    return values.value.map((key, value) {
      final message = BasicTranslatedMessage(key, Message.from(value, null));
      return MapEntry(key, message);
    });
  }
}

class BadFormatException implements Exception {
  String message;
  BadFormatException(this.message);
}
