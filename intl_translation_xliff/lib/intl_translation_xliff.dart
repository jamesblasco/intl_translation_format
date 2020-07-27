library intl_translation_xliff;

import 'package:intl_translation_format/intl_translation_format.dart';

export 'src/xliff_format.dart';

final xliffFormats = <String, TranslationFormatBuilder>{
  XliffFormat.key: () => XliffFormat(),
};
