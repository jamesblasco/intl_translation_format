

import 'package:intl_translation_arb/arb_format.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_gettext/intl_translation_gettext.dart';
import 'package:intl_translation_json/intl_translation_json.dart';
import 'package:intl_translation_multi_language_json/intl_translation_multi_language_json.dart';
import 'package:intl_translation_strings/intl_translation_strings.dart';
import 'package:intl_translation_xliff/intl_translation_xliff.dart';

export 'package:intl_translation_arb/arb_format.dart';
export 'package:intl_translation_gettext/intl_translation_gettext.dart';
export 'package:intl_translation_json/intl_translation_json.dart';
export 'package:intl_translation_multi_language_json/intl_translation_multi_language_json.dart';
export 'package:intl_translation_strings/intl_translation_strings.dart';
export 'package:intl_translation_xliff/intl_translation_xliff.dart';


final defaultFormats = <String, TranslationFormatBuilder>{
  ArbFormat.key: () => ArbFormat(),
  JsonFormat.key: () => JsonFormat(),
  MultiJsonFormat.key: () => MultiJsonFormat(),
  XliffFormat.key: () => XliffFormat(),
  StringsFormat.key: () => StringsFormat(),
  PoFormat.key: () => PoFormat(),
  MoFormat.key: () => MoFormat(),
};
