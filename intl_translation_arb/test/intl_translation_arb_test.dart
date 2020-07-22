import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_format/src/models/formats.dart';
import 'package:intl_translation_format/src/test_mock.dart';


import 'package:test/test.dart';
import 'package:intl_translation/src/intl_message.dart';


void main() {
  group('Arb Format -', () {
    group('Parse file:', () {
      test('Simple Message', () {
        final file = '''
{
  "@@locale": "en",
  "@@last_modified": "2020-07-04T20:20:28.317849",
  "simpleMessage": "Simple Message",
  "@simpleMessage": {
    "type": "text",
    "placeholders": {},
    "source_text": "message"
  }
}''';
        final result = ArbFormat().parseFile(file);
        final parsed = result.map(
          (key, m) => MapEntry(key, ICUParser().icuMessageToString(m.message)),
        );
        expect(parsed, {
          'simpleMessage': 'Simple Message',
        });
      });

      test('Simple Message with Metadata', () {
        final file = '''
{
  "@@locale": "en",
  "@@last_modified": "2020-07-04T20:20:28.317849",
  "messageWithMetadata": "Message With Metadata",
  "@textWithMetadata": {
    "type": "text",
    "placeholders": {},
    "source_text": "messageWithMetadata"
  }
}''';
        final result = ArbFormat().parseFile(file);
        final parsed = result.map(
          (key, m) => MapEntry(key, ICUParser().icuMessageToString(m.message)),
        );
        expect(parsed, {
          'messageWithMetadata': 'Message With Metadata',
        });
      });

      test('Plural Message', () {
        final file = '''
{
  "@@locale": "en",
  "@@last_modified": "2020-07-04T20:20:28.317849",
  "pluralExample": "{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}",
  "@pluralExample": {
    "type": "text",
    "placeholders": {
      "howMany": {}
    },
    "source_text": "{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}"
  }
}''';
        final result = ArbFormat().parseFile(file);
        final mainMessage = MainMessage()..arguments = ['howMany'];
        final parsed = result.map(
          (key, m) => MapEntry(key,
              ICUParser().icuMessageToString(m.message..parent = mainMessage)),
        );
        expect(parsed, {
          'pluralExample':
              '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}',
        });
      });

      test('Message with variable', () {
        final file = '''
{
  "@@locale": "en",
  "@@last_modified": "2020-07-04T20:20:28.317849",
  "messageWithVariable": "Share {variable}",
  "@messageWithVariable": {
    "type": "text",
    "placeholders": {
      "variable": {}
    },
    "source_text": "Share {variable}"
  }
}''';
        final result = ArbFormat().parseFile(file);
        final mainMessage = MainMessage()..arguments = ['variable'];
        final parsed = result.map(
          (key, m) => MapEntry(key,
              ICUParser().icuMessageToString(m.message..parent = mainMessage)),
        );
        expect(parsed, {
          'messageWithVariable': 'Share {variable}',
        });
      });

      test('Parse file', () {
        final result = ArbFormat().parseFile(_basicArbFile);

        final parsed =
            result.map((key, m) => MapEntry(key, m.message.expanded()));
        expect(parsed, {
          'simpleMessage': 'Simple Message',
          'messageWithMetadata': 'Message With Metadata',
          'pluralExample':
              '{howMany,plural, =0{Literal(No items)}=1{Literal(One item)}many{Literal(A lot of items)}other{CompositeMessage([VariableSubstitution(null), Literal( items)])}}',
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
        final result = ArbFormat().buildTemplate(template);
        expect(result.first.contents, '''
{
  "@@locale": "en",
  "simpleMessage": "Simple Message",
  "@simpleMessage": {
    "type": "text",
    "placeholders": {},
    "source_text": "Simple Message"
  }
}''');
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
        final result = ArbFormat().buildTemplate(template);
        expect(result.first.contents, '''
{
  "@@locale": "en",
  "messageWithMetadata": "Message With Metadata",
  "@messageWithMetadata": {
    "description": "This is a description",
    "type": "text",
    "placeholders": {},
    "source_text": "Message With Metadata"
  }
}''');
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
        final result = ArbFormat().buildTemplate(template);
        expect(result.first.contents, '''
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
}''');
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
        final result = ArbFormat().buildTemplate(template);
        expect(result.first.contents, '''
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
}''');
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
        final result = ArbFormat().buildTemplate(template);
        expect(result.first.contents, '''
{
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
}''');
      });

      test('File name', () {
        final template = MockTemplate('intl', {});
        template.lastModified = null;
        final result = ArbFormat().buildTemplate(template);

        expect(result.first.name, 'intl_en.arb');
      });

      test('Locale fr', () {
        final template = MockTemplate('intl', {}, locale: 'fr');
        template.lastModified = null;
        final result = ArbFormat().buildTemplate(template);

        expect(result.first.name, 'intl_fr.arb');
        expect(result.first.contents, '''
{
  "@@locale": "fr"
}''');
      });
    });
  });
}


const _basicArbFile = '''{
  "@@locale": "en",
  "@@last_modified": "2020-07-04T20:20:28.317849",
  "simpleMessage": "Simple Message",
  "@simpleMessage": {
    "type": "text",
    "placeholders": {},
    "source_text": "message"
  },
  "messageWithMetadata": "Message With Metadata",
  "@textWithMetadata": {
    "type": "text",
    "placeholders": {},
    "source_text": "messageWithMetadata"
  },
  "pluralExample": "{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}",
  "@pluralExample": {
    "type": "text",
    "placeholders": {
      "howMany": {}
    },
    "source_text": "{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}"
  }
}
      ''';
