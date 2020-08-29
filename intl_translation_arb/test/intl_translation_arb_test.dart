import 'package:intl_translation_arb/intl_translation_arb.dart';
import 'package:intl_translation_format/src/translation_format.dart';
import 'package:intl_translation_format/test_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Arb Format -', () {
    testFormat(ArbDefaultFormatTester());

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

      final expectedContent = '''
{
  "@@locale": "fr"
}''';

      expect(result.first.name, 'intl_fr.arb');
      expect(result.first.contents, expectedContent);
    });
  });
}

/// An implementation [MonolingualFormatTester] to test arb format with 
/// standarized messages.
///
/// It overrides the strings [simpleMessage], [messageWithMetadata],
/// [variableMessage], [pluralMessage], [allMessages], that should be the 
/// content from the arb file that contains each specific message.
/// 
/// When tested, it will parse these file content and extract the messages and it
/// will compare them with them expected ones. After that it will generate a template
/// with the expected messages and it will try to match it to the same file content
///
class ArbDefaultFormatTester extends MonolingualFormatTester {
  @override
  MonoLingualFormat get format => ArbFormat();

  @override
  String get simpleMessage => '''
{
  "@@locale": "en",
  "simpleMessage": "Simple Message",
  "@simpleMessage": {
    "type": "text",
    "placeholders": {},
    "source_text": "Simple Message"
  }
}''';

  @override
  String get messageWithMetadata => '''
{
  "@@locale": "en",
  "messageWithMetadata": "Message With Metadata",
  "@messageWithMetadata": {
    "description": "This is a description",
    "type": "text",
    "placeholders": {},
    "source_text": "Message With Metadata"
  }
}''';

  @override
  String get variableMessage => '''
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
}''';

  @override
  String get pluralMessage => '''
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
}''';

  @override
  String get allMessages => _basicArbFile;
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
