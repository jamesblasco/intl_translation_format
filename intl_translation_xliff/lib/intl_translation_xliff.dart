library intl_translation_xliff;

import 'package:intl_translation_format/intl_translation_format.dart';

export 'src/xliff_format.dart';

enum XliffVersion { v2, v1 }

final xliffFormats = <String, TranslationFormatBuilder>{
  keyForVersion(XliffVersion.v1): () => XliffFormat(XliffVersion.v1),
  keyForVersion(XliffVersion.v2): () => XliffFormat(XliffVersion.v2),
  keyForVersion(XliffVersion.v1, true): () =>
      MultipleLanguageXliffFormat(XliffVersion.v1),
  keyForVersion(XliffVersion.v2, true): () =>
      MultipleLanguageXliffFormat(XliffVersion.v2),
};

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

Map<String, String> attributesForVersion(XliffVersion version) {
  if (version == XliffVersion.v2) {
    return {
      'xmlns': 'urn:oasis:names:tc:xliff:document:2.0',
      'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
      'xsi:schemaLocation':
          'urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd',
    };
  } else {
    return {
      'xmlns': 'urn:oasis:names:tc:xliff:document:1.2',
      'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
      'xsi:schemaLocation':
          'urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd',
    };
  }
}
