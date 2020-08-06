import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_format/test/test_mock.dart' as mock;
import 'package:test/test.dart';

dynamic _expectMessages(
  String content,
  MultiLingualFormat format, {
  Map<String, Map<String, String>> messages = const {},
  List<String> arguments = const [],
}) {
  final result = format.parseFile(content);
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

dynamic _expectContentForMessages(
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
}

testMultiLingualFormatWithDefaultMessages(
  MultiLingualFormat format, {
  String simpleMessage,
  String messageWithMetadata,
  String pluralMessage,
  String messageWithVariable,
  String allMessages,
}) {
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
