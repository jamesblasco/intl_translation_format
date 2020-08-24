library extract;

import 'package:intl_translation_format/bin/extract.dart' as extract;
import 'package:intl_translation_format/src/utils/formats.dart';

main(List<String> args) async {
  await extract.main(args, defaultFormats);
}
