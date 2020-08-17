library intl_translation_json;

import 'package:intl_translation_format/intl_translation_format.dart';

export 'src/json_format.dart';
export 'src/multi_json_format.dart';
export 'src/json_parser.dart';

final jsonFormats = <String, TranslationFormatBuilder>{
  JsonFormat.key: () => JsonFormat(),
  MultiJsonFormat.key: () => MultiJsonFormat(),
};
