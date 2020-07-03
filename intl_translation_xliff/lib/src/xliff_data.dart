import 'package:intl_translation/generate_localized.dart';

class LocaleTranslationData {
  final Map<String, TranslatedMessage> messages;

  final String locale;

  LocaleTranslationData(this.messages, {this.locale,});
}
