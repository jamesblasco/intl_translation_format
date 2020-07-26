import 'package:intl_translation_format/intl_translation_format.dart';

class LocaleTranslationData {
  final Map<String, BasicTranslatedMessage> messages;

  final String locale;

  LocaleTranslationData(this.messages, {this.locale,});
}
