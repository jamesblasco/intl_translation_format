import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';

import 'package:intl_translation_format/src/intl_translation.dart';


class TranslationCatalog {
  String defaultLocal;

  Map<String, MainMessage> mainMessages;
  Map<String, List<TranslatedMessage>> translatedMessages;
  Map<String, String> metadata;

  List<String> get locales => translatedMessages?.keys?.toList() ?? [];
}

