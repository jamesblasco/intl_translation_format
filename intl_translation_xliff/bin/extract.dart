library extract_xliff;

import 'package:intl_translation_format/extract.dart' as extract;
import 'package:intl_translation_xliff/intl_translation_xliff.dart';

void main(List<String> args) async {
  await extract.main(args, xliffFormats);
}
