import 'package:intl_translation_format/intl_translation_format.dart';

import 'package:intl_translation_format/test/test_mock.dart';
import 'package:intl_translation_xliff/intl_translation_xliff.dart';
import 'package:test/test.dart';

void main() {
  group('Xliff v1.2 Format -', () {
    group('Parse file:', () {
      test('Simple Message', () {
        final file = '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.2" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" source-language="en">
  <file>
    <trans-unit id="simpleMessage" simpleMessage="text">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Simple Message</source>
    </trans-unit>
  </file>
</xliff>''';
        final result = XliffFormat(XliffVersion.v1).parseFile(file);
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
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.2" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" source-language="en">
  <file>
    <trans-unit id="messageWithMetadata">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Message With Metadata</source>
    </trans-unit>
  </file>
</xliff>''';
        final result = XliffFormat(XliffVersion.v1).parseFile(file);
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
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.2" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" source-language="en">
  <file>
    <trans-unit id="pluralExample">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>
    </trans-unit>
  </file>
</xliff>''';
        final result = XliffFormat(XliffVersion.v1).parseFile(file);
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
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.2" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" source-language="en">
  <file>
    <trans-unit id="messageWithVariable">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Share {variable}</source>
    </trans-unit>
  </file>
</xliff>''';
        final result = XliffFormat(XliffVersion.v1).parseFile(file);
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
        final result = XliffFormat(XliffVersion.v1).parseFile(_basicFile);

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
        final result = XliffFormat(XliffVersion.v1).generateTemplateFile(template);
        expect(result, '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">
  <file>
    <trans-unit id="simpleMessage">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Simple Message</source>
    </trans-unit>
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
        final result = XliffFormat(XliffVersion.v1).generateTemplateFile(template);
        expect(result, '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">
  <file>
    <trans-unit id="messageWithMetadata">
      <notes>
        <note category="format">icu</note>
        <note category="description">This is a description</note>
      </notes>
      <source>Message With Metadata</source>
    </trans-unit>
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
        final result = XliffFormat(XliffVersion.v1).generateTemplateFile(template);
        expect(result, '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">
  <file>
    <trans-unit id="pluralExample">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>
    </trans-unit>
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
        final result = XliffFormat(XliffVersion.v1).generateTemplateFile(template);
        expect(result, '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">
  <file>
    <trans-unit id="messageWithVariable">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Share {variable}</source>
    </trans-unit>
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
        final result = XliffFormat(XliffVersion.v1).generateTemplateFile(template);
        expect(result, '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">
  <file>
    <trans-unit id="simpleMessage">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Simple Message</source>
    </trans-unit>
    <trans-unit id="messageWithMetadata">
      <notes>
        <note category="format">icu</note>
        <note category="description">This is a description</note>
      </notes>
      <source>Message With Metadata</source>
    </trans-unit>
    <trans-unit id="pluralExample">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>
    </trans-unit>
    <trans-unit id="messageWithVariable">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Share {variable}</source>
    </trans-unit>
  </file>
</xliff>''');
      });

      test('File name', () {
        final template = MockTemplate('intl', {});
        template.lastModified = null;
        final result = XliffFormat(XliffVersion.v1).generateTemplateFiles(template);

        expect(result.first.name, 'intl_en.xliff');
      });

      test('Locale fr', () {
        final template = MockTemplate('intl', {}, locale: 'fr');
        template.lastModified = null;
        final result = XliffFormat(XliffVersion.v1).generateTemplateFiles(template);

        expect(result.first.name, 'intl_fr.xliff');
        expect(result.first.contents, '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="fr">
  <file/>
</xliff>''');
      });
    });
  });
}

const _basicFile = '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">
  <file>
    <trans-unit id="messageWithMetadata">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Message With Metadata</source>
    </trans-unit>
    <unit id="simpleMessage" name="simpleMessage">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Simple Message</source>
    </unit>
    <unit id="messageWithMetadata" name="messageWithMetadata">
      <notes>
        <note category="format">icu</note>
        <note category="description">This is a description</note>
      </notes>
      <source>Message With Metadata</source>
    </unit>
    <unit id="pluralExample" name="pluralExample">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>
    </unit>
    <unit id="messageWithVariable" name="messageWithVariable">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Share {variable}</source>
    </unit>
  </file>
</xliff>
''';
