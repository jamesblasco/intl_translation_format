import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:test/test.dart';

/// Mock Template used for testing
///
/// The messages are added programatically in the constructor
class MockTemplate extends TranslationTemplate {
  MockTemplate(
    String projectName,
    this.messages, {
    String locale = 'en',
  }) : super(
          projectName,
          locale: locale,
        );
  @override
  final Map<String, MainMessage> messages;
}

/// Compares two message with their icu string version.
void expectMessage(Message message, Message expected) {
  expect(
    messageToIcuString(message),
    messageToIcuString(expected),
  );
}

/// Compares a file content with the messages that are expected
/// after parsing the file with the indicated [format]
void expectFormatParsing(
  String content,
  MonoLingualFormat format, {
  List<MainMessage> messages = const [],
}) {
  final allTranslations = format.parseFile(content);

  for (final translated in allTranslations.messages.values) {
    final mainMessage = messages.firstWhere((e) => e.name == translated.id);
    final translatedMessage = translated.message..parent = mainMessage;
    expectMessage(translatedMessage, mainMessage);
  }
}

/// Compares a file content with the messages that are expected
/// after parsing the file with the indicated [format]
///
/// While [expectFormatParsing] works with monolingual files,
/// [expectMultiLingualFormatParsing] allows to test formats that
/// contains multiple languages
void expectMultiLingualFormatParsing(
  String content,
  MultiLingualFormat format, {
  Map<String, List<MainMessage>> messages,
  String defaultLocale = 'en',
}) {
  final result = format.parseFile(content, defaultLocale);
  for (final translatedForLocale in result) {
    final locale = translatedForLocale.locale;
    for (final translated in translatedForLocale.messages.values) {
      final mainMessage =
          messages[locale].firstWhere((e) => e.name == translated.id);
      final translatedMessage = translated.message..parent = mainMessage;
      expectMessage(translatedMessage, mainMessage);
    }
  }
}

/// Compares MainMessages with the template file that would be
/// generated using the indicated [format].
void expectFormatTemplateGeneration(
  String content,
  TranslationFormat<StringFileData> format, {
  List<MainMessage> messages = const [],
}) {
  final template = MockTemplate(
    'intl',
    Map.fromEntries(messages.map((e) => MapEntry(e.name, e))),
  );
  template.lastModified = null;
  final result = format.generateTemplateFiles(template).first.contents;
  expect(result, content);
}
