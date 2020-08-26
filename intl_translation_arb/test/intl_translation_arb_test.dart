import 'package:intl_translation_arb/intl_translation_arb.dart';
import 'package:intl_translation_format/src/file/file_provider.dart';
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

      expect(result.first.name, 'intl_fr.arb');
      expect(result.first.contents, '''
{
  "@@locale": "fr"
}''');
    });
  });
}

class ArbDefaultFormatTester extends MonolingualFormatTester {
  @override
  TranslationFormat<StringFileData> get format => ArbFormat();

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
