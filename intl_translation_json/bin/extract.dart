library extract_json;

import 'package:intl_translation_format/extract.dart' as extract;
import 'package:intl_translation_json/intl_translation_json.dart';

void main(List<String> args) async {
  await extract.main(args, jsonFormats);
}
