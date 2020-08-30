import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_format/test_utils.dart';
import 'package:intl_translation_json/intl_translation_json.dart';
import 'package:test/test.dart';

void main() {
  group('Json Format -', () {
    testFormat(JsonFormatTester());

    test('Parse nested Message', () {
      final test = '''
{
  "nested": {
    "key": "Simple Message"
  }
}''';
      final messages = JsonFormat().parseFile(test).messages;
      expect(messages.keys.first, 'nestedKey');
    });

    test('Parse double nested Message', () {
      final test = '''
{
  "double": {
    "nested": {
      "key": "Simple Message"
    }
  }
}''';
      final messages = JsonFormat().parseFile(test).messages;
      expect(messages.keys.first, 'doubleNestedKey');
    });

    test('Invalid json', () {
      final test = '''
{
  "listAreNotAllowed": [
    "item"
  ]
}''';

      try {
        JsonFormat().parseFile(test);
      } catch (error) {
        expect(
          '$error',
          'Invalid item with key listAreNotAllowed. [item] is not a subtype of type String',
        );
      }
    });
  });
}

class JsonFormatTester extends MonolingualFormatTester {
  @override
  MonoLingualFormat get format => JsonFormat();

  @override
  String get simpleMessage => '''
{
  "simpleMessage": "Simple Message"
}''';

  @override
  String get messageWithMetadata => '''
{
  "messageWithMetadata": "Message With Metadata"
}''';

  @override
  String get pluralMessage => '''
{
  "pluralExample": "{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}"
}''';

  @override
  String get variableMessage => '''
{
  "messageWithVariable": "Share {variable}"
}''';

  @override
  String get allMessages => '''
{
  "simpleMessage": "Simple Message",
  "messageWithMetadata": "Message With Metadata",
  "pluralExample": "{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}",
  "messageWithVariable": "Share {variable}"
}''';
}
