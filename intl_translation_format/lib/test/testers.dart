import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'package:test/test.dart';
import 'format_test.dart';

void testFormat(FormatTester tester) {
  tester._test();
}

/// An abstract class that allows to test a [TranslationFormat] into a standarized
/// test with diverse messages.
///
/// It is recommended to use the implmentations [MonolingualFormatTester] for
/// monolingual formats, and [MultilingualParsingTester],
/// [MultilingualGenerateTemplateTester] for formats with multiple locales.
///
/// See [intl_translation_arb](https://github.com/jamesblasco/intl_translation_format/blob/master/intl_translation_arb/test/intl_translation_arb_test.dart)
/// for an actual implementation of a FormatTester.
///
abstract class FormatTester<T> {
  TranslationFormat get format;
  String get defaultLocale => 'en';

  Map<String, MainMessage> get messages {
    return {
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
  }

  Map<String, MainMessage> get translatedMessages {
    return {
      'simpleMessage': IcuMainMessage('Mensaje simple', 'simpleMessage'),
      'messageWithMetadata':
          IcuMainMessage('Mensaje con Metadatos', 'messageWithMetadata')
            ..description = 'This is a description',
      'pluralExample': IcuMainMessage(
          '{howMany,plural, =0{Ningún elemento}=1{Un elemento}many{Muchos elementos}other{{howMany} elementos}}',
          'pluralExample'),
      'messageWithVariable':
          IcuMainMessage('Compartir {variable}', 'messageWithVariable'),
    };
  }

  _test();
}

abstract class ParsingFormatTester<T> implements FormatTester<T> {
  ///Messages file
  T get simpleMessage;
  T get messageWithMetadata;
  T get pluralMessage;
  T get variableMessage;
  T get allMessages;

  testParseFile();

  @override
  _test() {
    testParseFile();
  }
}

abstract class GenerateTranslationTester<T> implements FormatTester<T> {
  ///Template file
  T get templateSimpleMessage;
  T get templateMessageWithMetadata;
  T get templatePluralMessage;
  T get templateVariableMessage;
  T get templateAllMessages;

  testGenerateTemplate();

  @override
  _test() {
    testGenerateTemplate();
  }
}

abstract class MonolingualFormatTester extends FormatTester<String>
    implements ParsingFormatTester<String>, GenerateTranslationTester<String> {
  @override
  MonoLingualFormat get format;

  String get templateSimpleMessage => simpleMessage;
  String get templateMessageWithMetadata => messageWithMetadata;
  String get templatePluralMessage => pluralMessage;
  String get templateVariableMessage => variableMessage;
  String get templateAllMessages => allMessages;

  @override
  _test() {
    testGenerateTemplate();
    testParseFile();
  }

  @override
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

  @override
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

abstract class MultilingualParsingTester extends FormatTester<String>
    implements ParsingFormatTester<String> {
  @override
  TranslationFormat<StringFileData> get format;

  @override
  _test() {
    testParseFile();
  }

  Map<String, List<MainMessage>> messagesForKey(String id) {
    return {
      'en': [messages[id]],
      'es': [translatedMessages[id]],
    };
  }

  testParseFile() {
    group('Parse file:', () {
      if (simpleMessage != null) {
        test('Simple Message', () {
          expectMulipluralFormatParsing(
            simpleMessage,
            format,
            messages: messagesForKey('simpleMessage'),
          );
        });
      }
      if (messageWithMetadata != null) {
        test('Simple Message with Metadata', () {
          expectMulipluralFormatParsing(
            messageWithMetadata,
            format,
            messages: messagesForKey('messageWithMetadata'),
          );
        });
      }
      if (pluralMessage != null) {
        test('Plural Message', () {
          expectMulipluralFormatParsing(
            pluralMessage,
            format,
            messages: messagesForKey('pluralExample'),
          );
        });
      }
      if (variableMessage != null) {
        test('Message with variable', () {
          expectMulipluralFormatParsing(
            variableMessage,
            format,
            messages: messagesForKey('messageWithVariable'),
          );
        });
      }
      if (allMessages != null) {
        test('Parse file', () {
          expectMulipluralFormatParsing(pluralMessage, format, messages: {
            'en': messages.values.toList(),
            'es': translatedMessages.values.toList(),
          });
        });
      }
    });
  }
}

abstract class MultilingualGenerateTemplateTester extends FormatTester<String>
    implements GenerateTranslationTester<String> {
  @override
  TranslationFormat<StringFileData> get format;

  @override
  _test() {
    testGenerateTemplate();
  }

  Map<String, List<MainMessage>> messagesForKey(String id) {
    return {
      'en': [messages[id]],
      'es': [translatedMessages[id]],
    };
  }

  testGenerateTemplate() {
    group('Generate template:', () {
      if (templateSimpleMessage != null) {
        test('Simple Message', () {
          expectFormatTemplateGeneration(
            templateSimpleMessage,
            format,
            messages: [messages['simpleMessage']],
          );
        });
      }

      if (templateMessageWithMetadata != null) {
        test('Simple Message with Metadata', () {
          expectFormatTemplateGeneration(
            templateMessageWithMetadata,
            format,
            messages: [messages['messageWithMetadata']],
          );
        });
      }

      if (templatePluralMessage != null) {
        test('Plural Message', () {
          expectFormatTemplateGeneration(
            templatePluralMessage,
            format,
            messages: [messages['pluralExample']],
          );
        });
      }

      if (templateVariableMessage != null) {
        test('Message with Variable', () {
          expectFormatTemplateGeneration(
            templateVariableMessage,
            format,
            messages: [messages['messageWithVariable']],
          );
        });
      }

      if (templateAllMessages != null) {
        test('Multiple messages - full file', () {
          expectFormatTemplateGeneration(
            templateAllMessages,
            format,
            messages: messages.values.toList(),
          );
        });
      }
    });
  }
}
