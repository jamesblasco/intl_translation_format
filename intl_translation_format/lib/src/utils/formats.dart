import 'package:intl_translation_arb/intl_translation_arb.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_xliff/intl_translation_xliff.dart';

import '../translation_format.dart';

export 'package:intl_translation_arb/intl_translation_arb.dart';
export 'package:intl_translation_xliff/intl_translation_xliff.dart';

/// Translation file formats officially supported
final defaultFormats = <String, TranslationFormatBuilder>{
  ArbFormat.key: () => ArbFormat(),
  ...xliffFormats,
};
