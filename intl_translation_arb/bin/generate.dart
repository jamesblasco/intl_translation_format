library generate_arb;

import 'package:intl_translation_format/generate.dart' as generate;
import 'package:intl_translation_arb/intl_translation_arb.dart';

void main(List<String> args) async {
  await generate.main(args, {ArbFormat.key: () => ArbFormat()});
}
