import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_format/test/test_mock.dart';
import 'package:test/test.dart';

dynamic expectContentForMessages(
  String content,
  TranslationFormat<StringFileData> format, {
  Map<String, MainMessage> messages = const {},
  List<String> arguments = const [],
}) {
  final template = MockTemplate(
    'intl',
    messages,
  );
  template.lastModified = null;
  final result = format.generateTemplateFiles(template).first.contents;
  expect(result, content);
}


dynamic _expectMessages(
  String content,
  MultiLingualFormat format, {
  Map<String, Map<String, String>> messages = const {},
  List<String> arguments = const [],
}) {
  final result = format.parseFile(content, 'en');
  final MainMessage mainMessage = MainMessage();
  mainMessage..arguments = arguments;

  result.forEach((element) {
    final parsed = element.messages.map(
      (key, m) => MapEntry(
        key,
        messageToIcuString(m.message..parent = mainMessage),
      ),
    );
    return expect(parsed, messages[element.locale]);
  });
}

/* dynamic _expectContentForMessages(
  String content,
  MonoLingualFormat format, {
  Map<String, MainMessage> messages = const {},
  List<String> arguments = const [],
}) {
  final template = mock.MockTemplate(
    'intl',
    messages,
  );
  template.lastModified = null;
  final result = format.generateTemplateFile(template);
  expect(result, content);
} */

testMultiLingualFormat(
  String name,
  MultiLingualFormat format, {
  String file,
  String template,
  Map<String, Map<String, String>> icuMessageForLocale,
  String defaultLocale = 'en',
  List<String> locales = const ['en', 'es'],
}) {
  group(name, () {
    test('Parse file', () {
      _expectMessages(
        file,
        format,
        messages: icuMessageForLocale,
      );
    });
    test('Generate template', () {
      expectContentForMessages(
        template ?? file,
        format,
        messages: icuMessageForLocale[defaultLocale].map(
          (key, value) => MapEntry(
            key,
            IcuMainMessage(value, key),
          ),
        ),
      );
    });
  });
}

testMultiLingualFormatWithDefaultMessages(
  MultiLingualFormat format, {
  String simpleMessage,
  String messageWithMetadata,
  String pluralMessage,
  String messageWithVariable,
  String allMessages,
  List<String> locales = const ['en', 'es'],
}) {
  if (simpleMessage != null) {
    testMultiLingualFormat(
    'Simple Message',
    format,
    file: simpleMessage,
    template: '<?xml version="1.0 encoding="UTF-8""?>\n'
        '<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">\n'
        '  <file>\n'
        '    <trans-unit id="simpleMessage">\n'
        '      <notes>\n'
        '        <note category="format">icu</note>\n'
        '      </notes>\n'
        '      <source>Simple Message</source>\n'
        '      <target></target>\n'
        '    </trans-unit>\n'
        '  </file>\n'
        '</xliff>',
    icuMessageForLocale: {
      'en': {
        'simpleMessage': 'Simple Message',
      },
      'es': {
        'simpleMessage': 'Mensaje simple',
      },
    },
  );
  }
  group('Parse file:', () {
    if (simpleMessage != null) {
      test('Simple Message', () {
        _expectMessages(
          simpleMessage,
          format,
          messages: {
            'en': {
              'simpleMessage': 'Simple Message',
            },
            if (locales.contains('es'))
              'es': {
                'simpleMessage': 'Mensaje simple',
              },
          },
        );
      });
    }
    if (messageWithMetadata != null) {
      test('Simple Message with Metadata', () {
        _expectMessages(
          messageWithMetadata,
          format,
          messages: {
            'en': {
              'messageWithMetadata': 'Message With Metadata',
            },
            if (locales.contains('es'))
              'es': {
                'messageWithMetadata': 'Mensaje con Metadatos',
              },
          },
        );
      });
    }
    if (pluralMessage != null) {
      test('Plural Message', () {
        _expectMessages(
          pluralMessage,
          format,
          messages: {
            'en': {
              'pluralExample':
                  '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}',
            },
            if (locales.contains('es'))
              'es': {
                'pluralExample':
                    '{howMany,plural, =0{Ningún elemento}=1{Un elemento}many{Muchos elementos}other{{howMany} elementos}}',
              },
          },
          arguments: ['howMany'],
        );
      });
    }
    if (messageWithVariable != null) {
      test('Message with variable', () {
        _expectMessages(
          messageWithVariable,
          format,
          messages: {
            'en': {
              'messageWithVariable': 'Share {variable}',
            },
            if (locales.contains('es'))
              'es': {
                'messageWithVariable': 'Compartir {variable}',
              },
          },
          arguments: ['variable'],
        );
      });
    }
    if (allMessages != null) {
      test('Parse file', () {
        _expectMessages(allMessages, format, messages: {
          'en': {
            'simpleMessage': 'Simple Message',
            'messageWithMetadata': 'Message With Metadata',
            'pluralExample':
                '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}',
            'messageWithVariable': 'Share {variable}',
          },
          if (locales.contains('es'))
            'es': {
              'simpleMessage': 'Mensaje simple',
              'messageWithMetadata': 'Mensaje con Metadatos',
              'pluralExample':
                  '{howMany,plural, =0{Ningún elemento}=1{Un elemento}many{Muchos elementos}other{{howMany} elementos}}',
              'messageWithVariable': 'Compartir {variable}',
            },
        }, arguments: [
          'variable',
          'howMany'
        ]);
      });
    }
  });

  /*  group('Generate template:', () {
    if (simpleMessage != null) {
      test('Simple Message', () {
        expectContentForMessages(simpleMessage, format, messages: {
          'simpleMessage':
              mock.simpleMessage('simpleMessage', 'Simple Message'),
        });
      });
    }

    if (messageWithMetadata != null) {
      test('Simple Message with Metadata', () {
        expectContentForMessages(messageWithMetadata, format, messages: {
          'messageWithMetadata': mock.simpleMessage(
              'messageWithMetadata', 'Message With Metadata',
              description: 'This is a description'),
        });
      });
    }

    if (pluralMessage != null) {
      test('Plural Message', () {
        expectContentForMessages(
          pluralMessage,
          format,
          messages: {
            'pluralExample': mock.pluralMessage(
                'pluralExample',
                '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}',
                'howMany'),
          },
        );
      });
    }

    if (messageWithVariable != null) {
      test('Message with Variable', () {
        expectContentForMessages(
          messageWithVariable,
          format,
          messages: {
            'messageWithVariable': mock.simpleMessageWithVariable(
              'messageWithVariable',
              'Share {variable}',
              'variable',
            ),
          },
        );
      });
    }

    if (allMessages != null) {
      test('Multiple messages - full file', () {
        expectContentForMessages(
          allMessages,
          format,
          messages: {
            'simpleMessage':
                mock.simpleMessage('simpleMessage', 'Simple Message'),
            'messageWithMetadata': mock.simpleMessage(
                'messageWithMetadata', 'Message With Metadata',
                description: 'This is a description'),
            'pluralExample': mock.pluralMessage(
                'pluralExample',
                '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}',
                'howMany'),
            'messageWithVariable': mock.simpleMessageWithVariable(
                'messageWithVariable', 'Share {variable}', 'variable'),
          },
        );
      });
    }
  });
 */
}
