import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_format/test/test_mock.dart' as mock;
import 'package:test/test.dart';

dynamic expectMessages(
  String content,
  SingleLanguageFormat format, {
  Map<String, String> messages = const {},
  List<String> arguments = const [],
}) {
  final result = format.parseFile(content);
  final MainMessage mainMessage = MainMessage()..arguments = arguments;
  final parsed = result.messages.map(
    (key, m) => MapEntry(
      key,
      icuMessageToString(m.message..parent = mainMessage),
    ),
  );
  return expect(parsed, messages);
}

dynamic expectContentForMessages(
  String content,
  SingleLanguageFormat format, {
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

dynamic expectDefaultSimpleMessage(
        String content, SingleLanguageFormat format) =>
    expectMessages(
      content,
      format,
      messages: {
        'simpleMessage': 'Simple Message',
      },
    );

dynamic expectDefaultMessageWithMetadata(
        String content, SingleLanguageFormat format) =>
    expectMessages(
      content,
      format,
      messages: {
        'messageWithMetadata': 'Message With Metadata',
      },
    );

dynamic expectDefaultPluralMessage(
        String content, SingleLanguageFormat format) =>
    expectMessages(content, format, messages: {
      'pluralExample':
          '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}',
    }, arguments: [
      'howMany'
    ]);

dynamic expectDefaultMessageWithVariable(
        String content, SingleLanguageFormat format) =>
    expectMessages(content, format, messages: {
      'messageWithVariable': 'Share {variable}',
    }, arguments: [
      'variable'
    ]);

dynamic expectDefaultMessages(String content, SingleLanguageFormat format) =>
    expectMessages(content, format, messages: {
      'simpleMessage': 'Simple Message',
      'messageWithMetadata': 'Message With Metadata',
      'pluralExample':
          '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}',
      'messageWithVariable': 'Share {variable}',
    }, arguments: [
      'variable',
      'howMany'
    ]);

testFormatParserWithDefaultMessages(SingleLanguageFormat format,
    {String simpleMessage,
    String messageWithMetadata,
    String pluralMessage,
    String messageWithVariable,
    String allMessages}) {
  group('Parse file:', () {
    if (simpleMessage != null) {
      test('Simple Message', () {
        expectDefaultSimpleMessage(simpleMessage, format);
      });
    }
    if (messageWithMetadata != null) {
      test('Simple Message with Metadata', () {
        expectDefaultMessageWithMetadata(messageWithMetadata, format);
      });
    }
    if (pluralMessage != null) {
      test('Plural Message', () {
        expectDefaultPluralMessage(pluralMessage, format);
      });
    }
    if (messageWithVariable != null) {
      test('Message with variable', () {
        expectDefaultMessageWithVariable(messageWithVariable, format);
      });
    }
    if (allMessages != null) {
      test('Parse file', () {
        expectDefaultMessages(allMessages, format);
      });
    }
  });

  group('Generate template:', () {
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
}
