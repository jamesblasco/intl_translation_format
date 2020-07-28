import 'package:intl_translation_format/intl_translation_format.dart';

import 'package:intl_translation_format/test/test_mock.dart';
import 'package:intl_translation_xliff/intl_translation_xliff.dart';
import 'package:test/test.dart';

void main() {
  group('Xliff v2.0 Format -', () {
    group('Parse file:', () {
      test('Simple Message', () {
        final file = '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" srcLang="en">
  <file>
    <unit id="simpleMessage" simpleMessage="text">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Simple Message</source>
      </segment>
    </unit>
  </file>
</xliff>''';
        final result = XliffFormat().parseFile(file);
        final parsed = result.messages.map(
          (key, m) => MapEntry(key, icuMessageToString(m.message)),
        );
        expect(parsed, {
          'simpleMessage': 'Simple Message',
        });
      });

      test('Simple Message with Metadata', () {
        final file = '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" srcLang="en">
  <file>
    <unit id="messageWithMetadata" name="messageWithMetadata">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Message With Metadata</source>
      </segment>
    </unit>
  </file>
</xliff>''';
        final result = XliffFormat().parseFile(file);
        final parsed = result.messages.map(
          (key, m) => MapEntry(key, icuMessageToString(m.message)),
        );
        expect(parsed, {
          'messageWithMetadata': 'Message With Metadata',
        });
      });

      test('Plural Message', () {
        final file = '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" srcLang="en">
  <file>
    <unit id="pluralExample" name="pluralExample">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>
      </segment>
    </unit>
  </file>
</xliff>''';
        final result = XliffFormat().parseFile(file);
        final mainMessage = MainMessage()..arguments = ['howMany'];
        final parsed = result.messages.map(
          (key, m) => MapEntry(
              key, icuMessageToString(m.message..parent = mainMessage)),
        );
        expect(parsed, {
          'pluralExample':
              '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}',
        });
      });

      test('Message with variable', () {
        final file = '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" srcLang="en">
  <file>
    <unit id="messageWithVariable" name="messageWithVariable">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Share {variable}</source>
      </segment>
    </unit>
  </file>
</xliff>''';
        final result = XliffFormat().parseFile(file);
        final mainMessage = MainMessage()..arguments = ['variable'];
        final parsed = result.messages.map(
          (key, m) => MapEntry(
              key, icuMessageToString(m.message..parent = mainMessage)),
        );
        expect(parsed, {
          'messageWithVariable': 'Share {variable}',
        });
      });

      test('Parse file', () {
        final result = XliffFormat().parseFile(_basicFile);

        final mainMessage = MainMessage()..arguments = ['variable', 'howMany'];
        final parsed = result.messages.map(
          (key, m) => MapEntry(
              key, icuMessageToString(m.message..parent = mainMessage)),
        );
        expect(parsed, {
          'simpleMessage': 'Simple Message',
          'messageWithMetadata': 'Message With Metadata',
          'pluralExample':
              '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}',
          'messageWithVariable': 'Share {variable}',
        });
      });
    });

    group('Build template:', () {
      test('Simple Message', () {
        final template = MockTemplate(
          'intl',
          <String, MainMessage>{
            'simpleMessage': simpleMessage('simpleMessage', 'Simple Message'),
          },
        );
        template.lastModified = null;
        final result = XliffFormat().generateTemplateFile(template);
        expect(result, '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" version="2.0" srcLang="en">
  <file>
    <unit id="simpleMessage" name="simpleMessage">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Simple Message</source>
      </segment>
    </unit>
  </file>
</xliff>''');
      });

      test('Simple Message with Metadata', () {
        final template = MockTemplate(
          'intl',
          <String, MainMessage>{
            'messageWithMetadata': simpleMessage(
                'messageWithMetadata', 'Message With Metadata',
                description: 'This is a description'),
          },
        );
        template.lastModified = null;
        final result = XliffFormat().generateTemplateFile(template);
        expect(result, '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" version="2.0" srcLang="en">
  <file>
    <unit id="messageWithMetadata" name="messageWithMetadata">
      <segment>
        <notes>
          <note category="format">icu</note>
          <note category="description">This is a description</note>
        </notes>
        <source>Message With Metadata</source>
      </segment>
    </unit>
  </file>
</xliff>''');
      });

      test('Plural Message', () {
        final template = MockTemplate(
          'intl',
          <String, MainMessage>{
            'pluralExample': pluralMessage(
                'pluralExample',
                '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}',
                'howMany'),
          },
        );
        template.lastModified = null;
        final result = XliffFormat().generateTemplateFile(template);
        expect(result, '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" version="2.0" srcLang="en">
  <file>
    <unit id="pluralExample" name="pluralExample">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>
      </segment>
    </unit>
  </file>
</xliff>''');
      });

      test('Message with Variable', () {
        final template = MockTemplate(
          'intl',
          <String, MainMessage>{
            'messageWithVariable': simpleMessageWithVariable(
              'messageWithVariable',
              'Share {variable}',
              'variable',
            ),
          },
        );

        template.lastModified = null;
        final result = XliffFormat().generateTemplateFile(template);
        expect(result, '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" version="2.0" srcLang="en">
  <file>
    <unit id="messageWithVariable" name="messageWithVariable">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Share {variable}</source>
      </segment>
    </unit>
  </file>
</xliff>''');
      });

      test('Full file', () {
        final template = MockTemplate(
          'intl',
          <String, MainMessage>{
            'simpleMessage': simpleMessage('simpleMessage', 'Simple Message'),
            'messageWithMetadata': simpleMessage(
                'messageWithMetadata', 'Message With Metadata',
                description: 'This is a description'),
            'pluralExample': pluralMessage(
                'pluralExample',
                '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}',
                'howMany'),
            'messageWithVariable': simpleMessageWithVariable(
                'messageWithVariable', 'Share {variable}', 'variable'),
          },
        );
        template.lastModified = null;
        final result = XliffFormat().generateTemplateFile(template);
        expect(result, '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" version="2.0" srcLang="en">
  <file>
    <unit id="simpleMessage" name="simpleMessage">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Simple Message</source>
      </segment>
    </unit>
    <unit id="messageWithMetadata" name="messageWithMetadata">
      <segment>
        <notes>
          <note category="format">icu</note>
          <note category="description">This is a description</note>
        </notes>
        <source>Message With Metadata</source>
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
    <unit id="messageWithVariable" name="messageWithVariable">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Share {variable}</source>
      </segment>
    </unit>
  </file>
</xliff>''');
      });

      test('File name', () {
        final template = MockTemplate('intl', {});
        template.lastModified = null;
        final result = XliffFormat().generateTemplateFiles(template);

        expect(result.first.name, 'intl_en.xliff');
      });

      test('Locale fr', () {
        final template = MockTemplate('intl', {}, locale: 'fr');
        template.lastModified = null;
        final result = XliffFormat().generateTemplateFiles(template);

        expect(result.first.name, 'intl_fr.xliff');
        expect(result.first.contents, '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" version="2.0" srcLang="fr">
  <file/>
</xliff>''');
      });
    });
  });
}

const _basicFile = '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" srcLang="en">
  <file>
    <unit id="simpleMessage" simpleMessage="text">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Simple Message</source>
      </segment>
    </unit>
    <unit id="messageWithMetadata" name="messageWithMetadata">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Message With Metadata</source>
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
    <unit id="messageWithVariable" name="messageWithVariable">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Share {variable}</source>
      </segment>
    </unit>  
  </file>
</xliff>
''';
