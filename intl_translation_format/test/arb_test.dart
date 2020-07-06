import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_format/src/models/formats.dart';
import 'package:test/test.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'package:intl_translation/generate_localized.dart';

void main() {
  group('Arb Format', () {
    test('parse file', () {
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

    test('build file', () {
      final template = MockTemplate('intl', {
        'simpleMessage': Message.from('Simple Message', null),
        'messageWithMetadata': Message.from('Message With Metadata', null),
        'pluralExample': Message.from(
            '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}',
            null),
      });
      final result = ArbFormat().buildTemplate(template);
      print(result.first.contents);
      /* expect(parsed, {
        'simpleMessage': 'Simple Message',
        'messageWithMetadata': 'Message With Metadata',
        'pluralExample':
            '{howMany,plural, =0{Literal(No items)}=1{Literal(One item)}many{Literal(A lot of items)}other{CompositeMessage([VariableSubstitution(null), Literal( items)])}}',
      }); */
    });
  });
}

class MockTemplate extends TranslationTemplate {
  MockTemplate(String projectName, Map<String, Message> messages)
      : this.messages = messages.map((key, value) => MapEntry(
            key,
            MainMessage()
              ..id = key
              ..addPieces([value])
              ..arguments = [])),
        super(projectName);
  @override
  final Map<String, MainMessage> messages;
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
