import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_xliff/intl_translation_xliff.dart';
import 'package:intl_translation_xliff/src/parser/xliff_parser.dart';
import 'package:intl_translation_xliff/src/parser/xml_parser.dart';
import 'package:test/test.dart';

import 'xliff_v2_test.dart' as xliff2;
import 'xliff_v1_test.dart' as xliff1;

import 'xliff_v2_multi_test.dart' as xliff2_multi;
import 'xliff_v1_multi_test.dart' as xliff1_multi;

import 'xml_parser_test.dart' as xml;

final _xliffAttributes = attributesForVersion(XliffVersion.v2)
    .entries
    .map((e) => '${e.key}="${e.value}"')
    .reduce((value, element) => '$value $element');

void main() {
  xml.main();
  xliff2.main();
  xliff1.main();

  xliff2_multi.main();
  xliff1_multi.main();

  group('Xliff parser:', () {
    test('Nested <xliff> not allowed', () async {
      final content = '''
          <?xml version="1.0 encoding="UTF-8""?>
          <xliff $_xliffAttributes version="2.0" srcLang="en">
          <xliff $_xliffAttributes version="2.0" srcLang="en">
          </xliff>
          </xliff>
      ''';
      try {
        XliffParser(displayWarnings: false).parse(content);
      } on XliffParserException catch (e) {
        expect(e.title, 'Unsupported nested <xliff> element.');
        return;
      }
      throw 'Expected an error';
    });

    test('Required attribute version is missing in <xliff>', () async {
      final content = '''
          <?xml version="1.0 encoding="UTF-8""?>
          <xliff  srcLang="en" $_xliffAttributes>
          </xliff>
      ''';
      try {
        XliffParser(displayWarnings: false).parse(content);
      } on XmlParserException catch (e) {
        expect(e.title, '\'version\' attribute is required for <xliff>');
        return;
      }
      throw 'Expected an error';
    });

    test('Wrong xliff version in format', () async {
      final content = '''
          <?xml version="1.0 encoding="UTF-8""?>
          <xliff  source-language="en" $_xliffAttributes version="2.0">
          </xliff>
      ''';
      try {
        XliffParser(displayWarnings: false, version: XliffVersion.v1)
            .parse(content);
      } on XliffParserException catch (e) {
        expect(e.title, 'Invalid Xliff version parser');
        return;
      }
      throw 'Expected an error';
    });
  });
}
