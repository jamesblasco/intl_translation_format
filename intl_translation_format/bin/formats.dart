

import 'package:intl_translation_arb/arb_format.dart';
import 'package:intl_translation_json/intl_translation_json.dart';
import 'package:intl_translation_multi_language_json/intl_translation_multi_language_json.dart';


final availableFormats = {
  ArbFormat.key: () => ArbFormat(),
  JsonFormat.key: () => JsonFormat(),
  MultiJsonFormat.key: () => MultiJsonFormat(),
};
