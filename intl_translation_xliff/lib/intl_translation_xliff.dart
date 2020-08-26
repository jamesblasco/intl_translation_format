library intl_translation_xliff;

import 'package:intl_translation_format/intl_translation_format.dart';

export 'src/xliff_format.dart';

enum XliffVersion { v2, v1 }

final xliffFormats = <String, TranslationFormatBuilder>{
  'xlf': () => XliffFormat(XliffVersion.v1, false),
  'xlf2': () => XliffFormat(XliffVersion.v2, false),
};

// TODO: This will be better as an extension
String keyForVersion(XliffVersion version) {
  switch (version) {
    case XliffVersion.v2:
      return 'xlf2';
    case XliffVersion.v1:
      return 'xlf';
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
