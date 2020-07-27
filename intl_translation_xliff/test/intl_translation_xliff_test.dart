import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_xliff/intl_translation_xliff.dart';
import 'package:intl_translation_xliff/src/parser/xliff_parser.dart';
import 'package:test/test.dart';
import 'package:intl_translation/src/intl_message.dart';

final _xliffAttributes = xliffAttributes.entries
    .map((e) => '${e.key}="${e.value}"')
    .reduce((value, element) => '$value $element');

void main() {
  group('Xliff parser:', () {
    test('Nested <xliff> not allowed', () async {
      final content = '''
          <?xml version="1.0 encoding="UTF-8""?>
          <xliff $_xliffAttributes version="2.0" srcLang="en">
          <xliff $_xliffAttributes version="2.0"  srcLang="en">
          </xliff>
          </xliff>
      ''';
      try {
        final result = XliffParser(displayWarnings: false).parse(content);
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
        final result = XliffParser(displayWarnings: false).parse(content);
      } on XliffParserException catch (e) {
        expect(e.title, 'version attribute is required for <xliff>');
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
        final result = XliffParser(displayWarnings: false).parse(content);
      } on XliffParserException catch (e) {
        expect(e.title, 'version attribute is required for <xliff>');
        return;
      }
      throw 'Expected an error';
    });

    test('xliff', () async {
      final result =
          XliffParser(displayWarnings: false).parse(xliffBasicMessage);
      final mainMessage = MainMessage()..arguments = ['howMany', 'variable'];
      final map = result.messages.map((key, value) {
        final message = value.message;
        message..parent = mainMessage;

        return MapEntry(key, icuMessageToString(value.message));
      });

      expect(map, {
        'text': 'normal Text',
        'textWithMetadata': 'text With Metadata',
        'pluralExample':
            '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}',
        'variable': 'Hello {variable}'
      });
    });
  });
}

const xliffBasicMessage = '''
      <?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" srcLang="en">
  <file>
    <unit id="text" name="text">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>normal Text</source>
      </segment>
    </unit>
    <unit id="textWithMetadata" name="textWithMetadata">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>text With Metadata</source>
      </segment>
    </unit>
    <unit id="pluralExample" name="pluralExample">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>
      </segment>
    </unit>
    <unit id="variable" name="variable">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Hello {variable}</source>
      </segment>
    </unit>
  </file>
</xliff>''';
