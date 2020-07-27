library intl_translation_xliff;

import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_xliff/src/parser/xliff_parser.dart';

export 'src/xliff_format.dart';

enum XliffVersion { v2, v1 }

// TODO: This will be better as an extension
String keyForVersion(XliffVersion version, [bool multilingual = false]) {
  switch (version) {
    case XliffVersion.v2:
      if (!multilingual) {
        return 'xliff-2';
      } else {
        return 'xliff-2-multi';
      }
      break;
    case XliffVersion.v1:
      if (!multilingual) {
        return 'xliff-1.2';
      } else {
        return 'xliff-1.2-multi';
      }
  }
  throw UnimplementedError();
}

final xliffFormats = <String, TranslationFormatBuilder>{
  keyForVersion(XliffVersion.v1): () => XliffFormat(XliffVersion.v1),
  keyForVersion(XliffVersion.v2): () => XliffFormat(XliffVersion.v2),
};
