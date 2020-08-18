#!/usr/bin/env dart

library generate_xliff;

import 'package:intl_translation_format/bin/extract.dart' as generate;
import 'package:intl_translation_format/intl_translation_format.dart';

void main(List<String> args) async {
  await generate.main(args, xliffFormats);
}
