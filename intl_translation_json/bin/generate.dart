library generate_json;

import 'package:intl_translation_format/generate.dart' as generate;
import 'package:intl_translation_json/intl_translation_json.dart';

void main(List<String> args) async {
  await generate.main(args, jsonFormats);
}
