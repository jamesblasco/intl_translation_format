library extract_arb;

import 'package:intl_translation_format/extract.dart' as extract;
import 'package:intl_translation_arb/intl_translation_arb.dart';

void main(List<String> args) async {
  await extract.main(args, {ArbFormat.key: () => ArbFormat()});
}
