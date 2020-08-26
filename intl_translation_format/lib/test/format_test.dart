import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_format/test/test_mock.dart' as mock;
import 'package:test/test.dart';




dynamic expectMessage(Message message, Message expected) {
  return expect(
    messageToIcuString(message),
    messageToIcuString(expected),
  );
}

dynamic expectFormatParsing(
  String content,
  MonoLingualFormat format, {
  List<MainMessage> messages = const [],
}) {
  final result = format.parseFile(content);

  for (final translated in result.messages.values) {
    final mainMessage = messages.firstWhere((e) => e.name == translated.id);
    final translatedMessage = translated.message..parent = mainMessage;
    expectMessage(translatedMessage, mainMessage);
  }
}

dynamic expectFormatTemplateGeneration(
  String content,
  MonoLingualFormat format, {
  List<MainMessage> messages = const [],
}) {
  final template = mock.MockTemplate(
    'intl',
    Map.fromEntries(messages.map((e) => MapEntry(e.name, e))),
  );
  template.lastModified = null;
  final result = format.generateTemplateFiles(template).first.contents;
  expect(result, content);
}

void testFormat(FormatTester tester) {
  tester._test();
}

abstract class FormatTester<T> {
  TranslationFormat get format;
  String get defaultLocale => 'en';

  ///Messages file
  T get simpleMessage;
  T get messageWithMetadata;
  T get pluralMessage;
  T get variableMessage;
  T get allMessages;

  ///Template file
  T get templateSimpleMessage;
  T get templateMessageWithMetadata;
  T get templatePluralMessage;
  T get templateVariableMessage;
  T get templateAllMessages;

  Map<String, MainMessage> get messages => {
        'simpleMessage': IcuMainMessage('Simple Message', 'simpleMessage'),
        'messageWithMetadata':
            IcuMainMessage('Message With Metadata', 'messageWithMetadata')
              ..description = 'This is a description',
        'pluralExample': IcuMainMessage(
            '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}',
            'pluralExample'),
        'messageWithVariable':
            IcuMainMessage('Share {variable}', 'messageWithVariable'),
      };

  _test();
}

abstract class MonolingualFormatTester extends FormatTester<String> {
  @override
  TranslationFormat<StringFileData> get format;

  String get templateSimpleMessage => simpleMessage;
  String get templateMessageWithMetadata => messageWithMetadata;
  String get templatePluralMessage => pluralMessage;
  String get templateVariableMessage => variableMessage;
  String get templateAllMessages => allMessages;

  @override
  _test() {
    testParseFile();
    testGenerateTemplate();
  }

  testParseFile() {
    group('Parse file:', () {
      if (simpleMessage != null) {
        test('Simple Message', () {
          expectFormatParsing(
            simpleMessage,
            format,
            messages: [messages['simpleMessage']],
          );
        });
      }
      if (messageWithMetadata != null) {
        test('Simple Message with Metadata', () {
          expectFormatParsing(
            messageWithMetadata,
            format,
            messages: [messages['messageWithMetadata']],
          );
        });
      }
      if (pluralMessage != null) {
        test('Plural Message', () {
          expectFormatParsing(
            pluralMessage,
            format,
            messages: [messages['pluralExample']],
          );
        });
      }
      if (variableMessage != null) {
        test('Message with variable', () {
          expectFormatParsing(
            variableMessage,
            format,
            messages: [messages['messageWithVariable']],
          );
        });
      }
      if (allMessages != null) {
        test('Parse file', () {
          expectFormatParsing(
            pluralMessage,
            format,
            messages: messages.values.toList(),
          );
        });
      }
    });
  }

  testGenerateTemplate() {
    group('Generate template:', () {
      if (simpleMessage != null) {
        test('Simple Message', () {
          expectFormatTemplateGeneration(
            simpleMessage,
            format,
            messages: [messages['simpleMessage']],
          );
        });
      }

      if (messageWithMetadata != null) {
        test('Simple Message with Metadata', () {
          expectFormatTemplateGeneration(
            messageWithMetadata,
            format,
            messages: [messages['messageWithMetadata']],
          );
        });
      }

      if (pluralMessage != null) {
        test('Plural Message', () {
          expectFormatTemplateGeneration(
            pluralMessage,
            format,
            messages: [messages['pluralExample']],
          );
        });
      }

      if (messageWithMetadata != null) {
        test('Message with Variable', () {
          expectFormatTemplateGeneration(
            variableMessage,
            format,
            messages: [messages['messageWithVariable']],
          );
        });
      }

      if (allMessages != null) {
        test('Multiple messages - full file', () {
          expectFormatTemplateGeneration(
            allMessages,
            format,
            messages: messages.values.toList(),
          );
        });
      }
    });
  }
}

