import 'package:intl_translation_arb/intl_translation_arb.dart';
import 'package:intl_translation_format/test/test_mock.dart';
import 'package:intl_translation_format/test/format_test.dart';
import 'package:test/test.dart';

void main() {

  group('Arb Format -', () {
    testFormatParserWithDefaultMessages(
      ArbFormat(),
      simpleMessage: '''
{
  "@@locale": "en",
  "simpleMessage": "Simple Message",
  "@simpleMessage": {
    "type": "text",
    "placeholders": {},
    "source_text": "Simple Message"
  }
}''',
      messageWithMetadata: '''
{
  "@@locale": "en",
  "messageWithMetadata": "Message With Metadata",
  "@messageWithMetadata": {
    "description": "This is a description",
    "type": "text",
    "placeholders": {},
    "source_text": "Message With Metadata"
  }
}''',
      pluralMessage: '''
{
  "@@locale": "en",
  "pluralExample": "{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}",
  "@pluralExample": {
    "type": "text",
    "placeholders": {
      "howMany": {}
    },
    "source_text": "{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}"
  }
}''',
      messageWithVariable: '''
{
  "@@locale": "en",
  "messageWithVariable": "Share {variable}",
  "@messageWithVariable": {
    "type": "text",
    "placeholders": {
      "variable": {}
    },
    "source_text": "Share {variable}"
  }
}''',
      allMessages: _basicArbFile,
    );

      test('File name', () {
        final template = MockTemplate('intl', {});
        template.lastModified = null;
        final result = ArbFormat().generateTemplateFiles(template);

        expect(result.first.name, 'intl_en.arb');
      });

      test('Locale fr', () {
        final template = MockTemplate('intl', {}, locale: 'fr');
        template.lastModified = null;
        final result = ArbFormat().generateTemplateFiles(template);

        expect(result.first.name, 'intl_fr.arb');
        expect(result.first.contents, '''
{
  "@@locale": "fr"
}''');
      });

  });
}

const _basicArbFile = '''{
  "@@locale": "en",
  "simpleMessage": "Simple Message",
  "@simpleMessage": {
    "type": "text",
    "placeholders": {},
    "source_text": "Simple Message"
  },
  "messageWithMetadata": "Message With Metadata",
  "@messageWithMetadata": {
    "description": "This is a description",
    "type": "text",
    "placeholders": {},
    "source_text": "Message With Metadata"
  },
  "pluralExample": "{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}",
  "@pluralExample": {
    "type": "text",
    "placeholders": {
      "howMany": {}
    },
    "source_text": "{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}"
  },
  "messageWithVariable": "Share {variable}",
  "@messageWithVariable": {
    "type": "text",
    "placeholders": {
      "variable": {}
    },
    "source_text": "Share {variable}"
  }
}''';
