

import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';

import 'package:intl_translation_format/src/intl_translation.dart';
import 'package:intl_translation_format/src/models/translation_catalog.dart';


abstract class TranslationFormat {
  TranslationCatalog parse(
      Map<String, MainMessage> messages, List<String> files,
      {String defaultLocale}) {
    throw UnimplementedError();
  }

  String build(
      Map<String, MainMessage> messages, Map<String, String> metadata) {
    throw UnimplementedError();
  }
}
